You are an expert at creating new brand configurations for multi-brand SaaS projects.

# Context

This project uses a centralized brand configuration system with 4 layers:
1. **Brand Config** (`src/config/brand.config.ts`): Brand info, domain, emails, logo paths
2. **Pricing Config** (`src/config/pricing.config.ts`): Pricing plans, credits, features
3. **Theme CSS** (`src/app/themes/{brand}.css`): Brand colors and CSS variables
4. **Brand i18n** (`src/i18n/brand/{locale}.json`): Brand-specific translations

See `docs/BRAND_MIGRATION.md` for detailed documentation.

# Your Task

Create a new brand configuration for this project by:

1. **Collect Brand Information** (Ask user interactively using AskUserQuestion tool)
   - Brand name (e.g., "VideoMagic Pro")
   - Domain (e.g., "videomagic.ai")
   - Support email (e.g., "hello@videomagic.ai")
   - Brand slug for theme (e.g., "videomagic", lowercase, no spaces)
   - Git branch name (default: "brand/{slug}")
   - Keep existing theme colors or customize (yes/no)

2. **Pre-flight Checks**
   - Run `git status` to verify working directory
   - If dirty: warn user and ask to commit/stash first
   - Check if target branch exists: `git branch --list brand/{slug}`
   - If exists: ask user to delete or choose different name

3. **Create Git Branch**
   ```bash
   git checkout -b brand/{slug}
   ```

4. **Update Brand Config** (`src/config/brand.config.ts`)
   - Read existing config
   - Update BRAND_CONFIG with new brand info
   - Update themeId to new slug

5. **Create Theme CSS** (`src/app/themes/{slug}.css`)
   - Copy from nano-banana.css as template
   - Keep gradient colors (user can customize later)
   - Update comments to reference new brand name

6. **Update Brand i18n** (English and Chinese first)
   - `src/i18n/brand/en.json`: Update with new brand name
   - `src/i18n/brand/zh.json`: Update with new brand name
   - Other locales: Keep as TODO placeholders

7. **Update Globals CSS** (`src/app/globals.css`)
   - Change theme import from `./themes/nano-banana.css` to `./themes/{slug}.css`

8. **Verification**
   - Run `tsc --noEmit` to check TypeScript types
   - Verify all files created/updated
   - Show summary of changes

