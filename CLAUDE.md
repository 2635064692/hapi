# CLAUDE.md - HAPI 项目 AI 协作指南

## Core Instruction for CodeX MCP

在任何时刻，你必须思考当前过程可以如何与 codex 进行协作，如何调用 Codex 为你提供的 MCP 工具作为你客观全面分析的保障。

其中你**务必执行**以下几个步骤：

1. 在你对用户需求形成初步分析后，将用户需求、初始思路告知 codex，并要求其完善需求分析和实施计划。

2. 在实施具体编码任务前，**必须向 codex 索要代码实现原型（要求 codex 仅给出 unified diff patch，严禁对代码做任何真实修改）**。在获取代码原型后，你**只能以此为逻辑参考，再次对代码修改进行重写**，形成企业生产级别、可读性极高、可维护性极高的代码后，才能实施具体编程修改任务。

3. 无论何时，只要完成切实编码行为后，**必须立即使用 codex review 代码改动和对应需求完成程度**。

4. codex 只能给出参考，你**必须有自己的思考，甚至需要对 codex 的回答提出质疑**。尽信书则不如无书，你与 codex 的最终使命都是达成统一、全面、精准的意见，所以你们必须不断争辩以找到通向真理的唯一途径。


## Codex Tool Invocation Specification

### 1. 工具概述

codex MCP 提供了一个工具 `codex`，用于执行 AI 辅助的编码任务。该工具**通过 MCP 协议调用**，无需使用命令行。

### 2. 工具参数

**必选参数**：
- `PROMPT` (string): 发送给 codex 的任务指令
- `cd` (Path): codex 执行任务的工作目录根路径

**可选参数**：
- `sandbox` (string): 沙箱策略，可选值：
  - `"read-only"` (默认): 只读模式，最安全
  - `"workspace-write"`: 允许在工作区写入
  - `"danger-full-access"`: 完全访问权限
- `SESSION_ID` (UUID | null): 用于继续之前的会话以与 codex 进行多轮交互，默认为 None（开启新会话）
- `skip_git_repo_check` (boolean): 是否允许在非 Git 仓库中运行，默认 False
- `return_all_messages` (boolean): 是否返回所有消息（包括推理、工具调用等），默认 False
- `image` (List[Path] | null): 附加一个或多个图片文件到初始提示词，默认为 None
- `model` (string | null): 指定使用的模型，默认为 None（使用用户默认配置）
- `yolo` (boolean | null): 无需审批运行所有命令（跳过沙箱），默认 False
- `profile` (string | null): 从 `~/.codex/config.toml` 加载的配置文件名称，默认为 None（使用用户默认配置）

**返回值**：
```json
{
  "success": true,
  "SESSION_ID": "uuid-string",
  "agent_messages": "agent回复的文本内容",
  "all_messages": []  // 仅当 return_all_messages=True 时包含
}
```

或失败时：
```json
{
  "success": false,
  "error": "错误信息"
}
```

### 3. 使用方式

**开启新对话**：
- 不传 `SESSION_ID` 参数（或传 None）
- 工具会返回新的 `SESSION_ID` 用于后续对话

**继续之前的对话**：
- 将之前返回的 `SESSION_ID` 作为参数传入
- 同一会话的上下文会被保留

### 4. 调用规范

**必须遵守**：
- 每次调用 codex 工具时，必须保存返回的 `SESSION_ID`，以便后续继续对话
- `cd` 参数必须指向存在的目录，否则工具会静默失败
- 严禁 codex 对代码进行实际修改，使用 `sandbox="read-only"` 以避免意外，并要求 codex 仅给出 unified diff patch 即可

**推荐用法**：
- 如需详细追踪 codex 的推理过程和工具调用，设置 `return_all_messages=True`
- 对于精准定位、debug、代码原型快速编写等任务，优先使用 codex 工具

### 5. 注意事项

- **会话管理**：始终追踪 `SESSION_ID`，避免会话混乱
- **工作目录**：确保 `cd` 参数指向正确且存在的目录
- **错误处理**：检查返回值的 `success` 字段，处理可能的错误


## 已知问题与修复记录

### [2026-01-15] 分页边界导致工具组件错误合并

**问题描述**：
在 Session 页面初始加载时，某些工具组件（如 `/root/.claude.json`）会被错误地合并到不属于它的 AI 响应消息块中，显示在页面底部错误的位置。

**复现步骤**：
1. 访问包含大量消息的 Session 页面（如 `http://127.0.0.1:3006/sessions/<session-id>`）
2. 观察初始加载的消息列表
3. 发现某些工具调用块被错误地合并到最后一个 AI 响应中
4. 向上滚动并点击 "Load more" 加载更多历史消息
5. 加载更多消息后，之前被错误合并的工具组件会回到正确的位置

**根本原因**：
- 分页机制使用 `PAGE_SIZE = 50` 限制初始加载的消息数量
- 当分页边界恰好截断了作为分隔符的用户消息时，会导致相邻的 AI 响应消息失去边界
- `@assistant-ui/react` 库的 `useExternalMessageConverter` 会自动合并相邻的 assistant 消息
- 缺少用户消息分隔时，不同的 AI 响应被错误地合并为一个消息块

**解决方案**：
为 `ChatBlock` 类型添加 `sourceMessageId` 字段，记录每个 block 来源的原始消息 ID，然后在 `assistant-runtime.ts` 中按 `sourceMessageId` 分组，并使用 `joinStrategy: 'none'` 阻止跨消息边界的自动合并。

**涉及文件**：
- `web/src/chat/types.ts` - 所有 ChatBlock 类型添加 `sourceMessageId: string` 字段
- `web/src/chat/reducerTimeline.ts` - 创建 block 时传递 `sourceMessageId`
- `web/src/chat/reducer.ts` - `ensureToolBlock` 调用时传递 `sourceMessageId`
- `web/src/lib/assistant-runtime.ts` - 按 `sourceMessageId` 分组并设置 `joinStrategy: 'none'`


## 开发环境配置

**开发容器**：`hapi-hapi-1`
- 项目已挂载到容器中，所有开发相关的 shell 命令**必须**在此容器内执行
- 禁止在宿主机直接执行 shell 命令
- 执行命令格式：`docker exec -it hapi-hapi-1 <command>`
- 示例：
  - 编译检查：`docker exec -it hapi-hapi-1 sh -c "cd /app/web && npx tsc --noEmit"`
  - 运行测试：`docker exec -it hapi-hapi-1 sh -c "cd /app/web && npm test"`
  - 启动开发服务器：`docker exec -it hapi-hapi-1 sh -c "cd /app/web && npm run dev"`

**验证地址**：
- Web 开发服务器：`http://127.0.0.1:5174`
- 示例 Session 页面：`http://127.0.0.1:5174/sessions/47eb72d1-c807-4173-a26a-4e69e26a24e7`


## 网络代理配置

当遇到网络异常问题时，可使用以下代理配置：

1. **本机直连代理**：`127.0.0.1:10709`
   - 适用于本机网络异常场景

2. **容器环境代理**：`<容器网关IP>:7890`
   - 当容器非 host 网络模式时，使用容器网络的 `.1` 段 IP
   - 例如：容器 IP 为 `192.168.18.2`，则代理地址为 `192.168.18.1:7890`
   - 原理：宿主机使用 socat 将 7890 端口转发至 `127.0.0.1:10709`
