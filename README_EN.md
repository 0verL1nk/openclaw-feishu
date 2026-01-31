<div align="center">

# 🤖 OpenClaw Feishu Plugin

<p align="center">
  <em>OpenClaw plugin for Feishu/Lark enterprise messaging platform</em>
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

## ✨ Features

- 🌍 **Dual Version Support** - Works with both Feishu (China) and Lark (International)
- 🔌 **Dual Connection Modes** - WebSocket long-polling and Webhook callback
- 💬 **Full Scenario Support** - DMs, group chats, @mentions, message replies
- 🖼️ **Rich Media Processing** - AI can see images, read files (PDF/Excel), process rich text
- 📤 **File Upload** - Send images and files
- 🎨 **Smart Rendering** - Auto-switch between plain text and Markdown cards
- 🔐 **Access Control** - Flexible DM/group allowlist policies
- ⚡ **Instant Delivery** - v0.1.5 fix: messages sent immediately during generation

---

## 📦 Installation

### Method 1: Via OpenClaw CLI (Recommended)

```bash
openclaw plugins install @overlink/openclaw-feishu
```

### Method 2: Via npm

```bash
npm install @overlink/openclaw-feishu
```

### Method 3: Manual Install (Offline)

```bash
# 1. Download the package
curl -O https://registry.npmjs.org/@overlink/openclaw-feishu/-/openclaw-feishu-0.1.10.tgz

# 2. Install from local file
openclaw plugins install ./openclaw-feishu-0.1.10.tgz
```

---

## 🚀 Quick Start

### 📌 Choose Your Version

This plugin supports both versions of Feishu:

