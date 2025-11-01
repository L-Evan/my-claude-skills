# Article Writer Skill - Shipany 博客写作与发布指南

## 概述

本技能提供了一套完整的博客文章写作、编辑和发布流程，基于 Shipany 项目的博客系统。支持多语言（中文/英文）、Markdown 格式、分类管理和自动化同步到生产数据库。

---

## 🚀 快速开始

### 方法一：使用后台管理界面（推荐）

```bash
# 1. 启动开发环境
pnpm dev

# 2. 访问后台管理页面
# http://localhost:3000/admin/posts

# 3. 创建或编辑文章
# 点击 "Add Post" 按钮开始写作

# 4. 同步到生产数据库
pnpm blog:sync
```

### 方法二：使用脚本创建示例文章

```bash
# 创建示例文章（包含分类和示例内容）
pnpm db:seed

# 查看数据库内容
pnpm db:studio
```

---

## 📝 文章写作流程

### 1. 准备工作

#### 检查开发环境配置

确保 `.env.development` 文件已配置：

```env
# 开发数据库
DATABASE_URL=postgresql://user:pass@localhost:5432/dev_db

# 项目信息
NEXT_PUBLIC_WEB_URL=http://localhost:3000
NEXT_PUBLIC_PROJECT_NAME="Your Project"
```

#### 检查生产环境配置

确保 `.env.production` 或 `.env.local` 已配置：

```env
# 生产数据库（必须与开发数据库不同！）
DATABASE_URL=postgresql://user:pass@prod-host:5432/prod_db

# 生产网站信息
NEXT_PUBLIC_WEB_URL=https://your-domain.com
NEXT_PUBLIC_PROJECT_NAME="Your Project"
```

### 2. 创建文章

#### 通过后台管理界面

访问 `http://localhost:3000/admin/posts`，点击 **"Add Post"** 按钮。

**必填字段：**
- **Title**: 文章标题
- **Slug**: URL 友好的标识符（如 `my-first-post`）
- **Description**: 文章摘要（显示在列表页）
- **Content**: 文章正文（Markdown 格式）
- **Locale**: 语言（`zh` 或 `en`）
- **Status**: 状态（`online`, `offline`, `draft`）
- **Category**: 分类

**可选字段：**
- **Cover URL**: 封面图片链接
- **Author Name**: 作者名称
- **Author Avatar URL**: 作者头像链接

#### 文章状态说明

| 状态 | 说明 | 可见性 |
|------|------|--------|
| `online` | 已发布 | 前台可见 |
| `offline` | 已下线 | 仅后台可见 |
| `draft` | 草稿 | 仅后台可见 |

#### 支持的 Markdown 格式

```markdown
# 一级标题

## 二级标题

### 三级标题

**粗体文本**

*斜体文本*

- 列表项 1
- 列表项 2

1. 有序列表项 1
2. 有序列表项 2

[链接文本](https://example.com)

![图片描述](https://example.com/image.jpg)

> 引用文本

`行内代码`

```markdown
代码块
```

| 表格 | 列 1 | 列 2 |
|------|------|------|
| 行 1 | 内容 | 内容 |
```

#### 前台访问路径

- **文章列表**: `http://localhost:3000/zh/posts`（中文）
- **文章列表**: `http://localhost:3000/en/posts`（英文）
- **文章详情**: `http://localhost:3000/zh/posts/{slug}`
- **后台管理**: `http://localhost:3000/admin/posts`

### 3. 编辑文章

在后台管理页面（`http://localhost:3000/admin/posts`）：

1. 找到要编辑的文章
2. 点击操作菜单（⋯）→ **Edit**
3. 修改内容后保存
4. 重新同步到生产数据库：`pnpm blog:sync`

---

## 🔄 数据库同步流程

### 同步原理

博客文章数据存储在 PostgreSQL 数据库的两个表中：
- **categories**: 分类表
- **posts**: 文章表

同步脚本通过 **UUID** 判断记录是否存在：
- ✅ UUID 存在 → 更新现有记录
- ➕ UUID 不存在 → 插入新记录
- ⏭️ 唯一约束冲突 → 跳过该记录

### 同步步骤

#### 1. 确认数据库配置

```bash
# 检查开发环境配置
cat .env.development | grep DATABASE_URL

# 检查生产环境配置
cat .env.production | grep DATABASE_URL
# 或
cat .env.local | grep DATABASE_URL
```

