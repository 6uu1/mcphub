# MCPHub Hugging Face Spaces 部署指南

## 📋 概述

本指南将帮助你在 Hugging Face Spaces 上快速部署 MCPHub。我们提供了预构建的 Docker 镜像，让部署变得极其简单！

MCPHub 是一个 Model Context Protocol (MCP) 服务器的统一管理和调度中心，通过 Hugging Face Spaces，你可以轻松地在云端运行这个强大的工具。

## 🚀 快速开始（推荐方式）

### 使用预构建镜像一键部署

我们已经为你准备了优化过的 Docker 镜像，支持无数据库运行，完美适配 Hugging Face Spaces：

**镜像地址**: `ghcr.io/6uu1/mcphub-hf:pr-2`

### 部署步骤

#### 1. 创建 Hugging Face Space

1. **访问 Hugging Face Spaces**
   - 打开 [Hugging Face Spaces](https://huggingface.co/spaces)
   - 点击 "Create new Space"

2. **基础配置**
   - **Name**: `mcphub` (或你的首选名称)
   - **License**: `apache-2.0`
   - **SDK**: 选择 `Docker`
   - **Hardware**: 推荐 `CPU basic` 或更高配置
   - **Visibility**: 根据需要选择 Public 或 Private

#### 2. 配置 Dockerfile

在你的 Space 中创建一个简单的 `Dockerfile`：

```dockerfile
FROM ghcr.io/6uu1/mcphub-hf:pr-2

# 可选：如果你有自定义配置文件
# COPY mcp_settings.json ./mcp_settings.json

# 暴露端口 7860（HF Spaces 要求）
EXPOSE 7860

# 使用镜像内置的启动脚本
CMD ["python3", "app.py"]
```

#### 3. 创建 README.md

创建 Space 的说明文档（这会显示在你的 Space 首页）：

```markdown
---
title: MCPHub
emoji: 🔗
colorFrom: blue
colorTo: green  
sdk: docker
pinned: false
license: apache-2.0
app_port: 7860
---

# MCPHub - Model Context Protocol Server Hub

🔗 **统一的 MCP 服务器管理和调度中心**

## ✨ 功能特性

- 🎯 **统一管理** - 管理多个 MCP 服务器实例
- 🌐 **多协议支持** - HTTP、SSE、WebSocket 协议
- 📊 **服务器分组** - 智能路由和负载分发
- 🔐 **权限管理** - 内置用户认证系统
- 🎨 **现代界面** - 基于 React 的管理面板
- 🚀 **即开即用** - 预配置常用 MCP 服务器

## 🎮 使用方法

1. **启动应用** - Space 会自动构建和启动
2. **访问界面** - 点击上方 "App" 按钮进入管理界面  
3. **配置服务器** - 在界面中添加和管理 MCP 服务器
4. **API 调用** - 通过标准 MCP 协议与服务器交互

## 📡 API 端点

- `GET /api/health` - 应用健康检查
- `POST /mcp` - MCP 协议代理端点
- `GET /sse` - Server-Sent Events 连接
- `GET /` - Web 管理界面

## 🔧 预配置的 MCP 服务器

- **Memory Server** - 临时数据存储
- **Filesystem Server** - 文件系统访问（限制在 /tmp）
- **Fetch Server** - HTTP 请求工具
- **Brave Search** - 搜索引擎（需要 API 密钥）

更多服务器可在管理界面中添加！

## 🤝 支持与反馈

- [GitHub 仓库](https://github.com/samanhappy/mcphub)
- [问题反馈](https://github.com/samanhappy/mcphub/issues)
- [使用文档](https://github.com/samanhappy/mcphub/blob/main/README.md)

---

享受使用 MCPHub！🎉
```

#### 4. 环境变量配置（可选）

在 Space 的 Settings 中可以配置以下环境变量：

```bash
# 基础认证（可选，默认启用 skipAuth）
ADMIN_USERNAME=admin                    # 管理员用户名（默认：admin）
ADMIN_PASSWORD=your-secure-password     # 管理员密码（默认：mcphub123）

# API 密钥（可选）
BRAVE_API_KEY=your-brave-api-key       # Brave Search API
OPENAI_API_KEY=your-openai-key         # OpenAI API
ANTHROPIC_API_KEY=your-anthropic-key   # Anthropic API

# 认证设置（可选）
SKIP_AUTH=true                         # 跳过认证（默认：true）

# 其他 MCP 服务器相关的环境变量
GITHUB_TOKEN=your-github-token         # GitHub API 访问
SLACK_BOT_TOKEN=your-slack-token       # Slack 集成
```

#### 5. 启动和访问

1. **构建部署**
   - 将 Dockerfile 和 README.md 推送到 Space
   - HF Spaces 会自动开始构建
   - 构建过程可在 "Logs" 标签页查看

2. **访问应用**
   - 构建完成后，点击 "App" 标签页
   - **默认启用无认证模式** - 直接进入管理界面，无需登录
   - 如果看到登录页面，说明配置有问题（见故障排除）

3. **健康检查**
   ```bash
   curl https://your-space-name.hf.space/api/health
   ```

4. **验证无认证模式**
   ```bash
   curl https://your-space-name.hf.space/api/public-config
   # 应该返回: {"success": true, "data": {"skipAuth": true}}
   ```

## 🔧 自定义配置

### 添加自定义 MCP 服务器配置

如果你想自定义 MCP 服务器配置，可以创建自己的 `mcp_settings.json` 文件：

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/tmp"],
      "env": {},
      "enabled": true,
      "keepAliveInterval": 30000,
      "description": "文件系统访问（限制在 /tmp 目录）"
    },
    "memory": {
      "command": "npx", 
      "args": ["-y", "@modelcontextprotocol/server-memory"],
      "env": {},
      "enabled": true,
      "keepAliveInterval": 30000,
      "description": "内存存储服务器"
    },
    "brave-search": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-brave-search"],
      "env": {
        "BRAVE_API_KEY": "${BRAVE_API_KEY}"
      },
      "enabled": true,
      "keepAliveInterval": 30000,
      "description": "Brave 搜索引擎"
    }
  },
  "users": [
    {
      "id": "admin",
      "username": "${ADMIN_USERNAME}",
      "password": "${ADMIN_PASSWORD}",
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
```

然后在 Dockerfile 中添加：

```dockerfile
FROM ghcr.io/6uu1/mcphub-hf:pr-2

# 复制自定义配置
COPY mcp_settings.json ./mcp_settings.json

EXPOSE 7860
CMD ["python3", "app.py"]
```

## 💡 使用技巧

### 1. 快速测试
```bash
# 健康检查
curl https://your-space.hf.space/api/health

# 获取服务器列表  
curl https://your-space.hf.space/api/servers

# MCP 协议调用示例
curl -X POST https://your-space.hf.space/mcp \
  -H "Content-Type: application/json" \
  -d '{"method": "tools/list", "params": {}}'
```

### 2. 添加更多 MCP 服务器

常用的 MCP 服务器包：
- `@modelcontextprotocol/server-github` - GitHub 集成
- `@modelcontextprotocol/server-slack` - Slack 集成  
- `@modelcontextprotocol/server-fetch` - HTTP 请求工具
- `@amap/amap-maps-mcp-server` - 地图服务
- `tavily-mcp` - Tavily 搜索

### 3. 监控和日志

- **应用日志**: 在 Space 的 "Logs" 标签页查看
- **性能监控**: 通过 `/api/health` 端点监控应用状态
- **错误诊断**: 检查启动日志中的错误信息

## 🚨 故障排除

### 常见问题

1. **构建失败**
   ```
   ❌ Error: Cannot pull image ghcr.io/6uu1/mcphub-hf:pr-2
   ```
   **解决**: 确认镜像名称正确，或使用最新标签

2. **启动超时**
   ```
   ❌ Application failed to start within timeout
   ```
   **解决**: 升级到更高硬件配置，或检查镜像大小

3. **端口访问失败**
   ```
   ❌ Port 7860 not accessible
   ```
   **解决**: 确认 Dockerfile 中 EXPOSE 7860 和应用绑定到 0.0.0.0:7860

4. **意外显示登录页面**
   ```
   ❌ 显示登录页面，但应该启用无认证模式
   ```
   **解决**: 
   - 检查 `mcp_settings.json` 中 `"skipAuth": true` 设置
   - 验证配置: `curl https://your-space.hf.space/api/public-config`
   - 如果必须登录，默认账号密码：`admin` / `mcphub123`

5. **登录失败**
   ```
   ❌ Login failed, please check your username and password
   ```
   **解决**: 使用正确的默认凭据
   - **用户名**: `admin`
   - **密码**: `mcphub123` (不是 admin123!)
   - 或检查环境变量 `ADMIN_USERNAME` 和 `ADMIN_PASSWORD`

### 调试步骤

1. **查看构建日志**
   - 在 "Logs" 标签页查看详细的构建输出
   - 查找 ERROR 或 FAILED 关键词

2. **检查应用状态**
   ```bash
   # 健康检查
   curl https://your-space.hf.space/api/health
   
   # 查看配置
   curl https://your-space.hf.space/api/config
   ```

3. **验证环境变量**
   - 确认敏感信息（API 密钥）正确设置
   - 检查变量名称拼写

## 🔒 安全最佳实践

1. **API 密钥管理**
   - 使用 HF Spaces 的环境变量存储敏感信息
   - 不要在代码或配置文件中硬编码密钥

2. **访问控制**
   - 考虑启用认证：设置 `skipAuth: false`
   - 为生产环境设置强密码

3. **文件系统限制**
   - 文件系统 MCP 服务器仅限访问 `/tmp` 目录
   - 定期清理临时文件

4. **网络安全**
   - 仅配置必需的 MCP 服务器
   - 定期更新和审查配置

## 📚 下一步

1. **探索功能**: 在 Web 界面中熟悉各种功能
2. **集成应用**: 使用 MCP 协议将 MCPHub 集成到你的应用中
3. **自定义扩展**: 开发自己的 MCP 服务器
4. **社区参与**: 在 GitHub 上参与讨论和贡献

## 🤝 获取支持

- **文档**: [完整文档](https://github.com/samanhappy/mcphub/blob/main/README.md)
- **问题反馈**: [GitHub Issues](https://github.com/samanhappy/mcphub/issues)  
- **功能请求**: [GitHub Discussions](https://github.com/samanhappy/mcphub/discussions)
- **社区交流**: [Discord/Telegram 链接]

---

🎉 **恭喜！** 你已经成功在 Hugging Face Spaces 上部署了 MCPHub！

使用预构建镜像 `ghcr.io/6uu1/mcphub-hf:pr-2` 让部署变得极其简单。现在你可以开始探索 MCP 的强大功能了！