| Version | Region | Open Platform | Client Name |
|---------|--------|---------------|-------------|
| 🇨🇳 **Feishu (China)** | Mainland China | [open.feishu.cn](https://open.feishu.cn) | 飞书 (Feishu) |
| 🌏 **Lark (International)** | Global & Hong Kong/Taiwan | [open.larksuite.com](https://open.larksuite.com) | Lark |

> **💡 Note**:
> - Enterprises in China typically use **Feishu (China version)**
> - International companies use **Lark (International version)**
> - The two versions are **completely isolated** with separate apps and data

### Step 1: Create Application

Visit the corresponding open platform based on your version:

#### Feishu (China)

1. Go to [Feishu Open Platform](https://open.feishu.cn)
2. Create a **Custom App** (自建应用)
3. Get your credentials from **Credentials & Basic Info** page:
   - `App ID` (e.g., `cli_xxxxx`)
   - `App Secret`

#### Lark (International)

1. Go to [Lark Open Platform](https://open.larksuite.com)
2. Create a **Custom App**
3. Get your credentials from **Credentials & Basic Info** page:
   - `App ID` (e.g., `cli_xxxxx`)
   - `App Secret`

### Step 2: Configure Permissions

In the app console → **Permissions & Scopes**, enable the following:

#### 🔴 Required Permissions

| Permission | Scope | Purpose |
|-----------|-------|---------|
| `contact:user.base:readonly` | User info | Resolve sender display names (prevent speaker confusion) |
| `im:message` | Messaging | Send and receive messages |
| `im:message.p2p_msg:readonly` | Direct messages | Receive DMs sent to bot |
| `im:message.group_at_msg:readonly` | Group messages | Receive @mentions in groups |
| `im:message:send_as_bot` | Send messages | Send replies as bot |
| `im:resource` | Media resources | Upload and download images/files |

#### 🟡 Optional Permissions

| Permission | Scope | Purpose |
|-----------|-------|---------|
| `im:message.group_msg` | Group messages | Receive all group messages (sensitive) |
| `im:message:readonly` | Message history | Query message history |
| `im:message:update` | Edit messages | Update sent message cards |
| `im:message:recall` | Recall messages | Recall sent messages |

> **💡 Tip**: Permissions require admin approval.

### Step 3: Configure Event Subscriptions ⚠️

> **This is the most commonly missed configuration!** If your bot can send but not receive messages, check this section.

In the app console → **Events & Callbacks**:

1. **Event Configuration Method**: Select `Long Connection` (recommended)
2. **Add Event Subscriptions**, enable the following:

| Event | Description |
|-------|-------------|
| `Receive Message v2.0` (`im.message.receive_v1`) | Required, receive user messages |
| `Message Read` (`im.message.message_read_v1`) | Optional, read receipts |
| `Bot Added to Group` (`im.chat.member.bot.added_v1`) | Optional, group management |
| `Bot Removed from Group` (`im.chat.member.bot.deleted_v1`) | Optional, group management |

3. Ensure event subscriptions are approved

### Step 4: Configure OpenClaw

Configure based on your version:

#### Feishu (China)

```bash
openclaw config set channels.openclaw-feishu.domain "feishu"
openclaw config set channels.openclaw-feishu.appId "cli_xxxxx"
openclaw config set channels.openclaw-feishu.appSecret "your_app_secret"
openclaw config set channels.openclaw-feishu.enabled true
openclaw restart
```

#### Lark (International)

```bash
openclaw config set channels.openclaw-feishu.domain "lark"
openclaw config set channels.openclaw-feishu.appId "cli_xxxxx"
openclaw config set channels.openclaw-feishu.appSecret "your_app_secret"
openclaw config set channels.openclaw-feishu.enabled true
openclaw restart
```

> **⚠️ Important**: The `domain` parameter must match your app version!
> - Feishu (China): `domain: "feishu"`
> - Lark (International): `domain: "lark"`

---

## ⚙️ Configuration Options

### Basic Configuration

```yaml
channels:
  feishu:
    enabled: true                    # Enable plugin
    appId: "cli_xxxxx"               # App ID
    appSecret: "your_secret"         # App Secret
    domain: "feishu"                 # 🌍 Version: "feishu" (China) or "lark" (International)
    connectionMode: "websocket"      # Connection mode: "websocket" or "webhook"
```

### Access Policies

```yaml
channels:
  feishu:
    # DM policy
    dmPolicy: "pairing"              # "pairing" (approval) | "open" (open) | "allowlist" (whitelist)
    
    # Group chat policy
    groupPolicy: "allowlist"         # "open" (open) | "allowlist" (whitelist) | "disabled" (disabled)
    
    # Require @mention in groups
    requireMention: true             # true (need @) | false (no @, requires sensitive permission)
```

### Advanced Options

```yaml
channels:
  feishu:
    # Render mode
    renderMode: "auto"               # "auto" (automatic) | "raw" (plain text) | "card" (card)
    
    # Media file limit
    mediaMaxMb: 30                   # Max file size (MB)
```

### 📝 Render Mode

| Mode | Effect | Use Case |
|------|--------|----------|
| `auto` | Use card for code blocks/tables, plain text otherwise | Default, smart choice |
| `raw` | Always plain text, tables to ASCII | Clean reading, avoid formatting |
| `card` | Always Markdown cards (syntax highlighting, tables, links) | Technical content, formatted display |

---

## 🔧 FAQ

### ❌ Bot Cannot Receive Messages

**Checklist:**

1. ✅ Did you configure **event subscriptions**? (See Step 3 above)
2. ✅ Is event configuration set to **long connection**?
3. ✅ Did you add the `im.message.receive_v1` event?
4. ✅ Are permissions approved?

### ❌ 403 Error When Sending Messages

Ensure `im:message:send_as_bot` permission is **requested and approved**.

### ❓ How to Clear Conversation History?

Send `/new` command in the chat.

### ❓ Why Not Streaming Output?

Feishu API has strict rate limits. Frequent message updates easily trigger throttling. v0.1.5 optimizes this: **messages sent immediately during generation** (not after completion), balancing stability and real-time delivery.

### ❌ Windows Install Error (`spawn npm ENOENT`)

If `openclaw plugins install` fails, use manual installation (see Method 3 above).

### ❓ Cannot Find Bot in Feishu/Lark

1. Ensure the app is **published** (at least to test version)
2. Search for the bot name in Feishu/Lark search box
3. Check if your account is within the app's **availability scope**

### ❓ Wrong Domain Error

If you see connection errors, verify:
- **Feishu (China)**: Must use `domain: "feishu"`
- **Lark (International)**: Must use `domain: "lark"`

The domain determines which API endpoints are used and cannot be mismatched.

---

## 📄 License

[MIT License](./LICENSE)

---

## 🔗 Links

- [OpenClaw Official Site](https://github.com/openclaw/openclaw)
- [Feishu Open Platform Docs](https://open.feishu.cn/document) (China)
- [Lark Open Platform Docs](https://open.larksuite.com/document) (International)
- [npm Package](https://www.npmjs.com/package/@overlink/openclaw-feishu)
- [GitHub Repository](https://github.com/overlink/openclaw-feishu)

---

<div align="center">
  <sub>Built with ❤️ for the OpenClaw community</sub>
</div>