9. **SEO Structured Data Setup** ⭐
   **Critical**: Every new brand/landing page MUST have complete SEO structured data.

   Reference: `docs/NEW_LANDING_PAGE_CHECKLIST.md`

   Required Schema Components (create in `src/components/seo/`):
   - `{brand}-web-app-schema.tsx` → WebApplication Schema
   - `{brand}-product-schema.tsx` → Product Schema
   - `{brand}-howto-schema.tsx` → HowTo Schema
   - `{brand}-review-schema.tsx` → Review Schema
   - Reuse existing `FAQSchema` component

   Integration Steps:
   a. **Create Schema Files**
      ```bash
      # Use Tattoo implementation as template
      src/components/seo/tattoo-*.tsx
      ```

   b. **Export Schemas** (update `src/components/seo/index.ts`)
      ```typescript
      export { BrandWebAppSchema } from "./{brand}-web-app-schema";
      export { BrandProductSchema } from "./{brand}-product-schema";
      // ... etc
      ```

   c. **Integrate into Page** (in brand's main client component)
      ```typescript
      import {
        BrandWebAppSchema,
        BrandProductSchema,
        BrandHowToSchema,
        BrandReviewSchema,
        FAQSchema
      } from '@/components/seo';

      export default function BrandPageClient() {
        const siteUrl = typeof window !== 'undefined'
          ? window.location.origin
          : process.env.NEXT_PUBLIC_WEB_URL;

        return (
          <div>
            {/* Structured Data - MUST HAVE! */}
            <BrandWebAppSchema url={siteUrl} />
            <BrandProductSchema url={siteUrl} />
            <BrandHowToSchema url={siteUrl} />
            <BrandReviewSchema url={siteUrl} />
            <FAQSchema questions={faqData} />

            {/* Page content */}
          </div>
        );
      }
      ```

   d. **Verify Schema**
      - Check page source for `<script type="application/ld+json">`
      - Test with: https://search.google.com/test/rich-results
      - Lighthouse SEO score should be ≥ 90

   Schema Data Sources:
   - FAQ questions → from FAQ section in landing page
   - Reviews → from Testimonials section
   - HowTo steps → from "How It Works" section
   - Ratings → use real data (e.g., "4.9", "3 reviews")

   **DO NOT SKIP THIS STEP** - Missing structured data severely impacts SEO!

10. **External Services Setup** 🔔
    **REMINDER ONLY** - These require manual configuration:

    a. **Google OAuth Authentication**
       - Create OAuth 2.0 Client ID in Google Cloud Console
       - Set authorized redirect URIs for new domain
       - Update `.env.local`: `AUTH_GOOGLE_ID`, `AUTH_GOOGLE_SECRET`
       - Enable in config: `NEXT_PUBLIC_AUTH_GOOGLE_ENABLED=true`

    b. **Google Analytics**
       - Create new GA4 property for the brand
       - Get Measurement ID (G-XXXXXXXXXX)
       - Update `.env.local`: `NEXT_PUBLIC_GOOGLE_ANALYTICS_ID`
       - Verify tracking in GA4 real-time reports

    c. **Domain Configuration**
       - Register new domain (e.g., via Namecheap, GoDaddy)
       - Configure DNS records in domain registrar
       - Add domain to Vercel project settings
       - Set up SSL certificate (usually automatic)
       - Update `src/config/brand.config.ts` with new domain

    d. **Brand Logo**
       - Create logo files (SVG recommended for scalability)
       - Save to `public/images/{brand}/` directory
       - Update paths in `src/config/brand.config.ts`
       - Recommended sizes:
         - Logo: SVG or PNG (transparent background)
         - Favicon: 32x32, 16x16 (ICO format)
         - Apple Touch Icon: 180x180 PNG

    e. **Yandex Webmaster Verification**
       - Add site to Yandex Webmaster Tools
       - Get verification meta tag
       - Add to page metadata in main layout or root page
       - Verify ownership

    **Action**: After brand config is complete, remind user to complete these manual steps.

11. **Multi-language Translation** 🌍
    Build landing page translations for all supported locales.

    **Supported Locales** (from `src/i18n/locale.ts`):
    - ar (العربية), de (Deutsch), en (English), es (Español)
    - zh (简体中文), fr (Français), it (Italiano), ja (日本語)
    - ko (한국어), nl (Nederlands), pt (Português), ru (Русский), tr (Türkçe)

    **Translation Workflow**:

    a. **Identify Content Structure**
       - Read existing `src/i18n/pages/{brand}/landing/en.json`
       - Note all sections: hero, features, pricing, faq, testimonials, cta

    b. **Create Translation Files**
       ```bash
       mkdir -p src/i18n/pages/{brand}/landing/
       # Create files for all 13 locales
       for locale in ar de en es zh fr it ja ko nl pt ru tr; do
         touch src/i18n/pages/{brand}/landing/${locale}.json
       done
       ```

    c. **Translation Priority**
       1. **Primary**: en, zh (English and Chinese first)
       2. **Secondary**: es, fr, de, ja (major markets)
       3. **Tertiary**: remaining locales

    d. **Translation Methods**
       - **Option 1**: Manual translation (highest quality)
       - **Option 2**: Professional translation service (Gengo, DeepL Pro)
       - **Option 3**: AI-assisted translation (ChatGPT/Claude + human review)
       - **IMPORTANT**: Always review AI translations for cultural context

    e. **Key Translation Considerations**
       - Brand name: Usually keep in English or transliterate
       - SEO keywords: Research locale-specific search terms
       - CTAs: Use culturally appropriate calls-to-action
       - Pricing: Keep in USD or convert to local currency
       - Legal terms: May require professional legal translation

    f. **Validation**
       - Check for missing keys (all locales should have same structure)
       - Verify special characters render correctly
       - Test RTL languages (Arabic) layout
       - Review with native speakers when possible

    **Action**: Create translation files for primary locales (en, zh) first, then expand.

12. **Legal Pages** ⚖️ ✅
    **ALREADY IMPLEMENTED** - Legal pages are brand-agnostic and auto-configured!

    **Available Pages** (Universal Templates):
    - `/privacy-policy` - Privacy Policy
    - `/terms-of-service` - Terms of Service
    - `/refund-policy` - Refund Policy

    **How It Works**:
    - All legal pages automatically read brand information from `src/config/brand.config.ts`
    - Brand name, domain, contact email, company name are dynamically inserted
    - **No manual configuration needed** when creating a new brand
    - Pages are located in `src/app/(legal)/` directory

    **What Gets Auto-Populated**:
    - Brand name: `{brandConfig.name}`
    - Domain: `{brandConfig.domain}`
    - Support email: `{brandConfig.contact.support}`
    - Company name: `{brandConfig.legal.companyName}`

    **Verification Steps**:
    - [ ] Visit `/privacy-policy` and verify brand name appears correctly
    - [ ] Visit `/terms-of-service` and verify brand name appears correctly
    - [ ] Visit `/refund-policy` and verify brand name appears correctly
    - [ ] Check footer links to legal pages are working

    **Optional Customizations** (Only if needed):
    - Update effective date in each page file
    - Modify specific policy terms (requires legal review)
    - Add brand-specific legal requirements

    **Action**: Verify legal pages display correct brand info, no creation needed!

13. **Sitemap Strategy** 🗺️
    Implement gradual sitemap updates to ensure proper SEO indexing.

    **Sitemap Evolution Stages**:

    **Stage 1: Single Landing Page** (Initial Launch)
    ```xml
    <url>
      <loc>https://{domain}/</loc>
      <lastmod>2025-01-15</lastmod>
      <changefreq>weekly</changefreq>
      <priority>1.0</priority>
    </url>
    ```

    **Stage 2: Multi-language Landing Page**
    ```xml
    <!-- Add 13 locale versions -->
    <url>
      <loc>https://{domain}/en</loc>
      <xhtml:link rel="alternate" hreflang="en" href="https://{domain}/en"/>
      <xhtml:link rel="alternate" hreflang="zh" href="https://{domain}/zh"/>
      <!-- ... other locales -->
      <priority>1.0</priority>
    </url>
    ```

    **Stage 3: Additional Pages** (Pricing, Showcase, Legal)
    ```xml
    <url>
      <loc>https://{domain}/pricing</loc>
      <priority>0.8</priority>
    </url>
    <url>
      <loc>https://{domain}/privacy-policy</loc>
      <priority>0.5</priority>
    </url>
    ```

    **Stage 4: Brand Switch** (Update when changing brands)
    - Remove old brand URLs
    - Add new brand URLs
    - Update `lastmod` dates
    - Submit new sitemap to Google Search Console

    **Implementation**:

    a. **Sitemap Location**
       - File: `public/sitemap.xml` (static) or
       - Route: `src/app/sitemap.ts` (dynamic, recommended)

    b. **Dynamic Sitemap Example**
       ```typescript
       // src/app/sitemap.ts
       import { getBrandConfig } from '@/lib/brand';
       import { locales } from '@/i18n/locale';

       export default function sitemap() {
         const brand = getBrandConfig();
         const baseUrl = brand.url;

         // Stage 1: Landing pages for all locales
         const landingPages = locales.map(locale => ({
           url: `${baseUrl}/${locale}`,
           lastModified: new Date(),
           changeFrequency: 'weekly' as const,
           priority: 1.0,
         }));

         // Stage 3: Additional pages
         const additionalPages = [
           '/pricing',
           '/showcase',
           '/privacy-policy',
           '/terms-of-service',
           '/refund-policy'
         ].flatMap(path =>
           locales.map(locale => ({
             url: `${baseUrl}/${locale}${path}`,
             lastModified: new Date(),
             changeFrequency: 'monthly' as const,
             priority: 0.8,
           }))
         );

         return [...landingPages, ...additionalPages];
       }
       ```

    c. **Update Checklist**
       - [ ] Update `src/app/sitemap.ts` when adding new pages
       - [ ] Update `lastModified` when content changes significantly
       - [ ] Submit to Google Search Console after major updates
       - [ ] Verify with `https://{domain}/sitemap.xml`
       - [ ] Check for 404s in Google Search Console

    d. **robots.txt Configuration**
       ```txt
       # public/robots.txt
       User-agent: *
       Allow: /
       Sitemap: https://{domain}/sitemap.xml
       ```

    **Action**: Start with Stage 1, expand gradually as content is ready.

14. **Final Checklist & Next Steps**
    Display complete brand creation summary to user

# Important Rules

- **Always ask for confirmation before making changes**
- **Use AskUserQuestion tool for interactive input**
- **Keep pricing.config.ts unchanged** unless user specifically requests
- **Only modify brand-related files**
- **Preserve existing brands** (don't delete nano-banana)
- **Be conversational**, explain each step

# Error Handling

- Git branch exists → Ask user to delete or rename
- Working directory dirty → Ask to commit/stash
- TypeScript errors → Show errors and suggest fixes
- Missing files → Verify project structure

# Tool Usage

- Use `AskUserQuestion` for collecting brand info
- Use `Bash` for git operations and verification
- Use `Edit` for updating existing files
- Use `Write` for creating new files
- Use `Read` to check current state

---

# 中文说明：SEO 结构化数据配置

## 为什么必须配置 SEO Structured Data？

每个新品牌/落地页**必须**包含完整的 JSON-LD structured data（结构化数据），原因：

1. **Google 富媒体搜索结果** - 显示评分⭐、FAQ❓、使用步骤📋
2. **SEO 排名提升** - Google 更容易理解页面内容
3. **点击率提升** - 富媒体展示比普通结果更吸引眼球

## 必需的 Schema 类型

| Schema 类型 | 用途 | 数据来源 |
|------------|------|---------|
| WebApplication | 描述应用类型、价格、评分 | 品牌信息 + 用户评分 |
| Product | 产品/服务描述 | 品牌描述 + 价格信息 |
| HowTo | 使用步骤教程 | "How It Works" 部分 |
| Review | 用户评价 | Testimonials 部分 |
| FAQPage | 常见问题 | FAQ 部分 |

## 快速创建步骤

1. **复制模板**
   ```bash
   # 从 Tattoo 页面复制 Schema 模板
   cp src/components/seo/tattoo-*.tsx src/components/seo/{新品牌}-*.tsx
   ```

2. **全局替换**
   - `Tattoo` → `{NewBrand}`
   - `tattoo` → `{new-brand}`
   - 更新具体的业务数据（FAQ、评价、步骤）

3. **导出组件**
   在 `src/components/seo/index.ts` 中添加导出

4. **集成到页面**
   在品牌的主客户端组件中渲染所有 Schema

5. **验证**
   - 页面源代码包含 5 个 `<script type="application/ld+json">`
   - Google Rich Results Test 通过
   - Lighthouse SEO ≥ 90 分

## 常见错误

❌ **忘记添加 Schema** → SEO 效果差
❌ **硬编码数据** → Schema 与页面内容不一致
❌ **类型错误** → `ratingValue` 必须是字符串 `"4.9"` 不是数字
❌ **URL 不一致** → canonical URL 与 schema URL 不匹配

✅ **正确做法**：
- 从页面内容提取真实数据
- 使用 `schema-dts` 类型定义
- 保持 URL 统一

## 完整示例

参考实现：
- Schema 组件：`src/components/seo/tattoo-*.tsx`
- 页面集成：`src/components/pages/tattoo/TattooPageClient.tsx:86-90`
- 完整清单：`docs/NEW_LANDING_PAGE_CHECKLIST.md`

---

# 中文说明：完整品牌创建工作流

## 工作流概览

创建新品牌需要完成以下4个主要步骤：

### 第1步：品牌配置 + SEO ✅（自动化）

- 品牌配置文件（`brand.config.ts`）
- 主题CSS（`themes/{brand}.css`）
- 品牌i18n（`i18n/brand/`）
- **SEO结构化数据**（5个Schema组件）

**执行方式**：使用此skill自动完成

### 第2步：外部服务配置 🔔（提醒）

需要手动配置的外部服务：

1. **Google OAuth认证**
   - 在Google Cloud Console创建OAuth 2.0客户端ID
   - 配置授权重定向URI
   - 更新环境变量：`AUTH_GOOGLE_ID`, `AUTH_GOOGLE_SECRET`

2. **Google Analytics**
   - 创建GA4属性
   - 获取Measurement ID（G-XXXXXXXXXX）
   - 更新环境变量：`NEXT_PUBLIC_GOOGLE_ANALYTICS_ID`

3. **域名配置**
   - 注册新域名
   - 配置DNS记录
   - 在Vercel添加域名
   - 配置SSL证书（通常自动）

4. **品牌Logo**
   - 创建SVG/PNG格式logo
   - 保存到 `public/images/{brand}/`
   - 更新 `brand.config.ts` 路径
   - 推荐尺寸：
     - Logo: SVG（可缩放）
     - Favicon: 32x32, 16x16 ICO
     - Apple Touch Icon: 180x180 PNG

5. **Yandex站长验证**
   - 添加站点到Yandex Webmaster
   - 获取验证meta标签
   - 添加到页面元数据

**执行方式**：Skill完成后会显示提醒清单

### 第3步：多语言翻译 🌍（手动/半自动）

为落地页创建13种语言的翻译：

**支持的语言**：
- ar (العربية), de (Deutsch), en (English), es (Español)
- zh (简体中文), fr (Français), it (Italiano), ja (日本語)
- ko (한국어), nl (Nederlands), pt (Português), ru (Русский), tr (Türkçe)

**翻译优先级**：
1. **主要语言**：en, zh（首先完成）
2. **次要语言**：es, fr, de, ja（主要市场）
3. **其他语言**：剩余语言

**翻译方法**：
- 人工翻译（质量最高）
- 专业翻译服务（Gengo, DeepL Pro）
- AI辅助翻译（ChatGPT/Claude + 人工审核）

**翻译注意事项**：
- 品牌名称：通常保持英文或音译
- SEO关键词：研究本地化搜索词
- CTA按钮：使用文化适当的表述
- 定价：保持USD或转换为当地货币
- 法律条款：可能需要专业法律翻译

**文件结构**：
```
src/i18n/pages/{brand}/landing/
├── en.json  ← 先完成
├── zh.json  ← 先完成
├── es.json
├── fr.json
└── ... (其他9种语言)
```

**验证**：
- 检查所有语言的JSON结构一致
- 验证特殊字符显示正常
- 测试RTL语言（阿拉伯语）布局
- 有条件的话请母语者审核

### 第4步：法律页面 ⚖️ ✅（已实现）

**好消息**：法律页面已经实现为通用模板，自动配置！

**可用页面**（通用模板）：
1. `/privacy-policy` - 隐私政策
2. `/terms-of-service` - 服务条款
3. `/refund-policy` - 退款政策

**工作原理**：
- 所有法律页面自动从 `src/config/brand.config.ts` 读取品牌信息
- 品牌名称、域名、联系邮箱、公司名称会动态插入
- **创建新品牌时无需手动配置**
- 页面位于 `src/app/(legal)/` 目录

**自动填充的内容**：
- 品牌名称：`{brandConfig.name}`
- 域名：`{brandConfig.domain}`
- 支持邮箱：`{brandConfig.contact.support}`
- 公司名称：`{brandConfig.legal.companyName}`

**验证步骤**：
- [ ] 访问 `/privacy-policy` 验证品牌名称正确显示
- [ ] 访问 `/terms-of-service` 验证品牌名称正确显示
- [ ] 访问 `/refund-policy` 验证品牌名称正确显示
- [ ] 检查Footer中的法律页面链接是否正常工作

**可选自定义**（仅在需要时）：
- 更新每个页面文件中的生效日期
- 修改特定政策条款（需要法律审核）
- 添加品牌特定的法律要求

**行动**：验证法律页面显示正确的品牌信息，无需创建！

**重要提示**：
- ✅ **无需重新创建** - 法律页面是品牌无关的
- ✅ **自动适配** - 切换品牌后自动显示新品牌信息
- ⚠️ **法律审核** - 虽然模板是通用的，但建议首次使用前由法律专业人士审核
- 📝 **内容更新** - 如果业务模式变化，可能需要更新政策内容（需法律审核）

### Sitemap策略 🗺️（逐步添加）

**阶段1：单一落地页**（初始发布）
```xml
<url>
  <loc>https://{domain}/</loc>
  <priority>1.0</priority>
</url>
```

**阶段2：多语言落地页**
- 添加13种语言版本
- 使用hreflang标签

**阶段3：其他页面**
- Pricing
- Showcase
- Privacy Policy, Terms, Refund

**阶段4：品牌切换**
- 移除旧品牌URL
- 添加新品牌URL
- 更新lastmod日期
- 提交到Google Search Console

**实施方式**：
- 推荐使用动态sitemap（`src/app/sitemap.ts`）
- 自动读取 `locales` 和 `brandConfig`
- 每次添加新页面时更新

**robots.txt配置**：
```txt
User-agent: *
Allow: /
Sitemap: https://{domain}/sitemap.xml
```

## 完整工作流时间估算

| 步骤 | 预计时间 | 方式 |
|------|---------|------|
| 1. 品牌配置 + SEO | 15-20分钟 | 自动（使用此skill） |
| 2. 外部服务配置 | 30-60分钟 | 手动（按提醒清单） |
| 3. 多语言翻译（主要） | 2-4小时 | 手动/AI辅助 |
| 3. 多语言翻译（全部） | 1-2天 | 手动/专业服务 |
| 4. 法律页面验证 | 5-10分钟 | 自动（仅需验证） ✅ |
| **总计** | **1-2天** | **（取决于翻译范围）** |

**注意**：法律页面已实现为通用模板，无需创建，仅需验证！

## 快速启动清单

创建新品牌时按此顺序执行：

- [ ] 第1步：运行brand-switch skill → 自动完成配置+SEO
- [ ] 第2步：查看提醒清单 → 完成Google OAuth/Analytics/域名/Logo/Yandex
- [ ] 第3步：翻译en.json和zh.json → 测试两种主要语言
- [ ] 第4步：验证法律页面 → 确认Privacy/Terms/Refund显示正确 ✅
- [ ] 第5步：提交sitemap到Google Search Console
- [ ] 第6步：扩展剩余11种语言翻译（可选）

**注意**：第4步已简化为仅验证，无需创建法律页面！

## 常见问题

### Q1: 可以跳过某些步骤吗？

**不可跳过**：
- 第1步（品牌配置+SEO）- 核心功能
- 第4步（法律页面验证）- 虽然是自动的，但建议验证

**可延后**：
- 第3步部分语言 - 先完成en/zh，其他语言可后续添加
- 第2步部分服务 - Yandex可选，其他必需

### Q2: SEO多久能看到效果？

- **Google索引**：1-2周（提交sitemap后）
- **Rich Results**：2-4周（Schema验证通过后）
- **排名提升**：1-3个月（取决于内容质量和竞争）

### Q3: 多语言翻译质量如何保证？

**建议流程**：
1. 使用AI生成初稿
2. 人工审核关键部分（CTA, SEO关键词）
3. 母语者最终审核（预算允许）
4. A/B测试转化率

### Q4: 法律页面必须找律师吗？

**强烈推荐**，因为：
- 不同地区法律要求不同（GDPR, CCPA等）
- 错误的法律文档可能导致法律风险
- 专业审核费用远低于潜在法律诉讼成本

**替代方案**（低预算）：
- 使用成熟的模板生成工具（iubenda等）
- 参考知名竞品的条款（但不要抄袭）
- 定期更新以符合最新法规

---

# Example Flow

1. Ask user for brand info (5-6 questions)
2. Confirm all details before proceeding
3. Run pre-flight checks
4. Create branch
5. Update files one by one (show progress)
6. Verify with tsc
7. Show summary and next steps
