# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

MCPHub 是一个 Model Context Protocol (MCP) 服务器的统一管理和调度中心，提供灵活的 HTTP/SSE 端点来管理多个 MCP 服务器实例。

### 核心功能
- 统一管理多个 MCP 服务器
- 提供 HTTP 和 SSE 协议支持 
- 支持服务器分组和智能路由
- 内置用户认证和权限管理
- PostgreSQL + pgvector 支持的向量语义搜索
- React + Tailwind CSS 构建的管理面板

## 开发命令

### 项目构建
- `pnpm build` - 完整构建（后端+前端）
- `pnpm backend:build` - 仅构建后端（TypeScript 编译）
- `pnpm frontend:build` - 仅构建前端（Vite 构建）

### 开发模式
- `pnpm dev` - 并发启动后端和前端开发服务器
- `pnpm backend:dev` - 仅启动后端开发服务器（tsx watch）
- `pnpm frontend:dev` - 仅启动前端开发服务器（Vite）
- `pnpm backend:debug` - 启动后端调试模式（带 --inspect）

### 测试
- `pnpm test` - 运行所有测试
- `pnpm test:watch` - 监听模式运行测试
- `pnpm test:coverage` - 生成测试覆盖率报告
- `pnpm test:ci` - CI 环境测试（无监听）

### 代码质量
- `pnpm lint` - ESLint 检查
- `pnpm format` - Prettier 格式化

### 生产启动
- `pnpm start` - 启动生产环境服务器

## 项目架构

### 后端架构 (Node.js + Express + TypeScript)

**入口点**: `src/index.ts` -> `src/server.ts`

**核心服务层**:
- `src/services/mcpService.ts` - MCP 服务器管理核心
- `src/services/sseService.ts` - SSE 连接处理
- `src/services/groupService.ts` - 服务器分组管理
- `src/services/vectorSearchService.ts` - 向量搜索和智能路由
- `src/services/marketService.ts` - 服务器市场功能

**客户端层**:
- `src/clients/openapi.ts` - OpenAPI 客户端封装

**工具层**:
- `src/utils/smartRouting.ts` - 智能路由算法
- `src/utils/path.ts` - 路径处理工具

**中间件**:
- `src/middlewares/auth.ts` - JWT 认证
- `src/middlewares/index.ts` - 通用中间件

**配置管理**:
- `src/config/index.ts` - 配置加载和环境变量处理

### 前端架构 (React + Vite + Tailwind CSS)

- React 18 + TypeScript
- Vite 作为构建工具
- Tailwind CSS + shadcn/ui 组件库
- React Router 路由管理
- i18next 国际化支持

### 数据模型

**MCP 服务器配置** (`mcp_settings.json`):
```typescript
interface ServerConfig {
  command: string;
  args: string[];
  env?: Record<string, string>;
  enabled?: boolean;
  keepAliveInterval?: number;
}
```

**用户管理**:
- JWT 认证
- bcrypt 密码哈希
- 角色基础的访问控制

## 关键文件说明

### 配置文件
- `mcp_settings.json` - MCP 服务器和用户配置
- `servers.json` - 服务器市场数据
- `tsconfig.json` - TypeScript 配置（NodeNext 模块）
- `jest.config.cjs` - Jest 测试配置（ESM 支持）

### Docker 部署
- `Dockerfile` - 标准 Docker 部署
- `Dockerfile.hf` - Hugging Face Spaces 部署配置

### 协议支持
- **Stdio Transport**: 本地进程通信
- **SSE Transport**: 服务端推送事件
- **StreamableHTTP Transport**: HTTP 流式传输

### 智能路由功能
使用 pgvector 扩展实现向量语义搜索，自动匹配最相关的 MCP 工具。需要配置：
- PostgreSQL 数据库
- pgvector 扩展
- OpenAI API 密钥（嵌入服务）

## 开发注意事项

### 模块系统
项目使用 ESM (ECMAScript Modules)，所有 import 路径必须包含 `.js` 扩展名，即使源文件是 `.ts`

### 测试框架
使用 Jest + ts-jest，配置了 ESM 支持。测试文件应放在 `src/**/*.test.ts` 或 `tests/**/*.test.ts`

### 环境变量
支持通过 `${VARIABLE_NAME}` 语法在 `mcp_settings.json` 中使用环境变量

### TypeORM + 反射元数据
使用 TypeORM 作为数据库 ORM，需要 `reflect-metadata` 和装饰器支持

### 部署端点
- 默认端口: 3000
- HTTP 端点: `/mcp`, `/mcp/{group}`, `/mcp/{server}`
- SSE 端点: `/sse`, `/sse/{group}`, `/sse/{server}`
- 智能路由: `/mcp/$smart`, `/sse/$smart`