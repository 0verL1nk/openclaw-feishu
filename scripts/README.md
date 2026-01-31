# 发布脚本使用说明

本目录包含两个发布脚本，用于自动化发布流程。

## 📜 脚本说明

### 1. `publish.sh` - 完整交互式发布脚本

**功能：**
- ✅ 检查未提交的改动
- ✅ 交互式选择版本升级类型（patch/minor/major/自定义）
- ✅ 自动更新 README 中的版本号
- ✅ 运行类型检查
- ✅ 输入 changelog
- ✅ Git 提交并推送
- ✅ 发布到 npm
- ✅ 触发 npmmirror 同步
- ✅ 可选创建 Git Tag

**使用方法：**

```bash
# 在项目根目录执行
./scripts/publish.sh
```

**交互流程：**

1. 显示当前版本
2. 检查未提交改动（如有会询问是否继续）
3. 选择版本升级类型：
   - `1` - patch (0.1.5 -> 0.1.6)
   - `2` - minor (0.1.5 -> 0.2.0)
   - `3` - major (0.1.5 -> 1.0.0)
   - `4` - 自定义版本号
   - `5` - 跳过升级（使用当前版本）
4. 输入改动说明（changelog）
5. 自动执行提交、推送、发布
6. 询问是否发布到 npm
7. 询问是否创建 Git Tag

---

### 2. `quick-publish.sh` - 快速发布脚本（无交互）

**功能：**
- 🚀 一键完成发布流程
- 🚀 默认使用 patch 版本升级
- 🚀 自动提交、发布、同步镜像

**使用方法：**

```bash
# Patch 升级（默认）
./scripts/quick-publish.sh

# Minor 升级
./scripts/quick-publish.sh minor

# Major 升级
./scripts/quick-publish.sh major
```

**适用场景：**
- 快速修复 bug 并发布
- 已确认所有改动，无需交互确认
- CI/CD 自动化流程

---

## 🎯 推荐使用场景

| 场景 | 推荐脚本 | 原因 |
|------|---------|------|
| 首次发布 | `publish.sh` | 需要填写详细的 changelog |
| 重大版本更新 | `publish.sh` | 需要创建 Git Tag |
| 快速修复 bug | `quick-publish.sh` | 省时高效 |
| 小改动发布 | `quick-publish.sh` | 无需繁琐交互 |
| 不确定改动内容 | `publish.sh` | 交互式确认每一步 |

---

## ⚙️ 发布前准备

1. **确保已登录 npm**：
   ```bash
   npm whoami  # 应显示: overlink
   ```

2. **确保 Git 远程仓库已配置**：
   ```bash
   git remote -v
   ```

3. **确保有 npm 发布权限**（如需要 2FA，请配置 token）

---

## 🔧 手动发布（不使用脚本）

如果脚本出现问题，可以手动执行：

```bash
# 1. 升级版本
npm version patch  # 或 minor / major

# 2. 更新 README
NEW_VERSION=$(node -p "require('./package.json').version")
sed -i "s/openclaw-feishu-[0-9]\+\.[0-9]\+\.[0-9]\+/openclaw-feishu-${NEW_VERSION}/g" README.md README_EN.md

# 3. 提交
git add package.json README.md README_EN.md
git commit -m "chore: release v${NEW_VERSION}"
git push

# 4. 发布到 npm
npm publish --access public

# 5. 同步镜像
curl -X PUT https://registry.npmmirror.com/@overlink/openclaw-feishu/sync
```

---

## 📋 常见问题

### 1. 脚本提示 "Permission denied"

```bash
chmod +x scripts/publish.sh
chmod +x scripts/quick-publish.sh
```

### 2. npm 发布失败（403 错误）

检查是否需要 2FA 验证：
```bash
npm publish --otp 你的6位验证码
```

或使用 automation token（见主 README）。

### 3. Git 推送失败

确保有远程仓库推送权限：
```bash
git remote set-url origin git@github.com:overlink/openclaw-feishu.git
```

### 4. npmmirror 同步失败

手动访问触发：
```bash
curl -X PUT https://registry.npmmirror.com/@overlink/openclaw-feishu/sync
```

或访问网页：https://npmmirror.com/package/@overlink/openclaw-feishu

---

## 📝 版本号规范

遵循 [Semantic Versioning](https://semver.org/lang/zh-CN/)：

- **MAJOR (1.0.0)**: 不兼容的 API 变更
- **MINOR (0.1.0)**: 向下兼容的功能性新增
- **PATCH (0.0.1)**: 向下兼容的问题修正

**示例：**
- 修复 bug: `0.1.5 -> 0.1.6` (patch)
- 新增功能: `0.1.5 -> 0.2.0` (minor)
- 重大重构: `0.1.5 -> 1.0.0` (major)
