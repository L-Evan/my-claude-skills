# Article Writer Skill

## 快速开始

### 方法1：后台界面写作（推荐新手）

1. **启动开发服务器**
```bash
pnpm dev
```

2. **访问后台管理**
- 打开浏览器访问 `http://localhost:3000/en/admin/posts`
- 或者使用 Drizzle Studio: `pnpm db:studio`

3. **创建文章**
- 点击"Add New Post"
- 填写表单：
  - **Title**: 文章标题
  - **Description**: 简短描述（用于SEO和列表展示）
  - **Content**: Markdown格式正文
  - **Locale**: 语言（`en` 或 `zh`）
  - **Category**: 选择分类
  - **Cover Image**: 封面图片URL

4. **保存并同步**
- 保存后文章自动保存到本地数据库
- 运行 `pnpm blog:sync` 同步到生产环境

### 方法2：脚本批量创建（推荐高级用户）

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
        'TryVeo3.ai',
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

## 完整写作流程

### 阶段1：准备

1. **确定主题和受众**
   - 明确文章目标和读者群体
   - 研究关键词和SEO策略

2. **准备资源**
   - 封面图片（推荐尺寸：1200x630px）
   - 文章结构大纲
   - 参考资料和引用

### 阶段2：内容创作

1. **创建文章**
```bash
# 使用后台界面或脚本创建
# 确保设置正确的 locale（zh 或 en）
```

2. **内容结构建议**
```markdown
# 文章标题（H1）

## 概述
简短介绍文章主题和价值

## 主要章节
### 章节1
内容...

### 章节2
内容...

## 结论
总结要点和行动呼吁

---
*作者: TryVeo3.ai*
```

3. **多语言支持**
- 英文文章：`locale: "en"`
- 中文文章：`locale: "zh"`
- 每种语言创建独立文章记录

### 阶段3：本地测试

1. **启动开发服务器**
```bash
pnpm dev
```

2. **预览文章**
- 访问 `http://localhost:3000/zh/posts/your-slug`
- 检查格式、图片、链接

3. **验证功能**
- 确认文章显示正确
- 测试分享按钮
- 检查SEO元数据

### 阶段4：同步到生产

1. **运行同步**
```bash
pnpm blog:sync
```

2. **验证同步结果**
- 访问生产环境URL
- 确认文章正确显示
- 检查数据库记录

### 阶段5：推广和优化

1. **SEO优化**
   - 优化标题和描述
   - 添加内部链接
   - 设置社交媒体分享图片

2. **性能监控**
   - 跟踪阅读量和互动
   - 收集用户反馈
   - 定期更新内容

## 数据库同步机制

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
author_name: 'TryVeo3.ai',
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
*作者: TryVeo3.ai*',
  NOW(),
  NOW(),
  'online',
  '/imgs/blog/example.jpg',
  'TryVeo3.ai',
  '/imgs/users/1.png',
  'zh',
  'ai-tech-category'
) ON CONFLICT (uuid) DO NOTHING;
```

## 最佳实践总结

1. **内容为王**：高质量、有价值的内容是成功的关键
2. **SEO友好**：优化标题、描述、关键词和结构
3. **用户体验**：清晰的结构、易读的格式、快速加载
4. **持续优化**：根据数据反馈不断改进
5. **自动化**：使用脚本和工具提高效率
6. **测试验证**：在发布前充分测试
7. **监控分析**：跟踪表现并调整策略

---

*最后更新：2025年11月1日*
*版本：v2.6.0*
*维护者：TryVeo3.ai*