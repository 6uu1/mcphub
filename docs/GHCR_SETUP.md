# MCPHub GitHub Container Registry (GHCR) Configuration

## 📋 概述

本文档说明如何配置和使用 MCPHub 项目的 GitHub Container Registry (ghcr.io) 集成。我们提供了两个工作流来自动构建和推送 Hugging Face Spaces 优化版本的容器镜像。

## 🏗️ GitHub Actions 工作流

### 1. 持续集成工作流 (`build-hf-container.yml`)

**触发条件:**
- 推送到 `main` 或 `feature/huggingface-docker-optimization` 分支
- 创建标签 (格式: `v*`)
- Pull Request 到 `main` 分支
- 手动触发

**功能:**
- 多架构构建 (AMD64 + ARM64)
- 自动标签管理
- 缓存优化
- 安全证明生成

### 2. 发布工作流 (`release-hf-container.yml`)

**触发条件:**
- GitHub Release 发布
- 手动触发 (可指定版本)

**功能:**
- 生成稳定版标签 (`latest`, `stable`, `hf-spaces`)
- 版本化标签
- 发布摘要生成

## 🔑 权限配置

### Repository 权限

工作流需要以下权限（已在 YAML 中配置）:

```yaml
permissions:
  contents: read        # 读取仓库内容
  packages: write       # 推送到 GHCR
  id-token: write       # OIDC token 生成
  attestations: write   # 安全证明
```

### GITHUB_TOKEN 自动权限

- GitHub Actions 会自动提供 `GITHUB_TOKEN`
- 无需创建 Personal Access Token (PAT)
- 自动具备推送到同一仓库下 GHCR 的权限

## 🏷️ 镜像标签策略

### 自动标签

| 触发条件 | 标签 | 示例 |
|---------|------|------|
| Push to main | `latest`, `hf-spaces` | `ghcr.io/user/repo-hf:latest` |
| Push to branch | `branch-name` | `ghcr.io/user/repo-hf:feature-branch` |
| Tag | `v1.0.0`, `1.0`, `1` | `ghcr.io/user/repo-hf:v1.0.0` |
| PR | `pr-123` | `ghcr.io/user/repo-hf:pr-123` |

### 发布标签

```bash
# 版本发布时生成的标签:
ghcr.io/user/repo-hf:v1.0.0
ghcr.io/user/repo-hf:latest
ghcr.io/user/repo-hf:stable
ghcr.io/user/repo-hf:hf-spaces
```

## 🚀 使用方法

### 1. 启用工作流

将工作流文件推送到仓库后，GitHub Actions 会自动运行：

```bash
# 触发构建
git push origin main

# 触发发布
git tag v1.0.0
git push origin v1.0.0
```

### 2. 拉取镜像

```bash
# 最新版本
docker pull ghcr.io/samanhappy/mcphub-hf:latest

# 特定版本
docker pull ghcr.io/samanhappy/mcphub-hf:v1.0.0

# HF Spaces 优化版
docker pull ghcr.io/samanhappy/mcphub-hf:hf-spaces
```

### 3. 运行容器

```bash
# 基本运行
docker run -p 7860:7860 ghcr.io/samanhappy/mcphub-hf:latest

# 带环境变量
docker run -p 7860:7860 \
  -e ADMIN_USERNAME=admin \
  -e ADMIN_PASSWORD=secure123 \
  ghcr.io/samanhappy/mcphub-hf:latest

# Docker Compose
version: '3.8'
services:
  mcphub:
    image: ghcr.io/samanhappy/mcphub-hf:latest
    ports:
      - "7860:7860"
    environment:
      - HF_SPACE=1
      - NODE_ENV=production
```

## 🔧 本地测试

在推送前测试工作流：

```bash
# 本地构建测试
docker build -f Dockerfile.hf -t mcphub-hf-test .

# 测试运行
docker run -p 7860:7860 mcphub-hf-test

# 验证健康检查
curl http://localhost:7860/api/health
```

## 📊 监控和调试

### 查看构建状态

1. 访问仓库的 **Actions** 标签
2. 选择对应的工作流运行
3. 查看日志和构建详情

### 查看镜像

1. 访问仓库的 **Packages** 标签
2. 找到 `mcphub-hf` 包
3. 查看版本、大小、下载统计

### 常见问题

**Q: 权限被拒绝**
A: 检查 Repository Settings > Actions > General > Workflow permissions 确保允许 GITHUB_TOKEN 写入

**Q: 构建失败**
A: 查看 Actions 日志，通常是 Dockerfile 错误或依赖安装问题

**Q: 镜像太大**
A: 检查 `.dockerignore` 文件，确保排除不必要的文件

## 🔒 安全最佳实践

1. **使用官方 Actions**: 所有 Actions 都来自官方或知名维护者
2. **最小权限**: 仅授予必要的权限
3. **版本固定**: Actions 使用特定版本 (如 `@v4`)
4. **安全扫描**: 自动进行容器安全扫描
5. **签名验证**: 生成并验证构建证明

## 📚 相关文档

- [GitHub Container Registry 文档](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [Docker Buildx 文档](https://docs.docker.com/buildx/)
- [Hugging Face Spaces 文档](https://huggingface.co/docs/hub/spaces)