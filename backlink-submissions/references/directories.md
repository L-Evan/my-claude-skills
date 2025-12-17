# Backlink Directory Submissions

This file tracks (1) what each directory needs and (2) what we already submitted.

## Preparation Checklist (generic)

Have these ready before submitting anywhere:
- Website URL (prefer `https://`)
- Product name (and length limits if the directory has them)
- One-line description (and length limits)
- Category/tags
- Submission email (which email to use)
- Public logo URL *and/or* a local logo file ready to upload (square, PNG/JPG/WebP, ≥ 128×128)
- Promo image / homepage screenshot (some directories require this)
- Confirmation statements (e.g. “I placed a backlink/badge”) and where on your site it is
- Optional: screenshots, pricing, founder name, socials

## Directory: Twelve Tools

- Site: `https://twelve.tools/`
- Submit entry: `https://twelve.tools/submit` → Free “Continue” → `https://twelve.tools/submit-your-tool`

### Required fields (Free plan)

- Tool URL
- Tool name (limit shown: 24 chars)
- Tool description (limit shown: 92 chars)
- Category (dropdown)
- Email
- Logo upload (file input: `input#imageUpload`, accept: `.png, .jpg, .jpeg, .webp, .jfif`)
- Checkbox confirmation: backlink/badge to `https://twelve.tools` on homepage/footer

### Notes

- If you skip the logo upload, submission fails with `?msg=ko` and message: “Don’t forget to upload a logo.”
- For logo, use a publicly accessible URL (recommended: `https://chatgptimages.pro/logo.png`) and upload a downloaded file.

## Directory: Wired Business

- Site: `https://wired.business/`
- Submit entry: `https://wired.business/submit-your-website`

### Required fields (Free submit form)

- Website URL (`rURL`)
- Website name (`rName`)
- Category (`rCateg` dropdown; used: `Artificial Intelligence`)
- Description (`rDesc`)
- Email (`email`)
- Homepage screenshot / promo image upload (`rFileUpload`) (required)
- Backlink/badge confirmation checkbox (`agreeBL`) for `https://wired.business`
- Submit button (`btSubmit`)

### Notes

- If required fields are missing (especially the upload), the form redirects to `?msg=ko`.
- Success page is `https://wired.business/done`.
- Backlink/badge is satisfied via the site footer “Partners” section linking to `https://wired.business`.
- Submission pack values live in `references/site.md` under “Wired Business Submission Pack”.

### Screenshot generation (no MCP)

If you need a fresh homepage screenshot for upload, generate it locally with Playwright and upload the PNG:

```bash
NPM_CONFIG_CACHE=$PWD/.npm-cache PLAYWRIGHT_BROWSERS_PATH=0 npx -y playwright@1.50.1 screenshot http://chatgptimages.pro wired-chatgptimages.pro.png --viewport-size=1200,675
```

## Directory: Dofollow.Tools

- Site: `https://dofollow.tools/`
- Submit entry: `https://dofollow.tools/submit`

### Required fields (Step 1: Tool Information)

- Tool URL
- Tool Name
- Tagline (max shown: 160)
- Description (min shown: 500, max 3000; markdown allowed)
- Logo upload (PNG/JPG/WEBP; max shown: 500kb)
- Screenshots (optional; up to 4; each < 5MB)
- Categories (select up to 3)
- Pricing Model (Free/Freemium/Paid)
- Platforms (e.g. Web/iOS/Android/Desktop/Browser Extension)

### Step 2: Submission Type

- Paid plans: `One Time Pro ($9/Lifetime)`, `Monthly Promotion ($5/Month)`, `Featured Listing ($29/Month)`
- Free listing requires:
  - Add a dofollow backlink/badge to `https://dofollow.tools` in your website footer
  - Review within 7 days

### Important: Login required

When clicking **Free** “Verify and Submit”, it redirects to `https://dofollow.tools/login` and requires authentication (Google/GitHub/Email).

## Submission Log

### Twelve Tools

- Date: `2025-12-17`
- Result: Success page `https://twelve.tools/done`
- Proof screenshot: `references/proofs/twelve-tools-2025-12-17.png`
- Submitted URL: `https://chatgptimages.pro/`
- Name: `ChatGPT Images`
- Description: `Free GPT Image 1.5 powered ChatGPT image generator for text-to-image and editing.`
- Category: `Artificial Intelligence`
- Email used: `1129190684@qq.com`
- Logo used: `https://chatgptimages.pro/logo.png`

### Wired Business

- Date: `2025-12-17`
- Result: Success page `https://wired.business/done`
- Proof screenshot: `references/proofs/wired-business-2025-12-17.png`
- Submitted URL: `http://chatgptimages.pro`
- Name: `ChatGPT Images`
- Description: `Free GPT Image 1.5 powered ChatGPT image generator for text-to-image and editing.`
- Category: `Artificial Intelligence`
- Email used: `1129190684@qq.com`
- Upload used: `references/proofs/wired-business-2025-12-17.png`

### Dofollow.Tools

- Date: `2025-12-18`
- Status: Blocked at login gate (`https://dofollow.tools/login`)
- Proof screenshot: `references/proofs/dofollow-tools-login-required-2025-12-18.png`
- Filled URL: `https://chatgptimages.pro/`
- Name: `ChatGPT Images`
- Categories selected: `Artificial intelligence`, `Image Generation & Editing`
- Pricing model selected: `Freemium`
- Platform selected: `Web`
- Uploaded logo: `references/assets/logo.png`
- Uploaded screenshots: `references/assets/homepage-1920x1080.png`, `references/assets/homepage-1200x630.png`
