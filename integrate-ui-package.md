# Integrate UI Package Skill

**Purpose**: 快速将 AI Studio 生成的 UI 压缩包整合到 Next.js 网站，创建独立的新路由页面。

## 工作流程

### 1. 接收参数
- `zipPath`: 压缩包路径（如：`/Users/xxx/Downloads/ai-xxx.zip`）
- `routeName`: 新路由名称（如：`tattoo`, `portfolio`, `blog`）
- `componentPrefix`: 组件前缀（如：`Tattoo`, `Portfolio`）

### 2. 解压和分析 (5 分钟)
```bash
# 解压到临时目录
unzip -q "${zipPath}" -d /tmp/${routeName}-ui

# 分析文件结构
ls -la /tmp/${routeName}-ui
ls -la /tmp/${routeName}-ui/components
```

**关键文件识别**：
- `App.tsx` - 主应用逻辑，包含页面路由
- `components/*.tsx` - 各个组件
- `types.ts` - TypeScript 类型定义
- `package.json` - 依赖包

### 3. 创建项目结构 (2 分钟)
```bash
# 创建路由目录
mkdir -p "src/app/[locale]/(default)/${routeName}"

# 创建组件目录
mkdir -p "src/components/${routeName}"
```

### 4. 组件迁移清单

#### 必须创建的组件：
- `${ComponentPrefix}Header.tsx` - 导航栏（固定顶部，响应式）
- `${ComponentPrefix}Hero.tsx` - 英雄区（大标题，CTA 按钮）
- `${ComponentPrefix}Footer.tsx` - 页脚
- `${ComponentPrefix}LandingSections.tsx` - 落地页所有部分（Features, FAQ, CTA 等）

#### 可选组件（根据原 UI 决定）：
- `${ComponentPrefix}Gallery.tsx` - 画廊展示
- `${ComponentPrefix}Pricing.tsx` - 价格方案
- `${ComponentPrefix}Generator.tsx` - 生成器/工具页面
- 其他特定功能组件

### 5. 组件转换规则

#### 5.1 基础转换
```typescript
// 原始代码（AI Studio）
import { Button } from './Button';

// 转换为（我们的项目）
// 如果原组件简单，直接内联样式
<button className="px-6 py-3 bg-gradient-to-r from-violet-600...">
```

#### 5.2 移除外部依赖
- **不引入** AI Studio 的 API 服务（`services/` 目录）
- **不引入** 自定义类型（如 `TattooStyle` enum）
- **简化为** 简单的字符串数组或 mock 数据

#### 5.3 图片处理
```typescript
// 使用占位图
src="https://picsum.photos/400/600?random={id}"

// 或使用项目内图片
src="/images/${routeName}/example.jpg"
```

### 6. 创建主页面 (5 分钟)

**文件**: `src/app/[locale]/(default)/${routeName}/page.tsx`

```typescript
"use client";

import React, { useState } from 'react';
import { ${ComponentPrefix}Header } from '@/components/${routeName}/${ComponentPrefix}Header';
import { ${ComponentPrefix}Hero } from '@/components/${routeName}/${ComponentPrefix}Hero';
// ... 其他导入

export default function ${ComponentPrefix}Page() {
  const [currentPage, setCurrentPage] = useState('home');

  const goToGenerator = () => {
    setCurrentPage('generate');
    if (typeof window !== 'undefined') {
      window.scrollTo({ top: 0, behavior: 'smooth' });
    }
  };

  const renderPage = () => {
    switch (currentPage) {
      case 'home':
        return (
          <>
            <${ComponentPrefix}Hero onStart={goToGenerator} />
            {/* 其他落地页组件 */}
          </>
        );
      case 'generate':
        return <${ComponentPrefix}Generator />;
      // 其他页面
      default:
        return <${ComponentPrefix}Hero onStart={goToGenerator} />;
    }
  };

  return (
    <div className="min-h-screen bg-black text-white">
      <${ComponentPrefix}Header onNavigate={setCurrentPage} currentPage={currentPage} />
      <main>{renderPage()}</main>
      <${ComponentPrefix}Footer />
    </div>
  );
}
```

### 7. UI 样式迁移指南

#### 7.1 保留的设计元素
- ✅ 整体配色方案（背景色、主色调、渐变）
- ✅ 字体大小、粗细、行高
- ✅ 间距、内边距、外边距
- ✅ 圆角、阴影、边框
- ✅ 动画效果（hover, transition）
- ✅ 响应式断点

#### 7.2 常见样式模式

**黑色主题**：
```typescript
className="min-h-screen bg-black text-white"
```

**紫色/粉色渐变**：
```typescript
className="bg-gradient-to-r from-violet-600 to-indigo-600"
className="text-transparent bg-clip-text bg-gradient-to-r from-violet-400 to-white"
```