⚠️ **重要**: 开发和生产数据库 URL 必须不同！

#### 2. 执行同步

```bash
# 方法 1: 单独运行同步（推荐）
pnpm blog:sync

# 方法 2: 部署时自动同步
pnpm deploy:prod
# 选择 "y" 同步博客文章
```

#### 3. 同步过程示例

```bash
📝 准备同步博客数据到生产数据库...

⚠️  警告: 即将将本地文章同步到生产数据库！

请确认以下事项:
  1. 本地开发数据库包含要同步的文章
  2. 已备份生产数据库（防止误操作）
  3. 确认文章内容已审核完毕

确认继续同步博客文章? [y/N]: y

🔌 连接开发数据库...
🔌 连接生产数据库...

📂 同步分类...
   找到 1 个分类

   + 新增分类: AI 视频生成

📄 同步文章...
   找到 1 篇文章

   + 新增文章: VEO 3.1 vs Sora 2：下一代 AI 视频生成谁更强？

==================================================
📊 同步统计:
==================================================

分类:
  + 新增: 1
  ✓ 更新: 0
  - 跳过: 0

文章:
  + 新增: 1
  ✓ 更新: 0
  - 跳过: 0

==================================================

✅ 同步完成！
```

---

## 📊 数据库结构

### Posts 表结构

```typescript
{
  uuid: string           // 唯一标识（同步用主键）
  slug: string          // URL slug（如 "my-post"）
  title: string         // 标题
  description: string   // 摘要
  content: string       // 正文（Markdown）
  status: string        // 状态：online/offline/draft
  cover_url?: string    // 封面图片
  author_name?: string  // 作者名称
  author_avatar_url?: string // 作者头像
  locale: string        // 语言：zh/en
  category_uuid: string // 分类 UUID（外键）
  created_at: Date      // 创建时间
  updated_at: Date      // 更新时间
}
```

### Categories 表结构

```typescript
{
  uuid: string       // 唯一标识
  name: string       // 分类名称（唯一）
  title: string      // 显示标题
  description?: string // 描述
  status: string     // 状态：online/offline
  sort: number       // 排序
  created_at: Date   // 创建时间
  updated_at: Date   // 更新时间
}
```

---

## 🎨 文章写作最佳实践

### 1. 文章结构

```markdown
# 🎯 文章标题（包含 emoji）

---

简介：简要说明文章价值和主要内容（2-3 句话）

---

## 📋 目录（如适用）

- [第一部分](#part1)
- [第二部分](#part2)

---

## 🔥 第一部分

### 子标题

内容正文...

---

### 💡 提示框

> **重要提示**: 这是一个重要信息

---

## 🔥 第二部分

### 表格示例

| 功能 | 描述 | 状态 |
|------|------|------|
| 功能 1 | 描述 1 | ✅ |

---

## ✅ 总结

- 要点 1
- 要点 2

**下一步**: [行动号召]
```

### 2. 多语言支持

#### 中文文章

- Locale 设置为 `zh`
- 使用中文术语和文化表达
- 适合国内用户阅读习惯

```markdown
# 🎨 掌握 AI 视频创作：完整指南

随着 AI 技术的快速发展，视频创作不再是专业团队的专利...
```

#### 英文文章

- Locale 设置为 `en`
- 使用国际通用术语
- 适合全球用户阅读

```markdown
# 🎨 Mastering AI Video Creation: A Complete Guide

With the rapid development of AI technology, video creation is no longer exclusive to professional teams...
```

### 3. 视觉元素

#### 使用 Emoji

- 在标题前添加相关 emoji
- 在章节标题中使用 emoji
- 不要过度使用，保持专业性

#### 表格

用于对比、特性列表等：

```markdown
| 特性 | 传统视频 | AI 视频 |
|------|----------|---------|
| 时间成本 | 天/周 | 分钟/小时 |
| 技术门槛 | 高级 | 入门级 |
```

#### 代码块

```markdown
```javascript
// 代码示例
const prompt = "Create a video of a cat playing piano";
```
```

#### 提示框

```markdown
> **💡 提示**: 使用清晰的描述性提示词能获得更好的视频效果
```

---

## 🔧 高级功能

### 1. 分类管理

#### 创建分类

访问 `http://localhost:3000/admin/categories`：

