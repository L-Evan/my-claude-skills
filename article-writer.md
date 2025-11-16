# Article Writer Skill

> 🤖 使用 AI + MCP 工具自动化创作、优化和发布博客文章的完整工作流

## 核心理念

这个 skill 利用 Claude 的能力和 MCP 工具，实现文章创作的全自动化：
1. **AI 生成内容** - Claude 根据主题生成高质量文章
2. **智能优化** - 自动优化 SEO、结构、格式
3. **数据库写入** - 使用工具直接写入开发数据库
4. **一键发布** - 同步到生产环境

---

## 🚀 推荐工作流（AI 驱动）

### 方法 1：完全自动化（推荐）⭐

**一句话生成文章并发布：**

```
我需要写一篇关于「Next.js 15 性能优化技巧」的中文博客文章
```

**Claude 会自动执行：**
1. ✅ 生成完整的 Markdown 文章内容
2. ✅ 优化 SEO（标题、描述、关键词）
3. ✅ 创建 TypeScript 脚本插入数据库
4. ✅ 执行脚本写入开发数据库
5. ✅ 本地预览验证
6. ✅ 提示是否同步到生产

---

### 方法 2：分步引导（适合精细控制）

#### 第 1 步：生成文章内容

```
请帮我写一篇关于「如何部署 Next.js 应用到生产环境」的文章：
- 语言：中文
- 目标读者：中级开发者
- 字数：1500-2000字
- 包含代码示例
- SEO 友好
```

**Claude 会生成：**
- 完整的 Markdown 内容
- 优化的标题和描述
- 合适的 slug

#### 第 2 步：优化文章

```
请优化这篇文章的 SEO：
- 添加关键词
- 优化标题和描述
- 改进结构层次
- 添加内部链接
```

#### 第 3 步：写入数据库

```
请将这篇文章写入开发数据库：
- 标题：[生成的标题]
- slug：deployment-nextjs-production
- 分类：ai-tech
- 语言：zh
```

**Claude 会：**
1. 创建 TypeScript 脚本（`src/scripts/create-article-[timestamp].ts`）
2. 自动执行脚本写入数据库
3. 验证插入结果

#### 第 4 步：预览和发布

```
请启动开发服务器让我预览文章
```

**验证无误后：**
```
确认无误，请同步到生产环境
```

---

## 📋 数据库结构（posts 表）

```typescript
{
  uuid: string,              // 自动生成：post-{slug}-{timestamp}
  slug: string,              // URL 标识符
  title: string,             // 文章标题
  description: string,       // SEO 描述（120-160字符）
  content: string,           // Markdown 正文
  status: 'online' | 'draft', // 发布状态
  locale: 'zh' | 'en',       // 语言
  category_uuid: string,     // 分类UUID
  cover_url?: string,        // 封面图（默认：/imgs/blog/default.jpg）
  author_name?: string,      // 作者（默认：trygempix2.pro）
  author_avatar_url?: string, // 头像（默认：/imgs/users/1.png）
  created_at: timestamp,     // 创建时间
  updated_at: timestamp      // 更新时间
}
```

---

## 🎯 Claude 自动化执行流程

### 1. 内容生成阶段

**Claude 内部思考：**
```
1. 分析用户需求（主题、受众、语言、长度）
2. 研究相关资料（如需要，使用 WebSearch）
3. 生成文章大纲
4. 撰写完整内容
5. 优化格式和结构
```

**输出示例：**
```markdown
# Next.js 15 性能优化完全指南

## 概述
Next.js 15 带来了多项性能改进...

## 主要优化技巧

### 1. 使用 Turbopack
...

### 2. 优化图片加载
...

## 最佳实践
...
```

---

### 2. 数据库写入阶段

**Claude 自动创建脚本：**

