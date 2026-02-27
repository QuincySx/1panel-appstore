# OpenClaw

自托管 AI 助手网关，连接 WhatsApp、Telegram、Discord、iMessage 等聊天应用到 AI 编程代理。

## 功能

- 多渠道支持（WhatsApp、Telegram、Discord、Slack、iMessage 等）
- 多代理路由与隔离会话
- Web 控制面板
- 媒体处理（图片、音频、文档）

## 安装后配置

### 1. 运行初始化向导

安装完成后，在宿主机执行 onboard 向导完成首次配置（设置模型提供商、API Key 等）：

```bash
docker exec -it <容器名> openclaw onboard
```

### 2. 获取 Dashboard Token

向导完成后，获取 Web 控制面板的访问令牌：

```bash
docker exec -it <容器名> openclaw dashboard --no-open
```

### 3. 访问控制面板

浏览器打开：

```
http://<服务器IP>:<网关端口>?token=<上一步获取的Token>
```

### 4. 配置聊天渠道（按需）

```bash
# WhatsApp（扫码登录）
docker exec -it <容器名> openclaw channels login

# Telegram
docker exec -it <容器名> openclaw channels add --channel telegram --token "<Bot Token>"

# Discord
docker exec -it <容器名> openclaw channels add --channel discord --token "<Bot Token>"
```

### 5. 设备授权

如有新设备请求访问，可查看并审批：

```bash
docker exec -it <容器名> openclaw devices list
docker exec -it <容器名> openclaw devices approve <requestId>
```

## 端口说明

- **网关端口 (18789)** - Web 控制面板 + WebSocket 网关
- **桥接端口 (18790)** - 客户端桥接连接

## 参考文档

- [官方文档](https://docs.openclaw.ai)
- [Docker 安装指南](https://docs.openclaw.ai/install/docker)
- [GitHub 仓库](https://github.com/openclaw/openclaw)