**玻璃态效果**：
```typescript
className="bg-white/5 backdrop-blur-md border border-white/10"
```

**卡片悬停效果**：
```typescript
className="hover:border-violet-500/50 hover:-translate-y-2 transition-all duration-500"
```

### 8. SEO 优化（重要！）

在 `page.tsx` 顶部添加 SEO 注释：
```typescript
// SEO Metadata
// Title: 主标题 | 品牌名
// Description: 详细描述，包含关键词
// Keywords: 关键词1, 关键词2, 关键词3
```

**关键词策略**：
- 主关键词出现在 H1 标题中
- 长尾关键词分布在描述文本中
- 包含位置词（arm, chest, sleeve 等）
- 包含动作词（create, design, generate 等）

### 9. 测试清单

#### 功能测试：
- [ ] 页面导航切换正常
- [ ] 按钮点击响应正确
- [ ] 滚动动画正常触发
- [ ] 表单输入验证工作

#### 响应式测试：
- [ ] 桌面端布局正常（1920px+）
- [ ] 平板端布局正常（768px-1024px）
- [ ] 移动端布局正常（320px-767px）
- [ ] 导航栏在移动端显示汉堡菜单

#### 兼容性测试：
- [ ] Chrome/Edge 正常
- [ ] Firefox 正常
- [ ] Safari 正常

### 10. 完成输出

完成后提供：
```
✅ 新路由创建完成：/${routeName}

📂 创建的文件：
- src/app/[locale]/(default)/${routeName}/page.tsx
- src/components/${routeName}/${ComponentPrefix}Header.tsx
- src/components/${routeName}/${ComponentPrefix}Hero.tsx
- src/components/${routeName}/${ComponentPrefix}Footer.tsx
- ... (其他组件)

🔗 访问地址：
- http://localhost:3000/${routeName}
- http://localhost:3000/zh/${routeName}

🎨 UI 特点：
- 配色：[描述配色方案]
- 风格：[描述设计风格]
- 动画：[描述动画效果]

📝 注意事项：
- 原首页保持不变（/）
- 新页面完全独立运行
- 不依赖原项目认证系统
```

## 常见问题处理

### Q1: 组件依赖外部 API
**解决**: 使用 mock 数据或 `setTimeout` 模拟异步操作

```typescript
// 替代真实 API 调用
setTimeout(() => {
  setGeneratedImage("https://picsum.photos/800/800?random=" + Date.now());
  setIsGenerating(false);
}, 3000);
```

### Q2: 使用了项目不支持的库
**解决**: 查找替代方案或重写组件

```typescript
// 如果使用了特殊图标库，改用 lucide-react
import { Star, Heart, ChevronDown } from 'lucide-react';
```

### Q3: TypeScript 类型错误
**解决**: 定义简单的 interface 或使用 any（临时）

```typescript
interface Props {
  onStart: () => void;
  className?: string;
}
```

### Q4: 原项目有复杂的状态管理
**解决**: 简化为 useState，不引入 Redux/Zustand

```typescript
const [currentPage, setCurrentPage] = useState('home');
const [isLoading, setIsLoading] = useState(false);
```

## 优化建议

### 性能优化：
1. **图片懒加载**: 添加 `loading="lazy"` 属性
2. **代码分割**: 大组件使用 `dynamic` 动态导入
3. **CSS 优化**: 避免过度嵌套和复杂选择器

### SEO 优化：
1. **语义化标签**: 使用 `<header>`, `<nav>`, `<main>`, `<footer>`, `<article>`
2. **Alt 文本**: 所有图片添加描述性 alt 属性
3. **结构化数据**: 考虑添加 JSON-LD schema

### 可访问性：
1. **键盘导航**: 确保所有交互元素可用 Tab 键访问
2. **ARIA 标签**: 添加 `aria-label`, `aria-labelledby`
3. **颜色对比**: 确保文本和背景对比度至少 4.5:1

## 时间估算

| 步骤 | 预计时间 |
|------|---------|
| 解压和分析 | 5 分钟 |
| 创建目录结构 | 2 分钟 |
| Header 组件 | 5 分钟 |
| Hero 组件 | 5 分钟 |
| Landing Sections | 10 分钟 |
| 其他组件（3-5个） | 15-25 分钟 |
| 主页面整合 | 5 分钟 |
| 测试和调试 | 10 分钟 |
| **总计** | **45-60 分钟** |

## 下次使用指令

当用户提供新的 UI 压缩包时，直接说：

```
使用 integrate-ui-package skill，参数：
- zipPath: [压缩包路径]
- routeName: [路由名]
- componentPrefix: [组件前缀]
```

示例：
```
使用 integrate-ui-package skill，参数：
- zipPath: /Users/xxx/Downloads/portfolio-design.zip
- routeName: portfolio
- componentPrefix: Portfolio
```