```typescript
// src/scripts/create-article-1699123456.ts
import postgres from 'postgres';

const DATABASE_URL = process.env.DATABASE_URL;
const sql = postgres(DATABASE_URL!);

async function createArticle() {
  const article = {
    uuid: 'post-nextjs-performance-1699123456',
    slug: 'nextjs-15-performance-optimization',
    title: 'Next.js 15 性能优化完全指南',
    description: '深入解析 Next.js 15 的性能优化技巧，包括 Turbopack、图片优化、代码分割等实战技术，帮助你构建更快的 Web 应用。',
    content: `# Next.js 15 性能优化完全指南\n\n...`,
    locale: 'zh',
    category_uuid: 'ai-tech-category',
    status: 'online',
    cover_url: '/imgs/blog/default.jpg',
    author_name: 'trygempix2.pro',
    author_avatar_url: '/imgs/users/1.png',
  };

  await sql`
    INSERT INTO posts (
      uuid, slug, title, description, content,
      created_at, updated_at, status,
      cover_url, author_name, author_avatar_url,
      locale, category_uuid
    ) VALUES (
      ${article.uuid}, ${article.slug}, ${article.title},
      ${article.description}, ${article.content},
      NOW(), NOW(), ${article.status},
      ${article.cover_url}, ${article.author_name},
      ${article.author_avatar_url}, ${article.locale},
      ${article.category_uuid}
    )
    ON CONFLICT (uuid) DO NOTHING
  `;

  console.log('✅ 文章创建成功！');
}

createArticle()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error('❌ 错误:', error);
    process.exit(1);
  });
```

**Claude 自动执行：**
```bash
npx tsx src/scripts/create-article-1699123456.ts
```

---

### 3. 验证和发布阶段

**Claude 自动验证：**
```bash
# 查询数据库确认插入成功
psql $DATABASE_URL -c "SELECT title, slug, locale FROM posts WHERE slug='nextjs-15-performance-optimization'"
```

**提示用户预览：**
```
✅ 文章已写入开发数据库！

📝 文章信息：
- 标题：Next.js 15 性能优化完全指南
- Slug：nextjs-15-performance-optimization
- 语言：中文
- 分类：ai-tech

🌐 本地预览：
http://localhost:3000/zh/posts/nextjs-15-performance-optimization

💡 下一步操作：
1. 运行 'pnpm dev' 查看预览
2. 确认无误后运行 'pnpm blog:sync' 同步到生产
```

---

## 🛠️ 手动方法（备用）

### 方法1：后台界面写作

1. **启动开发服务器**
```bash
pnpm dev
```

2. **访问后台管理**
- 打开浏览器访问 `http://localhost:3000/en/admin/posts`
- 或者使用 Drizzle Studio: `pnpm db:studio`

3. **创建文章**
- 点击"Add New Post"
- 填写表单并保存

### 方法2：手动编写脚本

1. **创建脚本**
```bash
cat > src/scripts/create-your-posts.ts << 'EOF'
import postgres from 'postgres';
import { randomUUID } from 'crypto';

const DATABASE_URL = process.env.DATABASE_URL;

if (!DATABASE_URL) {
  throw new Error('DATABASE_URL is not set');
}

const sql = postgres(DATABASE_URL);

async function createArticles() {
  const articles = [
    {
      title: 'Your Article Title',
      slug: 'your-article-slug',
      description: 'Short description for SEO',
      content: '# Your Article Content\n\nMarkdown content here...',
      locale: 'zh',
      category_uuid: 'ai-tech-category' // or your category UUID
    }
  ];

  for (const article of articles) {
    const uuid = `post-${article.slug}-${Date.now()}`;
    await sql`
      INSERT INTO posts (
        uuid, slug, title, description, content,
        created_at, updated_at, status,
        cover_url, author_name, author_avatar_url,
        locale, category_uuid
      ) VALUES (
        ${uuid},
        ${article.slug},
        ${article.title},
        ${article.description},
        ${article.content},
        NOW(),
        NOW(),
        'online',
        '/imgs/blog/default.jpg',
        'trygempix2.pro',
        '/imgs/users/1.png',
        ${article.locale},
        ${article.category_uuid}
      )
      ON CONFLICT (uuid) DO NOTHING
    `;
    console.log(`✅ Created article: ${article.title}`);
  }
}

createArticles()
  .then(() => {
    console.log('🎉 All articles created successfully!');
    process.exit(0);
  })
  .catch((error) => {
    console.error('❌ Error:', error);
    process.exit(1);
  });
EOF
```

2. **执行脚本**
```bash
npx tsx src/scripts/create-your-posts.ts
```

