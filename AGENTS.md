# AGENTS.md

Work style: telegraph; noun-phrases ok; drop grammar;

Short guide for AI agents in this repo. Prefer progressive loading: start with the root README, then package READMEs as needed.

## Repo layout
- `cli/` - hapi CLI, daemon, Codex/MCP tooling
- `server/` - Telegram bot + HTTP API + Socket.IO + SSE
- `web/` - React Mini App / PWA

## Reference docs
- `README.md` (user overview)
- `cli/README.md` (CLI behavior and config)
- `server/README.md` (server setup and architecture)
- `web/README.md` (web app behavior and dev workflow)
- `localdocs/` (optional deep dives)

## Shared rules
- No backward compatibility: breaking old format freely.
- TypeScript strict; no untyped code.
- Bun workspaces; run `bun` commands from repo root.
- Path alias `@/*` maps to `./src/*` per package.
- Prefer 4-space indentation.

## Common commands (repo root)

- `bun typecheck`
- `bun run test`

## Key source dirs
- `cli/src/api/`, `cli/src/claude/`, `cli/src/commands/`, `cli/src/codex/`
- `server/src/web/`, `server/src/socket/`, `server/src/telegram/`, `server/src/sync/`
- `web/src/components/`, `web/src/api/`, `web/src/hooks/`

## Critical Thinking

1. Fix root cause (not band-aid).
2. Unsure: read more code; if still stuck, ask w/ short options.
3. Conflicts: call out; pick safer path.
4. Unrecognized changes: assume other agent; keep going; focus your changes. If it causes issues, stop + ask user.

## 中文工作约定（补充）

- 输出语言：中文为主；术语尽量通俗，必要时给简短解释。
- 业务优先：面向业务价值给最小可行解；避免过度工程化；拒绝临时“打补丁”思路，优先治本。
- 验证环境：默认容器 `hapi-hapi-1`；可用 Playwright 做 UI/流程验证；可用 DeepWiki（GitHub wiki 相关 MCP）辅助获取答案。
- 执行边界：命令/脚本在容器内执行；代码阅读分析与文件修改在 host 侧完成（通过工作区文件变更落盘）。

## MCP 使用优先级（按可用工具）

- 项目内资源：`functions.list_mcp_resources` → `functions.read_mcp_resource` / `functions.list_mcp_resource_templates`；降级：本地 `rg`。
- GitHub 仓库问答：`mcp__mcp-router__ask_question`；降级：`mcp__mcp-router__read_wiki_structure` / `mcp__mcp-router__read_wiki_contents`；再降级：`mcp__mcp-router__fetch_content` 抓 raw 文件。
- 文档/库资料：`mcp__mcp-router__resolve-library-id` → `mcp__mcp-router__query-docs`；降级：`mcp__mcp-router__search` → `mcp__mcp-router__fetch_content`。
- 失败与节流：超时/429/5xx 最多重试 2 次（指数退避）；仍失败立即切换降级路径；输出注明覆盖范围/假设/可验证步骤。
