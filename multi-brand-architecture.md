# Multi-Brand Routing Architecture

## Overview

This skill documents the multi-brand routing architecture implemented for the Next.js SaaS project, enabling multiple brands to coexist in the same codebase with isolated components and i18n content.

## Architecture Pattern

The system uses a **two-layer architecture**:

1. **Route Layer** (18-24 lines): Minimal routing logic that selects brand-specific modules
2. **Brand Container Layer**: Brand-specific components with SEO, data fetching, and rendering logic

This pattern enables:
- **URL routes remain unchanged** (`/pricing` stays `/pricing` for all brands)
- **Brand isolation** in separate directories to avoid merge conflicts
- **Build-time tree-shaking** - only the current brand's code is bundled
- **Static imports** for optimal performance with Turbopack

## Directory Structure

```
src/
├── app/[locale]/(default)/
│   ├── page.tsx              # Route layer: landing
│   ├── pricing/page.tsx      # Route layer: pricing
│   ├── showcase/page.tsx     # Route layer: showcase
│   ├── partners/page.tsx     # Route layer: partners
│   ├── gempix2/page.tsx      # Route layer: gempix2 product
│   ├── flux-pro/page.tsx     # Route layer: flux-pro product
│   └── ...
│
├── components/pages/
│   ├── b2/                   # Brand: Nano Banana Pro
│   │   ├── LandingPage.tsx
│   │   ├── PricingPage.tsx
│   │   ├── ShowcasePage.tsx
│   │   ├── PartnersPage.tsx
│   │   ├── Gempix2Page.tsx
│   │   ├── FluxProPage.tsx
│   │   ├── NanoBanana3Page.tsx
│   │   ├── NanoBananaProPage.tsx
│   │   └── Veo31VideoGenerationPage.tsx
│   │
│   └── gempix2/              # Brand: Gempix2
│       └── Gempix2Page.tsx
│
├── i18n/pages/
│   ├── b2/                   # Brand-specific i18n
│   │   ├── landing/          # 13 locales
│   │   ├── pricing/          # 13 locales
│   │   ├── showcase/         # 13 locales
│   │   └── partners/         # 13 locales
│   │
│   ├── gempix2/              # Product-specific i18n (shared)
│   ├── flux-pro/             # Product-specific i18n (shared)
│   ├── nano-banana-3/        # Product-specific i18n (shared)
│   └── ...
│
├── config/
│   └── brand.config.ts       # Central brand configuration
│
└── types/
    └── brand.ts              # BrandId type definitions
```

## Key Files

### 1. Brand Configuration (`src/config/brand.config.ts`)

```typescript
export type BrandConfig = {
  name: string;
  domain: string;
  url: string;
  themeId: string;
  brandId: string;  // ✅ Added for multi-brand support
  // ... other fields
};

export const BRAND_CONFIG = {
  name: "Nano Banana Pro",
  domain: "nanobanana2ai.art",
  url: "https://nanobanana2ai.art",
  themeId: "nano-banana",
  brandId: process.env.NEXT_PUBLIC_BRAND_ID || "b2",  // ✅ Defaults to "b2"
  // ... rest of config
} as const satisfies BrandConfig;
```

### 2. Brand Type Definitions (`src/types/brand.ts`)

```typescript
export type BrandId = "b2" | "gempix2" | "nano-banana";

export interface BrandPageProps {
  params: Promise<{ locale: string }>;
}

export type BrandContainerComponent = React.ComponentType<BrandPageProps>;
```

### 3. Route Layer Pattern (`src/app/[locale]/(default)/pricing/page.tsx`)

```typescript
import { getBrandId } from "@/lib/brand";
import type { BrandId } from "@/types/brand";

const brandId = getBrandId() as BrandId;

// Build-time static import mapping (Next.js will tree-shake unused branches)
const BrandPricingModule =
  brandId === "b2"
    ? await import("@/components/pages/b2/PricingPage")
    : brandId === "gempix2"
    ? await import("@/components/pages/gempix2/PricingPage")
    : null;

if (!BrandPricingModule) {
  throw new Error(`Unknown brand: ${brandId}`);
}

// Re-export brand-specific metadata and page component
export const generateMetadata = BrandPricingModule.generateMetadata;
export default BrandPricingModule.default;
```

**Key points:**
- Use **static conditional imports** (not template literals)
- Turbopack can tree-shake unused branches
- Re-export `generateMetadata` from brand module
- Static segment configs must be defined in route layer

### 4. Brand Container Pattern (`src/components/pages/b2/PricingPage.tsx`)