3. **同步到生产**
```bash
pnpm blog:sync
```

---

## 💬 实际使用示例

### 示例 1：快速生成技术文章

**你的指令：**
```
我需要写一篇关于「Vercel 部署最佳实践」的中文博客文章，
面向中级开发者，包含实用代码示例。
```

**Claude 的执行过程：**

1. **生成文章内容**
```markdown
# Vercel 部署最佳实践：从开发到生产的完整指南

## 概述
本文深入解析 Vercel 部署的最佳实践，帮助你构建高性能、可靠的生产环境...

## 环境变量管理
### 本地开发配置
...代码示例...

## 自动化部署流程
### 配置 GitHub Actions
...

[完整内容 1500+ 字]
```

2. **创建数据库脚本**
```typescript
// 自动生成 src/scripts/create-article-1730445678.ts
const article = {
  uuid: 'post-vercel-best-practices-1730445678',
  slug: 'vercel-deployment-best-practices',
  title: 'Vercel 部署最佳实践：从开发到生产的完整指南',
  description: '深入解析 Vercel 部署的最佳实践，涵盖环境变量管理、自动化流程、性能优化等核心技术，助你打造高性能生产环境。',
  content: '...[完整 Markdown 内容]...',
  locale: 'zh',
  category_uuid: 'ai-tech-category',
  status: 'online',
  // ... 其他字段
};
```

3. **执行写入**
```bash
✅ 创建脚本: src/scripts/create-article-1730445678.ts
✅ 执行脚本写入数据库
✅ 验证插入成功
```

4. **提供预览链接**
```
📝 文章已创建！

🌐 本地预览：
http://localhost:3000/zh/posts/vercel-deployment-best-practices

💡 运行 'pnpm dev' 查看效果
```

---

### 示例 2：优化现有文章

**你的指令：**
```
请帮我优化 slug 为 'nextjs-tutorial' 的文章的 SEO
```

**Claude 的执行过程：**

1. **读取现有文章**
```bash
psql $DATABASE_URL -c "SELECT * FROM posts WHERE slug='nextjs-tutorial'"
```

2. **分析并优化**
- 优化标题（添加关键词）
- 改进描述（120-160字符，包含核心关键词）
- 调整内容结构（H2/H3层次）
- 添加内部链接

3. **更新数据库**
```typescript
// 创建更新脚本
await sql`
  UPDATE posts
  SET
    title = '新优化的标题',
    description = '优化后的描述',
    content = '优化后的内容',
    updated_at = NOW()
  WHERE slug = 'nextjs-tutorial'
`;
```

---

### 示例 3：批量生成系列文章

**你的指令：**
```
帮我生成一个「AI 视频生成技术」系列文章（共3篇）：
1. 入门基础
2. 进阶技巧
3. 生产实战
```

**Claude 的执行过程：**

1. **规划系列结构**
```
✓ 确定整体框架
✓ 设计文章关联
✓ 优化 SEO 关键词分布
```

2. **批量生成内容**
```typescript
const articles = [
  {
    title: 'AI 视频生成入门：从零开始的完整指南',
    slug: 'ai-video-generation-basics',
    // ...
  },
  {
    title: 'AI 视频生成进阶：提升质量的 10 个技巧',
    slug: 'ai-video-generation-advanced',
    // ...
  },
  {
    title: 'AI 视频生成实战：生产环境最佳实践',
    slug: 'ai-video-generation-production',
    // ...
  }
];
```

3. **添加系列内部链接**
- 在每篇文章末尾添加"系列文章"导航
- 互相引用相关内容

---

## 📊 Claude 内置的优化规则

### SEO 优化自动检查

Claude 在生成文章时会自动：

1. **标题优化**
   - ✅ 长度控制在 6-12 个字
   - ✅ 包含核心关键词
   - ✅ 吸引点击（数字、疑问、对比）

2. **描述优化**
   - ✅ 120-160 字符
   - ✅ 包含 2-3 个关键词
   - ✅ 提供明确价值主张

3. **内容结构**
   - ✅ 清晰的 H1/H2/H3 层次
   - ✅ 每段 3-5 句话
   - ✅ 使用列表和表格提升可读性
   - ✅ 代码示例格式规范