1. 点击 **"Add Category"**
2. 填写分类信息：
   - **Name**: 分类标识符（唯一，如 `ai-video`）
   - **Title**: 显示标题（如 `AI 视频生成`）
   - **Description**: 分类描述
   - **Sort**: 排序顺序（数字越小越靠前）
3. 保存

#### 分类关联

创建文章时，选择相应的分类，系统会自动设置 `category_uuid` 字段。

### 2. 封面图片

#### 图片托管

推荐使用以下方式托管封面图片：

1. **CDN**: 上传到 Cloudflare R2、AWS S3 等
2. **图床**: 使用第三方图床服务
3. **本地存储**: 放在 `public/imgs/` 目录

#### 图片规范

- **格式**: JPG、PNG、WebP
- **尺寸**: 建议 1200x630（社交媒体分享最佳）
- **大小**: 建议 < 500KB

### 3. 作者信息

#### 字段说明

- **Author Name**: 作者姓名或昵称
- **Author Avatar URL**: 作者头像图片链接（建议 200x200）

#### 头像规范

- **格式**: JPG、PNG、WebP
- **尺寸**: 200x200 或 400x400
- **大小**: 建议 < 100KB

---

## 📱 文章优化

### 1. SEO 优化

#### 标题优化

- 包含关键词
- 长度 30-60 字符
- 避免重复

#### 描述优化

- 简洁概括文章核心
- 长度 120-160 字符
- 包含关键信息

#### Slug 优化

- 使用英文或拼音
- 包含关键词
- 避免特殊字符

```markdown
# 错误示例
slug: "post-123"
slug: "我的第一篇文章"

# 正确示例
slug: "ai-video-creation-guide"
slug: "ai-shipin-chuangzuo-zhinan"
```

### 2. 可读性优化

#### 段落长度

- 每段 3-5 行
- 避免过长段落

#### 标题层级

- 合理使用 H2、H3 标题
- 形成清晰的层次结构

#### 视觉元素

- 适当使用列表
- 使用表格展示对比信息
- 添加图片和代码块

---

## 🚀 部署与发布

### 完整部署流程

#### 方式 1：两步部署（推荐）

```bash
# 1. 推送代码到 staging（不触发部署）
pnpm push:staging "feat: 添加新的博客文章"

# 2. 部署到生产（包含博客同步）
pnpm deploy:prod

# 在部署流程中选择：
# 是否需要同步博客文章到生产环境? [y/N]: y
```

#### 方式 2：直接同步

```bash
# 在本地完成文章创作后，直接同步
pnpm blog:sync
```

### 数据库迁移

如果需要修改数据库结构：

```bash
# 1. 修改 schema
# 编辑 src/db/schema.ts

# 2. 生成迁移文件
pnpm db:generate

# 3. 应用迁移到开发数据库
pnpm db:push

# 4. 应用迁移到生产数据库
pnpm db:migrate:prod
```

---

## 🔍 故障排查

### 问题 1: 同步脚本失败

**错误信息**: `开发环境 DATABASE_URL 未配置`

**解决方法**:
```bash
# 检查 .env.development 文件
cat .env.development | grep DATABASE_URL

# 如果没有，创建一个
echo "DATABASE_URL=postgresql://..." > .env.development
```

### 问题 2: 生产数据库 URL 相同

**错误信息**: `⚠️ 开发和生产数据库 URL 相同！`

**解决方法**:
```bash
# 确保 .env.development 和 .env.production 使用不同数据库
# .env.development
DATABASE_URL=postgresql://user:pass@localhost:5432/dev_db

# .env.production
DATABASE_URL=postgresql://user:pass@prod-host:5432/prod_db
```

### 问题 3: 文章不同步

**可能原因**:
- UUID 冲突
- 外键约束错误

**解决方法**:
```bash
# 查看数据库内容
pnpm db:studio

# 检查文章和分类的 UUID 是否匹配
```

### 问题 4: 文章状态异常

**症状**: 文章在前台不显示

**解决方法**:
1. 检查文章状态是否为 `online`
2. 检查文章的 `locale` 是否正确
3. 检查文章的 `category_uuid` 是否存在
4. 检查文章的 `slug` 是否唯一

```sql
-- 查看所有 online 状态的文章
SELECT * FROM posts WHERE status = 'online';

-- 查看文章分类是否存在
SELECT * FROM categories WHERE uuid = '文章UUID';
```

### 问题 5: 唯一约束冲突

