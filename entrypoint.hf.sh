#!/bin/bash
set -e

# Hugging Face Spaces optimized entrypoint script for MCPHub

echo "🌟 MCPHub - Starting in Hugging Face Spaces mode..."

# Set default environment variables if not provided
export HF_SPACE=${HF_SPACE:-1}
export PORT=${PORT:-7860}
export HOST=${HOST:-0.0.0.0}
export NODE_ENV=${NODE_ENV:-production}

# Set default admin credentials if not provided
export ADMIN_USERNAME=${ADMIN_USERNAME:-admin}
export ADMIN_PASSWORD=${ADMIN_PASSWORD:-mcphub123}

echo "📊 Environment Configuration:"
echo "  - HF_SPACE: $HF_SPACE"
echo "  - PORT: $PORT"
echo "  - HOST: $HOST"
echo "  - NODE_ENV: $NODE_ENV"
echo "  - Admin User: $ADMIN_USERNAME"

# Check if mcp_settings.json exists, if not copy from template
if [ ! -f "mcp_settings.json" ]; then
    if [ -f "mcp_settings.hf.json" ]; then
        echo "📄 Copying HF Spaces configuration template..."
        cp mcp_settings.hf.json mcp_settings.json
    else
        echo "⚠️  No configuration file found, creating minimal config..."
        cat > mcp_settings.json << EOF
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"],
      "env": {},
      "enabled": true,
      "keepAliveInterval": 30000,
      "description": "内存存储服务器，提供临时数据存储"
    }
  },
  "users": [
    {
      "id": "admin",
      "username": "\${ADMIN_USERNAME}",
      "password": "\${ADMIN_PASSWORD}",
      "role": "admin"
    }
  ],
  "systemConfig": {
    "skipAuth": true,
    "smartRouting": {
      "enabled": false
    }
  }
}
EOF
    fi
fi

echo "✅ Configuration ready"

# Start the Node.js application
echo "🚀 Starting MCPHub server..."
exec node dist/index.js