4. **技术 SEO**
   - ✅ 语义化 Markdown
   - ✅ 图片 alt 描述
   - ✅ 内部链接优化

---

## 🔄 完整工作流程（从创作到发布）

```
┌─────────────────────────────────────────────┐
│  第 1 步：对话式创作                        │
│  「写一篇关于 XXX 的文章」                  │
└──────────────┬──────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────┐
│  第 2 步：Claude 生成内容                   │
│  ✓ 分析需求                                 │
│  ✓ 研究资料（WebSearch）                    │
│  ✓ 生成大纲                                 │
│  ✓ 撰写正文                                 │
│  ✓ 优化 SEO                                 │
└──────────────┬──────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────┐
│  第 3 步：自动写入数据库                    │
│  ✓ 创建 TypeScript 脚本                     │
│  ✓ 执行脚本插入数据                         │
│  ✓ 验证插入结果                             │
└──────────────┬──────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────┐
│  第 4 步：本地预览（可选）                  │
│  运行：pnpm dev                             │
│  访问：http://localhost:3000/zh/posts/...   │
└──────────────┬──────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────┐
│  第 5 步：同步到生产                        │
│  运行：pnpm blog:sync                       │
│  或：pnpm deploy:prod（含代码部署）         │
└─────────────────────────────────────────────┘
```

---

## 🎯 使用场景

### 场景 1：日常技术博客更新

**需求：** 每周发布 2-3 篇技术文章

**工作流：**
```
周一：「写一篇关于 TypeScript 5.0 新特性的文章」
周三：「写一篇 React Server Components 实战教程」
周五：「写一篇 Vercel Edge Functions 使用指南」
```

**耗时：** 每篇约 5-10 分钟（AI 生成 + 自动入库）

---

### 场景 2：产品发布配套文档

**需求：** 新功能上线需要配套博客文章

**工作流：**
```
「我们刚上线了 AI 视频生成功能，帮我写一篇发布公告：
- 介绍新功能亮点
- 提供使用教程
- 包含定价信息
- 添加演示视频链接」
```

**Claude 输出：**
- 结构化的产品介绍文章
- 自动优化营销文案
- 包含 CTA (Call-to-Action)

---

### 场景 3：SEO 内容矩阵

**需求：** 围绕核心关键词创建内容集群

**工作流：**
```
「帮我围绕「AI 视频生成」这个核心关键词，
创建一个内容矩阵（5篇文章）：
- 长尾关键词覆盖
- 不同难度层级
- 互相链接形成集群」
```

**Claude 输出：**
1. AI 视频生成是什么？（入门）
2. 10 个最佳 AI 视频生成工具对比（横向）
3. AI 视频生成完整教程（深度）
4. AI 视频生成常见问题解答（FAQ）
5. AI 视频生成未来趋势分析（前瞻）

---

### 场景 4：内容翻译和本地化

**需求：** 将中文文章翻译成英文

**工作流：**
```
「将 slug 为 'ai-video-basics' 的中文文章翻译成英文版本」
```

**Claude 执行：**
1. 读取中文原文
2. 翻译内容（保持技术准确性）
3. 调整文化差异和表达习惯
4. 创建新的英文文章记录（`locale: 'en'`）

---

## 🛠️ 高级技巧

### 技巧 1：使用 WebSearch 增强内容质量

**指令：**
```
「写一篇关于 Next.js 15 新特性的文章，
请先搜索最新的官方文档和社区反馈」
```

**Claude 会：**
1. 使用 WebSearch 查找最新资料
2. 综合官方文档和社区观点
3. 生成基于最新信息的文章

---

### 技巧 2：结合项目代码生成教程

**指令：**
```
「基于 src/app/api/demo 目录下的代码，
写一篇 API 开发教程」
```

**Claude 会：**
1. 分析项目代码结构
2. 提取关键技术点
3. 生成实战教程（引用真实代码）

---

### 技巧 3：批量更新旧文章

**指令：**
```
「检查所有中文技术文章，更新过时的代码示例和最佳实践」
```

**Claude 会：**
1. 查询所有技术文章
2. 分析代码时效性
3. 逐篇更新并标记修改

---

