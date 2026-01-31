<div align="center">

# 🤖 OpenClaw Feishu Plugin

<p align="center">
  <em>飞书/Lark 企业消息平台的 OpenClaw 插件</em>
</p>

<p align="center">
  <a href="https://www.npmjs.com/package/@overlink/openclaw-feishu">
    <img src="https://img.shields.io/npm/v/@overlink/openclaw-feishu?style=flat-square&logo=npm" alt="npm version" />
  </a>
  <a href="https://www.npmjs.com/package/@overlink/openclaw-feishu">
    <img src="https://img.shields.io/npm/dm/@overlink/openclaw-feishu?style=flat-square&logo=npm" alt="npm downloads" />
  </a>
  <a href="https://github.com/overlink/openclaw-feishu/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/overlink/openclaw-feishu?style=flat-square" alt="license" />
  </a>
</p>

<p align="center">
  <a href="./README.md">🇨🇳 简体中文</a> | <a href="./README_EN.md">🇺🇸 English</a>
</p>

</div>

---

## ✨ 特性

- 🌍 **双版本支持** - 同时支持飞书国内版和国际版（Lark）
- 🔌 **双连接模式** - 支持 WebSocket 长连接和 Webhook 回调
- 💬 **全场景支持** - 私聊、群聊、@提及、消息回复
- 🖼️ **富媒体处理** - AI 可识别图片、读取文件（PDF/Excel）、处理富文本
- 📤 **文件上传** - 支持图片和文件的上传发送
- 🎨 **智能渲染** - 自动选择纯文本或 Markdown 卡片渲染
- 🔐 **权限控制** - 灵活的私聊/群聊白名单策略
- ⚡ **即时响应** - v0.1.5 修复：消息在生成时立即发送，无需等待全部完成

---

## 📦 安装

### 方式 1：通过 OpenClaw CLI（推荐）

```bash
openclaw plugins install @overlink/openclaw-feishu
```

### 方式 2：通过 npm

```bash
npm install @overlink/openclaw-feishu
```

### 方式 3：手动安装（离线环境）

```bash
# 1. 下载插件包
curl -O https://registry.npmjs.org/@overlink/openclaw-feishu/-/openclaw-feishu-0.1.10.tgz

# 2. 安装本地包
openclaw plugins install ./openclaw-feishu-0.1.10.tgz
```

---

## 🚀 快速开始

### 📌 选择版本

本插件同时支持飞书的两个版本：

