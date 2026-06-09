---
name: frontend-coding-standards
description: React 前端编码规范：禁止行内样式，使用 CSS Module，全局 reset.css，Vite 代理配置规范
glob: frontend/**
alwaysApply: true
---

# 前端编码规范

## 样式规范（最高优先级）

### ❌ 禁止行内样式
**任何情况下都不得使用 `style={{...}}` 内联样式。** 所有样式必须写在 `.module.css` 或 `.css` 文件中。

```tsx
// ❌ 错误
<div style={{ textAlign: 'center', padding: 24 }}>

// ✅ 正确
import styles from './Component.module.css';
<div className={styles.container}>
```

### CSS Module 命名
- 页面级组件：`PageName.module.css`，与 `.tsx` 文件同级
- 组件级：`ComponentName.module.css`

### 全局样式
- 放在 `src/styles/` 目录
- `reset.css`：浏览器默认样式清除（`* { margin: 0; padding: 0; box-sizing: border-box }`）
- 在 `main.tsx` 中 `import './styles/reset.css'` 全局引入
- 禁止在 `index.html` 中写 `<style>` 标签

### UI 组件
- 必须使用 Ant Design 5.x 组件（antd）
- 图标使用 `@ant-design/icons`
- 中文环境：`<ConfigProvider locale={zhCN}>`

## Vite 配置规范

```ts
server: {
  port: 3000,
  host: '0.0.0.0',   // 局域网可访问
  open: true,          // 自动打开浏览器
  proxy: {
    '/api': {
      target: 'http://localhost:8080',
      changeOrigin: true,
    },
  },
},
```

## 路由
- 使用 `react-router-dom` v6
- 新增页面在 `src/router/index.tsx` 中添加 `<Route>`
- 未匹配路由重定向到首页：`<Route path="*" element={<Navigate to="/" replace />} />`
