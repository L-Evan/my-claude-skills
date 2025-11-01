# Article Writer Skill

## Description
This skill helps you write professional, well-formatted articles with proper structure, engaging content, and optimized formatting.

## Features
- Markdown formatting with tables, code blocks, and visual separators
- Bilingual article support (English/Chinese)
- SEO-optimized structure with clear headings
- Interactive content with collapsible sections
- Emoji support for visual appeal
- Professional typography and spacing

## How to Use

### Writing a New Article

**Prompt Template:**
```
Write an article about [TOPIC] with the following specifications:
- Title: [ARTICLE TITLE]
- Language: [English/Chinese]
- Target audience: [AUDIENCE]
- Key sections to include:
  - Section 1
  - Section 2
  - Section 3
- Include practical examples/tips
- Target word count: [NUMBER] words
```

**Example:**
```
Write an article about "AI Video Creation Best Practices" with the following specifications:
- Title: "Mastering AI Video Creation: A Comprehensive Guide"
- Language: English
- Target audience: Content creators and marketers
- Key sections to include:
  - Getting started with AI video tools
  - Prompt engineering techniques
  - Quality optimization tips
  - Platform-specific strategies
- Include practical examples/tips
- Target word count: 2000 words
```

### Updating an Existing Article

**Prompt Template:**
```
Update the article located at [FILE_PATH] with the following improvements:
- Enhance formatting with better visual separators
- Add collapsible sections for examples
- Improve table formatting
- Add emoji to enhance visual appeal
- Optimize structure for better readability
- Ensure consistent spacing and typography
```

**Example:**
```
Update the article located at content/docs/halloween-guide.mdx with the following improvements:
- Enhance formatting with better visual separators
- Add collapsible sections for examples
- Improve table formatting
- Add emoji to enhance visual appeal
- Optimize structure for better readability
- Ensure consistent spacing and typography
```

### Creating Bilingual Articles

**Prompt Template:**
```
Create bilingual articles (English and Chinese) about [TOPIC]:
- Write the main article in English with professional formatting
- Translate and adapt for Chinese audience
- Ensure cultural adaptation for Chinese context
- Maintain consistent structure across both versions
- Use appropriate emoji for visual enhancement
```

## Formatting Guidelines

### Recommended Structure
1. **Front Matter**
   ```yaml
   ---
   description: Brief description of the article
   ---
   ```

2. **Main Title**
   - Use appropriate emoji
   - Make it engaging and descriptive

3. **Introduction**
   - 2-3 paragraphs
   - Highlight key benefits/value proposition

4. **Main Sections**
   - Use clear headings with emoji
   - Add visual separators (---)
   - Use tables for comparisons
   - Use collapsible sections for detailed examples

5. **Conclusion**
   - Summarize key points
   - Include call-to-action

### Visual Elements
- **Tables**: Use for comparisons, specifications, feature lists
- **Code Blocks**: Use ```markdown for prompts and examples
- **Collapsible Sections**: Use `<details>` for expandable content
- **Emoji**: Enhance readability and visual appeal
- **Blockquotes**: Use for important tips and quotes

### Best Practices
- Keep paragraphs concise (3-4 sentences max)
- Use bullet points for lists
- Add visual separators between major sections
- Include practical examples throughout
- Use consistent emoji style
- Optimize for both web and mobile viewing

## Example Output

```markdown
# 🎨 Mastering AI Video Creation

---

AI video creation has revolutionized content creation, enabling anyone to produce professional-quality videos without extensive technical knowledge.

---

## 🚀 Getting Started

### Why AI Video Tools?

| Feature | Traditional Video | AI Video |
|---------|------------------|----------|
| Time Required | Days/Weeks | Minutes/Hours |
| Technical Skills | Advanced | Minimal |
| Cost | High | Low |

---

### Quick Start Guide

1. **Choose Your Platform**
   - Research available AI video tools
   - Compare features and pricing
   - Read user reviews

2. **Craft Your First Video**
   - Start with simple prompts
   - Experiment with styles
   - Iterate based on results

---

## 💡 Pro Tips

> **Remember:** The best videos come from clear, descriptive prompts that paint a vivid picture of your desired outcome.

---

**Ready to start creating? Visit [platform] and begin your AI video journey today!**
```

## Integration with Database

After writing an article, you can insert it into the database using:

```bash
# Insert new article
npx tsx src/scripts/insert-custom-post.ts

# Sync to production
NODE_ENV=production npx tsx src/scripts/sync-blog-to-prod.ts
```

## Troubleshooting

**Issue: Formatting not displaying correctly**
- Ensure proper markdown syntax
- Check for missing code block fences
- Verify emoji encoding

**Issue: Article too long**
- Break into smaller sections
- Use collapsible details for long examples
- Consider splitting into multiple articles

**Issue: Poor readability**
- Add more visual separators
- Use tables for complex information
- Increase white space between sections
