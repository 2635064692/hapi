FROM oven/bun:1.3.5-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    ca-certificates \
    curl \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js (required for claude and codex CLI)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install uv (for uvx command used by codex MCP)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

# Install claude and codex CLI globally
RUN npm install -g @anthropic-ai/claude-code @openai/codex

# Create claude.json with MCP server configurations
RUN echo '{\
  "mcpServers": {\
    "codex": {\
      "command": "uvx",\
      "args": ["--from", "git+https://github.com/GuDaStudio/codexmcp.git", "codexmcp"],\
      "env": {},\
      "type": "stdio"\
    },\
    "mcp-router": {\
      "command": "npx",\
      "args": ["-y", "@mcp_router/cli@latest", "connect"],\
      "env": {\
        "MCPR_TOKEN": "mcpr_fD_JhJaUS8qTbSxVtg4cUfis3kbsTZ8K"\
      }\
    }\
  }\
}' > /root/.claude.json

WORKDIR /app

ENV NODE_ENV=development

EXPOSE 3000 5173

CMD ["sh", "-c", "bun install && bun run dev"]
