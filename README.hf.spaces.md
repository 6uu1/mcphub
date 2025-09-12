---
title: MCPHub - Model Context Protocol Server Hub
emoji: 🌟
colorFrom: blue
colorTo: purple
sdk: docker
app_file: src/index.ts
app_port: 7860
suggested_hardware: cpu-basic
suggested_storage: small
tags:
  - mcp
  - model-context-protocol
  - ai-tools
  - server-management
  - typescript
  - nodejs
license: apache-2.0
---

# MCPHub: The Unified Hub for Model Context Protocol (MCP) Servers

🚀 **Live Demo**: This Space provides a unified interface to manage and access multiple MCP (Model Context Protocol) servers through flexible HTTP/SSE endpoints.

## ✨ Features

- **🔄 Unified MCP Server Management**: Seamlessly integrate and manage multiple MCP servers from one interface
- **📊 Real-time Dashboard**: Monitor server status, performance metrics, and logs
- **🔗 Multiple Protocol Support**: Full compatibility with stdio, SSE, and HTTP protocols
- **🔧 Hot-swappable Configuration**: Add, remove, or update servers without downtime
- **👥 Group-based Access**: Organize servers into logical groups for better management
- **🔐 Secure Authentication**: Built-in user management with JWT-based authentication
- **🤖 Smart Routing**: AI-powered tool discovery using vector semantic search
- **⚡ Performance Optimized**: Built for reliability and speed in cloud environments

## 🚀 Quick Start

### Using the Web Interface

1. **Access the Dashboard**: Open this Space and log in with:
   - **Username**: `admin`
   - **Password**: `admin123`

2. **Configure MCP Servers**: Add your MCP servers through the intuitive web interface

3. **Create Groups**: Organize servers into logical groups for easier management

### HTTP Endpoints

Connect your AI clients to these endpoints:

```bash
# All servers
https://your-space-name-username.hf.space/mcp

# Smart routing (AI-powered tool discovery)
https://your-space-name-username.hf.space/mcp/$smart

# Specific group
https://your-space-name-username.hf.space/mcp/{group-name}

# Individual server
https://your-space-name-username.hf.space/mcp/{server-name}
```

## 🛠️ Configuration

### Default MCP Servers

This Space comes pre-configured with popular MCP servers:

- **🗺️ Amap Maps**: Geographic and mapping services
- **🌐 Fetch**: HTTP request capabilities  
- **📚 Context7**: Documentation and knowledge base access
- **💬 Slack**: Team communication integration

### Adding Custom Servers

1. Navigate to the **Servers** tab in the dashboard
2. Click **Add Server** and provide:
   - Server name
   - Command and arguments
   - Environment variables (if needed)
3. Enable the server and assign it to groups as needed

### Environment Variables

Configure these in your Space settings:

```bash
# External API Keys
AMAP_MAPS_API_KEY=your_amap_api_key
SLACK_BOT_TOKEN=your_slack_bot_token
SLACK_TEAM_ID=your_slack_team_id
OPENAI_API_KEY=your_openai_key  # For smart routing

# Database (optional for persistence)
DATABASE_URL=postgresql://user:pass@host:5432/mcphub

# Custom admin credentials
ADMIN_USERNAME=your_admin_username
ADMIN_PASSWORD=your_secure_password
```

## 📈 Smart Routing

MCPHub's intelligent tool discovery uses vector semantic search to automatically find the most relevant tools for any given task.

**How it works:**
1. All MCP tools are indexed as vector embeddings
2. User queries are matched against tool embeddings using cosine similarity
3. Dynamic thresholds ensure relevant results without noise
4. Found tools can be executed directly with parameter validation

## 🔧 Technical Architecture

- **Backend**: Node.js, Express, TypeScript
- **Frontend**: React, Vite, Tailwind CSS
- **Database**: PostgreSQL with pgvector (optional)
- **Authentication**: JWT with bcrypt
- **Protocols**: Full MCP SDK support (stdio, SSE, HTTP)

## 🤝 Contributing

This is an open-source project! Contributions welcome:

- **GitHub**: [samanhappy/mcphub](https://github.com/samanhappy/mcphub)
- **Issues**: Report bugs or request features
- **Discord**: Join our [community](https://discord.gg/qMKNsn5Q)

## 📄 License

Licensed under the [Apache 2.0 License](https://github.com/samanhappy/mcphub/blob/main/LICENSE).

---

⭐ **Star the project on GitHub** if you find MCPHub useful!

🔗 **Connect with AI Tools**: Use the endpoints above to integrate MCPHub with Claude Desktop, Cursor, or any MCP-compatible client.