```typescript
import { getBrandId, getBrandConfig } from "@/lib/brand";
import { getPricingPage } from "@/services/page";
import type { Metadata } from "next";

const brandId = getBrandId();
const brandConfig = getBrandConfig();
const brandName = brandConfig.name;

// Brand-specific SEO defaults
const buildDefaultSeoTitle = (name: string) =>
  `${name} Image Generator Pricing | Transparent AI Credits`;

export async function generateMetadata({
  params,
}: {
  params: Promise<{ locale: string }>;
}): Promise<Metadata> {
  const { locale } = await params;
  const page = await getPricingPage(locale, brandId);  // ✅ Pass brandId

  const baseUrl = brandConfig.url.replace(/\/$/, "");  // ✅ Use brandConfig
  const canonical =
    locale === defaultLocale ? `${baseUrl}/pricing` : `${baseUrl}/${locale}/pricing`;

  return {
    title: page.seo?.title ?? DEFAULT_SEO_TITLE,
    description: page.seo?.description ?? DEFAULT_SEO_DESCRIPTION,
    // ...
  };
}

export default async function B2PricingPage({ params }) {
  const { locale } = await params;
  const page = await getPricingPage(locale, brandId);
  // ... render logic
}
```

**Key points:**
- Import `getBrandId()` and `getBrandConfig()`
- Replace `process.env.NEXT_PUBLIC_WEB_URL` with `brandConfig.url`
- Pass `brandId` to service functions
- Each brand defines its own SEO strategy

### 5. Service Layer (`src/services/page.ts`)

```typescript
export async function getPricingPage(locale: string, brandId?: string): Promise<PricingPage> {
  return (await getPage("pricing", locale, brandId)) as PricingPage;
}

export async function getPage(
  name: string,
  locale: string,
  brandId?: string
): Promise<LandingPage | PricingPage | ShowcasePage | PartnersPage> {
  const normalizedLocale = normalizeLocale(locale);

  if (brandId) {
    const loadBrandPage = async () => {
      if (brandId === "b2") {
        return await import(`@/i18n/pages/b2/${name}/${normalizedLocale}.json`).then(
          (module) => module.default
        );
      }
      if (brandId === "gempix2") {
        return await import(`@/i18n/pages/gempix2/${name}/${normalizedLocale}.json`).then(
          (module) => module.default
        );
      }
      throw new Error(`Unsupported brandId: ${brandId}`);
    };

    try {
      return await loadBrandPage();
    } catch (error) {
      // Fallback to en.json
      if (brandId === "b2") {
        return await import(`@/i18n/pages/b2/${name}/en.json`).then((module) => module.default);
      }
      // ... other brands
    }
  }

  // Fallback for backward compatibility
  // ...
}
```

### 6. Layout Integration (`src/app/[locale]/(default)/layout.tsx`)

```typescript
import { getLandingPage } from "@/services/page";
import { getBrandId } from "@/lib/brand";

const brandId = getBrandId();

export default async function DefaultLayout({ children, params }) {
  const { locale } = await params;
  const page = await getLandingPage(locale, brandId);  // ✅ Pass brandId

  return (
    <>
      {page.header && <Header header={page.header} />}
      <main>{children}</main>
      {page.footer && <Footer footer={page.footer} />}
    </>
  );
}
```

## Adding a New Brand

### Step 1: Update Type Definitions

```typescript
// src/types/brand.ts
export type BrandId = "b2" | "gempix2" | "nano-banana" | "newbrand";  // ✅ Add new brand
```

### Step 2: Create Brand Configuration

```typescript
// For newbrand, create .env.local or set environment variable
NEXT_PUBLIC_BRAND_ID=newbrand
```

Update `src/config/brand.config.ts` if needed:

```typescript
export const BRAND_CONFIG = {
  name: "New Brand Name",
  domain: "newbrand.com",
  url: "https://newbrand.com",
  themeId: "newbrand-theme",
  brandId: process.env.NEXT_PUBLIC_BRAND_ID || "b2",
  // ...
} as const satisfies BrandConfig;
```

### Step 3: Create Brand Components

```bash
mkdir -p src/components/pages/newbrand
```

Create brand-specific pages:
- `src/components/pages/newbrand/LandingPage.tsx`
- `src/components/pages/newbrand/PricingPage.tsx`
- `src/components/pages/newbrand/ShowcasePage.tsx`
- `src/components/pages/newbrand/PartnersPage.tsx`

### Step 4: Create i18n Content

```bash
mkdir -p src/i18n/pages/newbrand/{landing,pricing,showcase,partners}
```

Copy and translate JSON files for each locale (13 locales total).

### Step 5: Update Route Layers

Update all route files to include the new brand:

```typescript
// src/app/[locale]/(default)/pricing/page.tsx
const BrandPricingModule =
  brandId === "b2"
    ? await import("@/components/pages/b2/PricingPage")
    : brandId === "gempix2"
    ? await import("@/components/pages/gempix2/PricingPage")
    : brandId === "newbrand"  // ✅ Add this
    ? await import("@/components/pages/newbrand/PricingPage")
    : null;
```

### Step 6: Update Service Layer