## ✅ 质量检查清单

Claude 在发布前会自动检查：

### 内容质量
- [ ] 标题吸引力（6-12 字）
- [ ] 描述准确性（120-160 字符）
- [ ] 内容完整性（≥800 字）
- [ ] 代码示例正确性
- [ ] 链接有效性

### SEO 优化
- [ ] 核心关键词密度（1-2%）
- [ ] H1/H2/H3 层次清晰
- [ ] 图片 alt 标签
- [ ] 内部链接（至少 2 个）
- [ ] 元数据完整

### 技术规范
- [ ] Markdown 语法正确
- [ ] 代码块语言标注
- [ ] 表格格式规范
- [ ] 特殊字符转义

---

## 📦 数据库同步机制

### UUID匹配

同步脚本使用以下逻辑：

```typescript
// 从本地数据库读取
const localPosts = await sql`
  SELECT * FROM posts
  WHERE locale = ${targetLocale}
`;

// 匹配策略
for (const localPost of localPosts) {
  const existingPost = await sql`
    SELECT * FROM posts
    WHERE slug = ${localPost.slug}
      AND locale = ${localPost.locale}
  `;

  if (existingPost.length === 0) {
    // 新文章 → 插入
  } else {
    // 现有文章 → 检查更新
    if (hasChanges(localPost, existingPost[0])) {
      // 更新内容
    }
  }
}
```

### 增量更新

- **新增文章**：自动检测并插入
- **更新文章**：比较updated_at字段
- **删除文章**：需要手动从生产环境删除

## 数据库结构

### posts表

| 字段 | 类型 | 描述 | 必需 |
|------|------|------|------|
| uuid | varchar | 主键UUID | ✅ |
| slug | varchar | URL友好标识符 | ✅ |
| title | varchar | 文章标题 | ✅ |
| description | varchar | 简短描述 | ✅ |
| content | text | Markdown正文 | ✅ |
| status | enum | online/draft | ✅ |
| locale | enum | zh/en | ✅ |
| category_uuid | varchar | 分类UUID | ✅ |
| cover_url | varchar | 封面图片 | ❌ |
| author_name | varchar | 作者名 | ❌ |
| author_avatar_url | varchar | 头像URL | ❌ |
| created_at | timestamp | 创建时间 | ✅ |
| updated_at | timestamp | 更新时间 | ✅ |

### categories表

| 字段 | 类型 | 描述 |
|------|------|------|
| uuid | varchar | 分类UUID |
| name | varchar | 标识符（英文） |
| title | varchar | 显示名称 |
| description | varchar | 分类描述 |
| status | enum | online/draft |
| sort | integer | 排序权重 |

## 写作最佳实践

### 1. 内容策略

**标题优化**
- 清晰简洁：6-12个字最佳
- 包含关键词：SEO友好
- 吸引点击：数字、疑问、对比

**描述优化**
- 120-160字符
- 包含核心关键词
- 引起兴趣和点击欲望

**内容结构**
- 使用H2/H3标题组织内容
- 每段3-5句话
- 列表和表格提高可读性
- 包含相关图片

### 2. Markdown格式

**基础语法**
```markdown
# H1标题
## H2标题
### H3标题

**粗体文本**
*斜体文本*

[链接文本](URL)

![图片描述](图片URL)

- 列表项1
- 列表项2

1. 有序列表项1
2. 有序列表项2

> 引用内容

`代码片段`
```

**高级格式**
```markdown
表格：
| 列1 | 列2 | 列3 |
|-----|-----|-----|
| 数据1 | 数据2 | 数据3 |

代码块：
```typescript
const message = 'Hello World';
```

分割线：
---
```

### 3. SEO优化

**关键词研究**
- 使用工具：Google Keyword Planner, Ahrefs
- 长尾关键词：更容易排名
- 语义相关词：提高语义相关性

**页面优化**
- 标题：包含主关键词
- URL：简洁友好
- 图片：alt标签描述
- 内部链接：链接到相关文章

**技术SEO**
- 页面速度：< 3秒加载
- 移动友好：响应式设计
- 结构化数据：JSON-LD标记

### 4. 图片使用