| 版本 | 服务区域 | 开放平台地址 | 客户端名称 |
|------|---------|------------|-----------|
| 🇨🇳 **飞书国内版** | 中国大陆 | [open.feishu.cn](https://open.feishu.cn) | 飞书 |
| 🌏 **Lark 国际版** | 海外及港澳台 | [open.larksuite.com](https://open.larksuite.com) | Lark |

> **💡 提示**：
> - 国内企业用户通常使用**飞书国内版**
> - 海外企业或跨国公司使用 **Lark 国际版**
> - 两个版本的应用和数据**完全隔离**，不互通

### 第 1 步：创建应用

根据你使用的版本，访问对应的开放平台：

#### 飞书国内版

1. 访问 [飞书开放平台](https://open.feishu.cn)
2. 创建**自建应用**
3. 在**凭证与基础信息**页面获取：
   - `App ID`（如 `cli_xxxxx`）
   - `App Secret`

#### Lark 国际版

1. 访问 [Lark Open Platform](https://open.larksuite.com)
2. 创建 **Custom App**
3. 在 **Credentials & Basic Info** 页面获取：
   - `App ID`（如 `cli_xxxxx`）
   - `App Secret`

### 第 2 步：配置权限

在应用后台 → **权限管理** 中开启以下权限：

#### 🔴 必需权限

| 权限标识 | 权限名称 | 用途 |
|---------|---------|------|
| `contact:user.base:readonly` | 获取用户基本信息 | 解析发送者姓名（避免混淆说话者） |
| `im:message` | 获取与发送单聊、群组消息 | 收发消息 |
| `im:message.p2p_msg:readonly` | 读取用户发给机器人的单聊消息 | 私聊接收 |
| `im:message.group_at_msg:readonly` | 获取群组中所有消息 | 群聊 @提及 |
| `im:message:send_as_bot` | 以应用的身份发消息 | 发送回复 |
| `im:resource` | 获取与上传图片或文件资源 | 媒体文件处理 |

#### 🟡 可选权限（按需开启）

| 权限标识 | 权限名称 | 用途 |
|---------|---------|------|
| `im:message.group_msg` | 接收群聊中所有消息 | 无需 @也能响应（敏感权限） |
| `im:message:readonly` | 查询消息历史 | 获取历史消息 |
| `im:message:update` | 更新应用发送的消息卡片 | 编辑已发送消息 |
| `im:message:recall` | 撤回应用发送的消息 | 撤回消息 |

> **💡 提示**：权限申请后需等待管理员审核通过。

### 第 3 步：配置事件订阅 ⚠️

> **这是最容易遗漏的配置！** 如果机器人能发消息但收不到消息，一定要检查此项。

在应用后台 → **事件与回调** 页面：

1. **事件配置方式**：选择 `使用长连接接收事件`（推荐）
2. **添加事件订阅**，勾选以下事件：

| 事件名称 | 说明 |
|---------|------|
| `接收消息 v2.0` (`im.message.receive_v1`) | 必需，接收用户消息 |
| `消息已读` (`im.message.message_read_v1`) | 可选，已读回执 |
| `机器人进群` (`im.chat.member.bot.added_v1`) | 可选，群组管理 |
| `机器人被移出群` (`im.chat.member.bot.deleted_v1`) | 可选，群组管理 |

3. 确保事件订阅的权限已通过审核

### 第 4 步：配置 OpenClaw

根据你使用的版本配置：

#### 飞书国内版

```bash
openclaw config set channels.openclaw-feishu.domain "feishu"
openclaw config set channels.openclaw-feishu.appId "cli_xxxxx"
openclaw config set channels.openclaw-feishu.appSecret "your_app_secret"
openclaw config set channels.openclaw-feishu.enabled true
openclaw restart
```

#### Lark 国际版

```bash
openclaw config set channels.openclaw-feishu.domain "lark"
openclaw config set channels.openclaw-feishu.appId "cli_xxxxx"
openclaw config set channels.openclaw-feishu.appSecret "your_app_secret"
openclaw config set channels.openclaw-feishu.enabled true
openclaw restart
```

> **⚠️ 重要**：`domain` 参数必须与你的应用版本匹配！
> - 飞书国内版：`domain: "feishu"`
> - Lark 国际版：`domain: "lark"`

---

## ⚙️ 配置选项

### 基础配置

```yaml
channels:
  feishu:
    enabled: true                    # 启用插件
    appId: "cli_xxxxx"               # 应用 App ID
    appSecret: "your_secret"         # 应用 App Secret
    domain: "feishu"                 # 🌍 版本选择："feishu"（国内版）或 "lark"（国际版）
    connectionMode: "websocket"      # 连接模式："websocket" 或 "webhook"
```

### 权限策略

```yaml
channels:
  feishu:
    # 私聊策略
    dmPolicy: "pairing"              # "pairing"（配对审批）| "open"（全开放）| "allowlist"（白名单）
    
    # 群聊策略
    groupPolicy: "allowlist"         # "open"（全开放）| "allowlist"（白名单）| "disabled"（禁用）
    
    # 群聊是否需要 @机器人
    requireMention: true             # true（需要@）| false（不需要@，需开启敏感权限）
```

### 高级选项

```yaml
channels:
  feishu:
    # 渲染模式
    renderMode: "auto"               # "auto"（自动）| "raw"（纯文本）| "card"（卡片）
    
    # 媒体文件限制
    mediaMaxMb: 30                   # 单个文件最大大小（MB）
```

### 📝 渲染模式说明

| 模式 | 效果 | 适用场景 |
|------|------|---------|
| `auto` | 有代码块/表格时用卡片，否则纯文本 | 默认推荐，智能选择 |
| `raw` | 始终纯文本，表格转 ASCII | 简洁阅读，避免格式干扰 |
| `card` | 始终 Markdown 卡片（语法高亮、表格、链接） | 重度技术内容，需要格式化展示 |

---

## 🔧 常见问题

### ❌ 机器人收不到消息

**检查清单：**

1. ✅ 是否配置了**事件订阅**？（见上方第 3 步）
2. ✅ 事件配置方式是否选择了**长连接**？
3. ✅ 是否添加了 `im.message.receive_v1` 事件？
4. ✅ 相关权限是否已审核通过？

### ❌ 发送消息时返回 403 错误

确保 `im:message:send_as_bot` 权限已申请**并审核通过**。

### ❓ 如何清除历史对话？

在聊天中发送 `/new` 命令。

### ❓ 为什么消息不是流式输出？

飞书 API 有严格的频率限制，频繁更新消息容易触发限流。v0.1.5 已优化为：**消息在生成时立即发送**（而非等待全部完成），在稳定性和实时性之间取得平衡。

### ❌ Windows 安装失败（`spawn npm ENOENT`）

如果 `openclaw plugins install` 失败，改用手动安装（见上方"方式 3"）。

### ❓ 在飞书里找不到机器人

1. 确保应用已**发布**（至少发布到测试版本）
2. 在飞书搜索框搜索机器人名称
3. 检查应用的**可用范围**是否包含你的账号

---

## 📄 许可证

[MIT License](./LICENSE)

---

## 🔗 相关链接

- [OpenClaw 官网](https://github.com/openclaw/openclaw)
- [飞书开放平台文档](https://open.feishu.cn/document)
- [npm 包地址](https://www.npmjs.com/package/@overlink/openclaw-feishu)
- [GitHub 仓库](https://github.com/overlink/openclaw-feishu)

---

<div align="center">
  <sub>Built with ❤️ for the OpenClaw community</sub>
</div>