**错误信息**: `duplicate key value violates unique constraint`

**可能原因**:
- 同一 slug 在同一语言下已存在

**解决方法**:
```bash
# 修改文章的 slug
# 例如：ai-video-guide-1, ai-video-guide-2
```

---

## 📋 检查清单

### 发布前检查

- [ ] 文章标题简洁明了，包含关键词
- [ ] Slug 格式正确（英文，无特殊字符）
- [ ] 描述信息完整（120-160 字符）
- [ ] 内容格式正确（Markdown）
- [ ] 状态设置为 `online`
- [ ] 语言设置正确（zh/en）
- [ ] 分类已创建且关联正确
- [ ] 封面图片链接有效
- [ ] 本地预览正常

### 同步前检查

- [ ] 开发和生产数据库 URL 不同
- [ ] 生产环境变量已配置
- [ ] 文章内容已审核完毕
- [ ] 生产数据库已备份（重要）
- [ ] 网络连接正常

### 部署后验证

- [ ] 文章列表页正常访问
- [ ] 文章详情页正常显示
- [ ] 图片加载正常
- [ ] 文章状态正确
- [ ] SEO 信息正确（title、description）

---

## 💡 进阶技巧

### 1. 批量操作

如果需要批量创建文章，可以使用脚本：

```typescript
// src/scripts/insert-halloween-posts.ts
// 参考现有脚本创建批量插入脚本
```

### 2. 数据库可视化

```bash
# 打开 Drizzle Studio
pnpm db:studio

# 可以可视化查看和编辑：
# - 所有文章
# - 所有分类
# - 数据关系
```

### 3. 性能优化

- 保持文章内容合理长度（建议 < 10,000 字）
- 图片使用适当格式和大小
- 定期清理离线文章

### 4. 数据备份

```bash
# 备份生产数据库
pg_dump -h prod-host -U user -d prod_db -f backup_$(date +%Y%m%d_%H%M%S).sql

# 仅备份博客相关表
pg_dump -h prod-host -U user -d prod_db -t posts -t categories -f backup_blog.sql
```

---

## 📚 相关文档

- [博客同步指南](../../docs/博客同步指南.md) - 详细的同步流程说明
- [BLOG_DEPLOYMENT.md](../../docs/BLOG_DEPLOYMENT.md) - 博客功能生产环境部署
- [DEPLOYMENT.md](../../docs/部署文档.md) - 完整部署流程
- [ENV_CHECKLIST.md](../../docs/环境变量配置清单.md) - 环境变量配置
- [CLAUDE.md](../../CLAUDE.md) - 项目开发指南

---

## 🎯 快速参考

### 常用命令

```bash
# 开发
pnpm dev                    # 启动开发服务器
pnpm db:studio             # 打开数据库 GUI

# 数据库
pnpm db:seed               # 创建示例文章
pnpm db:generate           # 生成迁移文件
pnpm db:migrate            # 应用迁移
pnpm db:push               # 推送 schema（开发环境）

# 博客同步
pnpm blog:sync             # 同步博客到生产

# 部署
pnpm push:staging "msg"    # 推送到 staging
pnpm deploy:prod           # 部署到生产
```

### 重要路径

```
开发环境：
  前台: http://localhost:3000/zh/posts
  后台: http://localhost:3000/admin/posts

生产环境：
  前台: https://your-domain.com/zh/posts
  后台: https://your-domain.com/admin/posts
```

### 数据库操作

```bash
# 查看所有文章
SELECT * FROM posts ORDER BY created_at DESC;

# 查看所有分类
SELECT * FROM categories ORDER BY sort;

# 查看某篇文章详情
SELECT * FROM posts WHERE slug = 'your-slug';
```

---

## ✅ 最佳实践总结

1. **开发环境使用后台管理界面** - 更直观、更高效
2. **使用 UUID 进行同步** - 保证数据一致性
3. **先同步分类再同步文章** - 保证外键关系
4. **定期备份生产数据库** - 防止数据丢失
5. **使用语义化的 Slug** - 有助于 SEO
6. **保持开发和生产数据库分离** - 避免误操作
7. **文章内容格式规范** - 提高可读性
8. **发布前充分预览** - 确保质量

---

**💡 提示**: 如遇到问题，请先查看 [博客同步指南](../../docs/博客同步指南.md) 和 [故障排查](#故障排查) 章节。