**封面图片**
- 尺寸：1200x630px（16:9）
- 格式：JPG或WebP
- 文件大小：< 500KB
- 内容：与文章主题相关

**文章内图片**
- 尺寸：根据需要调整
- 格式：WebP优先
- 压缩：保持质量的同时减小文件

**图片存储**
```typescript
// 推荐存储路径
cover_url: '/imgs/blog/your-article-slug.jpg'
author_avatar_url: '/imgs/users/1.png'
```

## 高级功能

### 1. 分类管理

**创建分类**
```sql
INSERT INTO categories (uuid, name, title, description, status, sort)
VALUES (
  'your-category-uuid',
  'category-name',
  '分类显示名称',
  '分类描述',
  'online',
  1
);
```

**分配分类**
- 技术文章 → AI技术
- 产品更新 → 产品动态
- 用户案例 → 成功案例

### 2. 作者信息

**设置默认作者**
```typescript
author_name: 'trygempix2.pro',
author_avatar_url: '/imgs/users/1.png'
```

**多作者支持**
- 为每个作者创建头像图片
- 在内容中提到作者
- 支持作者页面链接

### 3. 社交媒体优化

**Open Graph标签**
```html
<meta property="og:title" content="文章标题">
<meta property="og:description" content="文章描述">
<meta property="og:image" content="封面图片URL">
<meta property="og:url" content="文章URL">
```

**Twitter Card**
```html
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="文章标题">
<meta name="twitter:description" content="文章描述">
<meta name="twitter:image" content="封面图片URL">
```

### 4. 内容更新

**增量更新流程**
```bash
# 1. 在本地修改内容
# 2. 更新数据库
# 3. 同步到生产
pnpm blog:sync
```

**版本控制**
- 记录重要更改
- 保持内容新鲜度
- 定期审核准确性

## 部署发布流程

### 开发环境

1. **创建文章**
```bash
# 使用后台或脚本创建
```

2. **本地预览**
```bash
pnpm dev
# 访问 http://localhost:3000/[locale]/posts/[slug]
```

3. **数据库验证**
```bash
pnpm db:studio
# 检查posts表中的记录
```

### 生产部署

1. **同步脚本**
```bash
# 自动从本地同步到生产
pnpm blog:sync
```

2. **验证发布**
```bash
# 检查生产环境
curl https://yourdomain.com/zh/posts/your-slug
```

3. **监控检查**
- 访问速度和可用性
- SEO索引状态
- 用户访问和反馈

### 持续优化

1. **性能监控**
   - Google Analytics
   - PageSpeed Insights
   - Core Web Vitals

2. **内容分析**
   - 阅读量统计
   - 跳出率分析
   - 用户停留时间

3. **定期更新**
   - 每月审查内容准确性
   - 更新过期信息
   - 添加新相关内容

## 故障排查

### 常见问题

**问题1：文章不显示**
```bash
# 检查步骤
1. 确认数据库中有记录
2. 检查status字段为'online'
3. 验证slug格式正确
4. 重启开发服务器
```

**问题2：同步失败**
```bash
# 检查DATABASE_URL
echo $DATABASE_URL

# 检查网络连接
ping your-db-host

# 检查权限
psql $DATABASE_URL -c "SELECT * FROM posts LIMIT 1;"
```

**问题3：图片不显示**
```bash
# 验证图片路径
ls -la public/imgs/blog/

# 检查图片URL格式
# 应该是 /imgs/... 而不是 ./imgs/...
```

**问题4：MDX文档构建失败**
```bash
# 检查frontmatter格式
cat content/docs/your-file.mdx
# 确保包含必需的title和description字段

# 运行构建测试
pnpm build
```

### 数据库问题

**连接错误**
```typescript
// 检查.env文件
DATABASE_URL=postgresql://user:pass@host:port/db

// 测试连接
npx tsx -e "import postgres from 'postgres'; console.log(postgres(process.env.DATABASE_URL))"
```

**迁移问题**
```bash
# 重置数据库
pnpm db:push --force

# 重新生成迁移
pnpm db:generate
```

### 同步问题

**本地与生产不同步**
```bash
# 手动运行同步
pnpm blog:sync

# 检查同步日志
# 查看输出中的统计信息
```