```typescript
// src/services/page.ts
const loadBrandPage = async () => {
  if (brandId === "b2") {
    return await import(`@/i18n/pages/b2/${name}/${normalizedLocale}.json`).then(...);
  }
  if (brandId === "gempix2") {
    return await import(`@/i18n/pages/gempix2/${name}/${normalizedLocale}.json`).then(...);
  }
  if (brandId === "newbrand") {  // ✅ Add this
    return await import(`@/i18n/pages/newbrand/${name}/${normalizedLocale}.json`).then(...);
  }
  throw new Error(`Unsupported brandId: ${brandId}`);
};
```

### Step 7: Build and Test

```bash
# Set brand ID
export NEXT_PUBLIC_BRAND_ID=newbrand

# Build
pnpm build

# Start dev server
pnpm dev
```

## Git Merge Strategy

To prevent merge conflicts when multiple brands develop simultaneously:

```gitattributes
# .gitattributes
src/components/pages/b2/* merge=ours
src/components/pages/gempix2/* merge=ours
src/components/pages/newbrand/* merge=ours
src/i18n/pages/b2/* merge=ours
src/i18n/pages/gempix2/* merge=ours
src/i18n/pages/newbrand/* merge=ours
```

## Pages Refactored

### Core Pages (Brand-specific i18n)
- ✅ `/` (landing)
- ✅ `/pricing`
- ✅ `/showcase`
- ✅ `/partners`

### Product Pages (Shared i18n)
- ✅ `/veo-3-1-video-generation`
- ✅ `/nano-banana-pro-ai-image-editing`
- ✅ `/nano-banana-3`
- ✅ `/flux-pro`
- ✅ `/gempix2`

## Build Optimization

**Tree-shaking verified:**
- Only the current brand's components are included in the bundle
- Unused brand code is eliminated at build time
- Static imports enable optimal code splitting

**Build output:**
```
✓ Compiled successfully in 17.3s
✓ Generating static pages using 7 workers (53/53) in 4.2s
```

## Environment Variables

```bash
# .env.example
# Brand identifier for multi-brand architecture (optional)
# Available values: b2, gempix2, nano-banana
# Defaults to "b2" if not specified
NEXT_PUBLIC_BRAND_ID="b2"
```

## Common Patterns

### Replace Hardcoded URLs

❌ **Before:**
```typescript
const baseUrl = process.env.NEXT_PUBLIC_WEB_URL || "https://example.com";
```

✅ **After:**
```typescript
import { getBrandConfig } from "@/lib/brand";

const brandConfig = getBrandConfig();
const baseUrl = brandConfig.url.replace(/\/$/, "");
```

### Pass brandId to Services

❌ **Before:**
```typescript
const page = await getPricingPage(locale);
```

✅ **After:**
```typescript
import { getBrandId } from "@/lib/brand";

const brandId = getBrandId();
const page = await getPricingPage(locale, brandId);
```

### Static Segment Config

⚠️ **Route segment configs must be static values:**

❌ **Wrong:**
```typescript
export const revalidate = BrandModule.revalidate;  // Will fail
```

✅ **Correct:**
```typescript
export const revalidate = 60;  // Static value in route layer
```

## Troubleshooting

### Error: "Cannot find module '@/i18n/pages/landing/en.json'"

**Cause:** Service function not receiving `brandId` parameter.

**Fix:** Pass `brandId` to all service calls:
```typescript
const page = await getLandingPage(locale, brandId);
```

### Error: "Turbopack can't resolve dynamic import"

**Cause:** Using template literals in dynamic imports.

**Fix:** Use static conditional imports:
```typescript
// ❌ Wrong
const module = await import(`@/components/pages/${brandId}/Page`);

// ✅ Correct
const module = brandId === "b2"
  ? await import("@/components/pages/b2/Page")
  : null;
```

### Error: "exported 'dynamicParams' field not recognized"

**Cause:** Re-exporting non-static route segment configs.

**Fix:** Define static values in route layer:
```typescript
// Route layer
export const revalidate = 60;
export const dynamicParams = true;
```

## Benefits

1. **Brand Isolation**: Each brand has isolated components and i18n content
2. **Merge Safety**: Brand-specific directories prevent merge conflicts
3. **SEO Flexibility**: Each brand defines its own SEO strategy
4. **Build Optimization**: Tree-shaking eliminates unused brand code
5. **Type Safety**: TypeScript ensures all brands are handled
6. **Scalability**: Easy to add new brands without touching existing code

## Related Files

- `src/config/brand.config.ts` - Brand configuration
- `src/lib/brand.ts` - Brand utility functions
- `src/types/brand.ts` - Brand type definitions
- `src/services/page.ts` - Page data loading with brand support
- `.env.example` - Environment variable documentation

## References

- [Next.js Dynamic Routes](https://nextjs.org/docs/app/building-your-application/routing/dynamic-routes)
- [Next.js Route Segment Config](https://nextjs.org/docs/app/api-reference/file-conventions/route-segment-config)
- [Turbopack Optimization](https://nextjs.org/docs/app/api-reference/next-config-js/turbo)
