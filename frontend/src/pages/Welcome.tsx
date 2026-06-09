import { useState, useEffect } from 'react';
import { Layout, Card, Typography, Button, Space, Spin, Tag, Row, Col } from 'antd';
import {
  RocketOutlined,
  ApiOutlined,
  DatabaseOutlined,
  SettingOutlined,
  GithubOutlined,
  CheckCircleOutlined,
  CloseCircleOutlined,
} from '@ant-design/icons';
import axios from 'axios';
import styles from './Welcome.module.css';

const { Header, Content, Footer } = Layout;
const { Title, Paragraph, Text } = Typography;

interface BackendStatus {
  message: string;
  backend: string;
  serverTime: string;
  database: string;
}

/** 技术栈配置 */
const TECH_STACKS = [
  { icon: ApiOutlined, className: styles.techIconSpring, title: 'Spring Boot 3.x', desc: '后端框架，RESTful API' },
  { icon: RocketOutlined, className: styles.techIconReact, title: 'React 18', desc: '前端框架，组件化开发' },
  { icon: SettingOutlined, className: styles.techIconAntd, title: 'Ant Design 5', desc: 'UI 组件库，开箱即用' },
  { icon: DatabaseOutlined, className: styles.techIconMysql, title: 'MySQL / H2', desc: '数据库，H2 默认，MySQL 可选' },
];

/** 快速开始步骤 */
const QUICK_STEPS = [
  { title: '1\uFE0F\u20E3 配置数据库', items: ['默认使用 H2 内存数据库，无需安装', '如需 MySQL，编辑 dev.sh 将 DB_MODE 改为 mysql'] },
  { title: '2\uFE0F\u20E3 启动项目', items: ['在项目根目录执行：', './dev.sh start', '一键启动所有服务'] },
  { title: '3\uFE0F\u20E3 开始开发', items: ['前端：cd frontend && npm run dev', '后端：cd backend && ./mvnw spring-boot:run', '使用 Qoder 打开项目，开始 AI 编码'] },
];

export default function Welcome() {
  const [status, setStatus] = useState<BackendStatus | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchStatus();
  }, []);

  const fetchStatus = async () => {
    setLoading(true);
    setError(null);
    try {
      const res = await axios.get<BackendStatus>('/api/hello');
      setStatus(res.data);
    } catch {
      setError('后端服务未启动，请先运行后端项目');
    } finally {
      setLoading(false);
    }
  };

  const dbConnected = status?.database?.startsWith('连接成功');

  return (
    <Layout className={styles.layout}>
      <Header className={styles.header}>
        <RocketOutlined className={styles.headerIcon} />
        <Title level={4} className={styles.headerTitle}>AI 项目脚手架</Title>
      </Header>

      <Content className={styles.content}>
        {/* 欢迎区域 */}
        <div className={styles.heroSection}>
          <Title className={styles.heroTitle}>
            <RocketOutlined className={styles.heroIcon} />
            欢迎使用 AI 项目脚手架
          </Title>
          <Paragraph className={styles.heroDesc}>
            这是一个开箱即用的项目模板，集成了 Spring Boot + React + Ant Design，
            <br />
            让你可以快速开始 AI 辅助的全栈开发。
          </Paragraph>
        </div>

        {/* 技术栈卡片 */}
        <Row gutter={[24, 24]} className={styles.techCards}>
          {TECH_STACKS.map((tech) => (
            <Col key={tech.title} xs={24} sm={12} md={6}>
              <Card hoverable>
                <div className={styles.techCardBody}>
                  <tech.icon className={`${styles.techIcon} ${tech.className}`} />
                  <Title level={4} className={styles.techTitle}>{tech.title}</Title>
                  <Text type="secondary">{tech.desc}</Text>
                </div>
              </Card>
            </Col>
          ))}
        </Row>

        {/* 后端连接状态 */}
        <Card
          className={styles.statusCard}
          title={<Space><ApiOutlined /><span>后端服务状态</span></Space>}
          extra={<Button type="primary" size="small" onClick={fetchStatus} loading={loading}>刷新状态</Button>}
        >
          {loading ? (
            <div className={styles.statusLoading}>
              <Spin tip="正在检测后端服务..." />
            </div>
          ) : error ? (
            <div className={styles.statusError}>
              <CloseCircleOutlined className={styles.statusErrorIcon} />
              <Paragraph className={styles.statusErrorText}>{error}</Paragraph>
            </div>
          ) : status ? (
            <Row gutter={[24, 16]}>
              <Col span={12}>
                <Card size="small" type="inner" title="服务状态">
                  <Tag icon={<CheckCircleOutlined />} color="success">{status.backend}</Tag>
                </Card>
              </Col>
              <Col span={12}>
                <Card size="small" type="inner" title="服务器时间">
                  <Text code>{status.serverTime}</Text>
                </Card>
              </Col>
              <Col span={24}>
                <Card size="small" type="inner" title="数据库状态">
                  <Tag
                    icon={dbConnected ? <CheckCircleOutlined /> : <CloseCircleOutlined />}
                    color={dbConnected ? 'success' : 'error'}
                  >
                    {status.database}
                  </Tag>
                </Card>
              </Col>
            </Row>
          ) : null}
        </Card>

        {/* 快速开始指引 */}
        <Card title={<Space><RocketOutlined /><span>快速开始</span></Space>}>
          <Row gutter={[24, 16]}>
            {QUICK_STEPS.map((step) => (
              <Col key={step.title} xs={24} md={8}>
                <Card size="small" type="inner" title={step.title}>
                  <ul className={styles.stepList}>
                    {step.items.map((item, i) => (
                      <li key={i}>
                        {item === './dev.sh start'
                          ? <Text code copyable>{item}</Text>
                          : item}
                      </li>
                    ))}
                  </ul>
                </Card>
              </Col>
            ))}
          </Row>
        </Card>
      </Content>

      <Footer className={styles.footer}>
        <Space>
          <GithubOutlined />
          <Text type="secondary">AI 项目脚手架 - 让 AI 编程更简单</Text>
        </Space>
      </Footer>
    </Layout>
  );
}