**内容冲突**
```sql
-- 查看重复文章
SELECT slug, COUNT(*)
FROM posts
GROUP BY slug
HAVING COUNT(*) > 1;
```

## 检查清单

### 写前检查
- [ ] 确定主题和目标受众
- [ ] 准备封面图片（1200x630px）
- [ ] 研究关键词和SEO策略
- [ ] 创建文章大纲

### 写作检查
- [ ] 标题简洁明确（6-12字）
- [ ] 描述吸引人（120-160字符）
- [ ] 使用标题层次结构（H1/H2/H3）
- [ ] 包含内部和外部链接
- [ ] 添加相关图片
- [ ] 使用列表和表格

### 技术检查
- [ ] slug格式正确（URL友好）
- [ ] locale设置正确（zh/en）
- [ ] category_uuid存在
- [ ] cover_url可访问
- [ ] Markdown格式正确
- [ ] 字符编码正确

### 发布检查
- [ ] 本地预览正常
- [ ] 数据库记录正确
- [ ] 同步到生产成功
- [ ] 生产环境可访问
- [ ] SEO元数据正确
- [ ] 社交分享正常

### 发布后检查
- [ ] 监控页面加载速度
- [ ] 检查搜索引擎收录
- [ ] 跟踪用户互动数据
- [ ] 收集用户反馈
- [ ] 计划后续更新

## 进阶技巧

### 1. 批量操作

**批量创建文章**
```typescript
// 使用脚本创建多篇文章
const articles = [
  { title: 'Article 1', slug: 'article-1', ... },
  { title: 'Article 2', slug: 'article-2', ... },
];

for (const article of articles) {
  await createArticle(article);
}
```

**批量更新分类**
```sql
-- 批量更新文章分类
UPDATE posts
SET category_uuid = 'new-category-uuid'
WHERE category_uuid = 'old-category-uuid';
```

### 2. 内容复用

**模板化**
```markdown
# 文章模板

## 概述
[简要介绍]

## 主要内容
### 章节1
[内容]

### 章节2
[内容]

## 结论
[总结和行动呼吁]
```

**组件化内容**
- 创建可复用的内容块
- 使用变量替换动态内容
- 建立内容库

### 3. 性能优化

**图片优化**
```typescript
// 使用WebP格式
cover_url: '/imgs/blog/article.webp'

// 添加懒加载
<img loading="lazy" src="..." />
```

**缓存策略**
```typescript
// 设置适当的缓存头
Cache-Control: public, max-age=3600
```

### 4. 分析集成

**自定义事件**
```typescript
// 跟踪文章阅读
gtag('event', 'page_view', {
  page_title: 'Article Title',
  page_location: window.location.href
});
```

**转化跟踪**
- 设置阅读目标
- 跟踪分享行为
- 测量转化率

### 5. 自动化

**CI/CD集成**
```yaml
# .github/workflows/blog-sync.yml
name: Sync Blog
on:
  push:
    paths:
      - 'src/scripts/**'

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - run: pnpm blog:sync
```

**定时任务**
```bash
# 每天同步内容
0 2 * * * /usr/local/bin/pnpm blog:sync
```

### 6. 国际化

**多语言策略**
```typescript
// 创建多语言版本
const locales = ['en', 'zh', 'ja'];

for (const locale of locales) {
  await createArticle({ ...article, locale });
}
```

**URL结构**
```
/en/posts/article-slug
/zh/posts/文章-slug
/ja/posts/記事-slug
```

## 快速命令参考

```bash
# 开发
pnpm dev                    # 启动开发服务器
pnpm db:studio             # 打开数据库GUI

# 博客操作
pnpm blog:sync             # 同步博客到生产
pnpm db:push               # 推送数据库变更
pnpm db:generate           # 生成迁移文件

# 构建和部署
pnpm build                 # 生产构建
pnpm deploy:prod           # 部署到生产

# 数据库
psql $DATABASE_URL         # 连接数据库
```

## 示例文章

### 完整示例（中文）

