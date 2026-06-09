import { Routes, Route, Navigate } from 'react-router-dom';
import Welcome from '../pages/Welcome';

/**
 * 应用路由配置
 * 
 * 新增页面只需在此处添加 Route 即可
 */
export default function AppRouter() {
  return (
    <Routes>
      <Route path="/" element={<Welcome />} />
      {/* 更多页面路由在此添加 */}
      {/* <Route path="/example" element={<Example />} /> */}

      {/* 404 - 未匹配的路由重定向到首页 */}
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}
