# Brand Switch Skill

自动化创建新品牌分支的工具。用于快速启动一个新的品牌网站项目。

## 功能

- 🔀 自动创建新Git分支
- 🎨 交互式收集品牌信息（名称、域名、邮箱、颜色等）
- 📝 自动更新品牌配置文件
- 🎨 生成品牌主题CSS
- 🌍 创建多语言品牌翻译文件
- ✅ 自动验证配置正确性

## 使用方法

### 方式1：通过Claude Code调用

在Claude Code中说：
```
使用brand-switch skill创建一个新品牌分支
```

或：
```
/brand-switch
```

### 方式2：直接调用（如果配置了slash command）

```bash
/brand-switch
```

## 工作流程

1. **收集品牌信息**
   - 品牌名称（如：VideoMagic Pro）
   - 域名（如：videomagic.ai）
   - 联系邮箱（如：hello@videomagic.ai）
   - 主题颜色（3个渐变色的OKLCH值）
   - 分支名称（默认：brand/{brand-slug}）

2. **创建分支**
   ```bash
   git checkout -b brand/videomagic
   ```

3. **更新配置文件**
   - `src/config/brand.config.ts`
   - `src/app/themes/{brand-slug}.css`
   - `src/i18n/brand/*.json`
   - `src/app/globals.css` (导入新主题)

4. **验证**
   - TypeScript类型检查
   - 文件完整性检查
   - 显示修改摘要

5. **提示下一步**
   - 更新logo资产（/public/logo.png等）
   - 完成翻译
   - 提交代码

## 前置条件

- 已实施品牌配置系统（见`docs/BRAND_MIGRATION.md`）
- 当前分支为`main`或`staging`（推荐）
- 工作目录干净（无未提交的更改）

## 配置项

可以通过环境变量或交互式问答提供：

- `BRAND_NAME`: 品牌名称
- `BRAND_DOMAIN`: 品牌域名
- `BRAND_EMAIL`: 联系邮箱
- `BRAND_THEME_ID`: 主题ID（默认：brand-slug）
- `GIT_BRANCH`: Git分支名称

## 示例

### 创建VideoMagic品牌

```
输入：使用brand-switch创建VideoMagic品牌

交互问答：
- 品牌名称：VideoMagic Pro
- 域名：videomagic.ai
- 邮箱：hello@videomagic.ai
- 主题色1 (from): oklch(0.75 0.20 280)  # 紫色
- 主题色2 (via): oklch(0.80 0.18 320)   # 粉紫
- 主题色3 (to): oklch(0.85 0.15 340)    # 粉色

输出：
✅ 创建分支: brand/videomagic
✅ 更新配置: src/config/brand.config.ts
✅ 创建主题: src/app/themes/videomagic.css
✅ 更新翻译: src/i18n/brand/*.json
✅ TypeScript验证通过

下一步:
1. 替换Logo: /public/logo.png, /public/favicon.svg
2. 更新翻译: src/i18n/brand/zh.json 等
3. 测试: pnpm dev
4. 提交: git commit -m "feat: add VideoMagic brand"
```

## 高级用法

### 仅更新配置（不创建分支）

```
使用brand-switch更新当前品牌配置，不创建新分支
```

### 使用现有颜色方案

```
使用brand-switch创建新品牌，使用Nano Banana的颜色方案
```

### 批量创建多个品牌

```
使用brand-switch批量创建以下品牌:
- VideoMagic (videomagic.ai)
- ImagePro (imagepro.com)
- AudioGen (audiogen.io)
```

## 故障排除

### 问题：Git分支已存在
**解决**：
```bash
git branch -D brand/videomagic
```
然后重新运行skill

### 问题：TypeScript类型错误
**解决**：检查brand.config.ts的配置是否符合BrandConfig类型定义

### 问题：主题颜色不显示
**解决**：确保在`src/app/globals.css`中导入了新主题CSS

## 参考文档

- 品牌迁移指南：`docs/BRAND_MIGRATION.md`
- 项目文档：`CLAUDE.md`
- 品牌配置：`src/config/brand.config.ts`
- 主题系统：`src/app/themes/`

## 更新历史

- 2025-11-30: 初始版本，支持基础品牌切换流程
