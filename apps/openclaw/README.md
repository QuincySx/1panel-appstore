# OpenClaw

自托管 AI 助手网关，连接 WhatsApp、Telegram、Discord、iMessage 等聊天应用到 AI 编程代理。

## 功能

- 多渠道支持（WhatsApp、Telegram、Discord、Slack、iMessage 等）
- 多代理路由与隔离会话
- Web 控制面板
- 媒体处理（图片、音频、文档）

## 安装后配置

### 1. 访问控制面板

安装时会自动生成 Gateway Token，查看方式：

```bash
cat <应用数据目录>/data/config/.gateway_token
```

浏览器打开：

```
http://<服务器IP>:<网关端口>?token=<Token>
```

### 2. 运行初始化向导

在控制面板中完成首次配置，或通过命令行：

```bash
docker exec -it <容器名> openclaw onboard
```

### 3. 配置聊天渠道（按需）

```bash
# WhatsApp（扫码登录）
docker exec -it <容器名> openclaw channels login

# Telegram
docker exec -it <容器名> openclaw channels add --channel telegram --token "<Bot Token>"

# Discord
docker exec -it <容器名> openclaw channels add --channel discord --token "<Bot Token>"
```

### 4. 设备授权

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