```sql
INSERT INTO posts (
  uuid, slug, title, description, content,
  created_at, updated_at, status,
  cover_url, author_name, author_avatar_url,
  locale, category_uuid
) VALUES (
  'post-example-' || extract(epoch from now())::bigint,
  'example-article',
  '示例文章标题',
  '这是一篇示例文章的简短描述，用于SEO和列表展示。',
  '# 示例文章

## 概述
这是文章的主要内容部分。

## 主要章节
这里包含文章的详细内容和要点。

## 结论
总结文章的核心信息和行动呼吁。

---
*作者: trygempix2.pro*',
  NOW(),
  NOW(),
  'online',
  '/imgs/blog/example.jpg',
  'trygempix2.pro',
  '/imgs/users/1.png',
  'zh',
  'ai-tech-category'
) ON CONFLICT (uuid) DO NOTHING;
```

---

## 📖 快速参考

### 🚀 一句话创作

```
「写一篇关于 [主题] 的 [语言] 博客文章」
```

Claude 自动完成：内容生成 → SEO 优化 → 写入数据库 → 提供预览

---

### 🎨 自定义创作

```
「写一篇关于 [主题] 的文章：
- 语言：[zh/en]
- 目标读者：[初级/中级/高级]
- 字数：[800/1500/2000+]
- 包含：[代码示例/图表/案例研究]
- 风格：[技术/营销/教程]」
```

---

### 🔄 优化现有文章

```
「优化 slug 为 '[article-slug]' 的文章的 SEO」
「将 '[article-slug]' 翻译成英文版本」
「更新 '[article-slug]' 的过时代码示例」
```

---

### 📦 批量操作

```
「生成一个 [主题] 系列文章（共 N 篇）：
1. 子主题 1
2. 子主题 2
3. 子主题 3」
```

---

## 🎯 AI 驱动 vs 传统方式

| 维度 | AI 驱动（本 Skill） | 传统方式 |
|------|-------------------|---------|
| **创作时间** | 5-10 分钟 | 2-4 小时 |
| **SEO 优化** | 自动检查 ✅ | 手动优化 |
| **数据库写入** | 自动生成脚本 ✅ | 手动编写代码 |
| **内容质量** | AI 辅助，一致性高 | 人工编写，质量波动 |
| **批量处理** | 支持系列文章 ✅ | 逐篇手动创建 |
| **多语言** | 一键翻译 ✅ | 手动翻译 |

---

## ⚡ 核心优势

1. **零代码创作** - 无需手写 SQL 或 TypeScript
2. **智能优化** - 自动 SEO 检查和内容优化
3. **快速迭代** - 从想法到发布仅需几分钟
4. **质量保证** - 内置检查清单确保质量
5. **可扩展** - 支持批量、系列、多语言

---

## 📚 相关资源

- **部署指南**: [DEPLOYMENT.md](../../../DEPLOYMENT.md)
- **数据库文档**: [src/db/schema.ts](../../../src/db/schema.ts)
- **同步脚本**: [scripts/blog-sync.sh](../../../scripts/blog-sync.sh)
- **示例文章**: [src/scripts/seed-blog.ts](../../../src/scripts/seed-blog.ts)

---

## 🔖 版本信息

- **版本**: v3.0.0-ai-powered
- **更新日期**: 2025-01-11
- **变更摘要**: 完全重构为 AI 驱动的工作流，使用 MCP 工具自动化文章创作和数据库操作
- **维护者**: trygempix2.pro Team

---

## 💡 提示词模板库

### 技术教程类
```
「写一篇关于 [技术栈] 的完整教程：
- 包含实战代码示例
- 面向 [初级/中级] 开发者
- 涵盖常见问题和最佳实践」
```

### 产品发布类
```
「写一篇 [产品/功能] 的发布公告：
- 突出核心亮点（3-5 个）
- 包含使用场景和案例
- 添加 CTA 引导用户注册/试用」
```

### SEO 内容类
```
「围绕 [核心关键词] 创建 SEO 内容矩阵：
- 覆盖 5-10 个长尾关键词
- 不同角度和深度
- 内部链接形成集群」
```

### 翻译优化类
```
「将 [slug] 翻译成 [目标语言]：
- 保持技术准确性
- 调整文化表达差异
- 优化本地化 SEO」
```

---

**开始使用：** 直接对 Claude 说一句话，让 AI 驱动的文章创作工作流为你服务！🚀