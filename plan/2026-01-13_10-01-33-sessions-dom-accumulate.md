---
mode: plan
cwd: /home/opensource/script/hapi
task: 修复 sessions 会话页 DOM 元素累积问题
complexity: medium
planning_method: builtin
created_at: 2026-01-13T10:01:33+08:00
---

# Plan: sessions 会话页 DOM 元素累积并消失

🎯 任务概述
会话页 `http://127.0.0.1:3007/sessions/d4d503e5-de86-4e8a-bf14-f6fbdc6b5ba8` 中，class 为 `py-1 min-w-0 max-w-full overflow-x-hidden` 的元素在页面底部不断累积；向上滑动到顶端后又消失。目标：用 Playwright 稳定复现、定位是“数据重复”还是“渲染/订阅泄漏”，给出可验证修复与回归用例。

📋 执行计划
1. 复现脚本：复用仓库现有 Playwright 配置（若存在）；否则写最小 Playwright 脚本，直连 `localhost:3007` 打开指定会话页。
2. 鉴权注入：查前端鉴权实现（token 存储位置/字段名），在脚本里写入 token（`c-kkSdnQGhJIEuFrgKXN9xG3kGF1iridlzOWvC6XkYM`）并刷新，确保可进入会话页。
3. 现象量化：Playwright 统计匹配选择器 `.py-1.min-w-0.max-w-full.overflow-x-hidden` 的节点数；执行“向下滚动→停顿→重复 N 次”；记录节点数随时间变化、截图/trace。
4. 数据 vs DOM 判定：
   - 若节点数增长同时“消息数据”也重复：优先查分页合并/增量订阅（WS/SSE）是否重复 append、是否缺 dedupe。
   - 若节点数增长但数据不重复：优先查虚拟列表/滚动容器实现是否未卸载、key 不稳定导致无法复用节点。
5. 代码定位：
   - `rg` 定位上述 class 字符串所在组件；再定位路由 `/sessions/:id` 的入口与消息列表组件。
   - 追踪数据来源：拉取历史记录 API、WS/SSE 实时流、以及把数据写入 state/store 的 reducer/merge 逻辑。
6. 根因修复（按优先级选最小改动）：
   - 订阅泄漏：`useEffect` 依赖稳定化；确保 `off/removeEventListener/close` 清理；避免 StrictMode 下重复注册导致双倍事件。
   - 分页/流去重：以 message id（或可构造的稳定 key）做 `Map/Set` 去重；合并逻辑改为“幂等追加”。
   - 列表渲染：确保 `key` 稳定且唯一；若用虚拟列表库，校正 itemKey/overscan/反向列表实现；避免把同一批 items 渲染两次（例如 header+list 双渲染）。
7. 回归验证：
   - Playwright 用例断言：重复滚动后 DOM 节点数不应单调无界增长（设置合理阈值/窗口）；向上滚动到顶端不应触发“清空再出现”的闪烁。
   - 手工验证：在目标会话页观察 1–2 分钟；确认性能（滚动不卡顿）与消息不重复。

⚠️ 风险与注意事项
- Dev 环境 React StrictMode 可能导致 effect 双执行；修复需保证幂等与正确 cleanup，而非关闭 StrictMode 规避。
- 若根因在 WS/SSE 双连接或重复监听，可能同时影响其它页面；需要最小范围回归（至少 session 列表与详情页）。
- Playwright 鉴权注入依赖具体实现（localStorage/cookie/header）；需先通过代码或网络请求确认。

📎 参考
- 复现页面：`http://127.0.0.1:3007/sessions/d4d503e5-de86-4e8a-bf14-f6fbdc6b5ba8`
- 目标元素 class：`py-1 min-w-0 max-w-full overflow-x-hidden`
