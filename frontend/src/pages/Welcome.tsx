import { useState, useEffect } from 'react';
import { Layout, Card, Typography, Button, Space, Spin, Tag, Row, Col } from 'antd';
import {
  RocketOutlined,
  ApiOutlined,
  GithubOutlined,
  CheckCircleOutlined,
  CloseCircleOutlined,
  RobotOutlined,
  ToolOutlined,
  CodeOutlined,
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

/** Qoder 对话示例 */
const QODER_EXAMPLES = [
  { icon: RocketOutlined, prompt: '启动项目' },
  { icon: ToolOutlined, prompt: '安装环境' },
  { icon: CodeOutlined, prompt: '开发一个登录页' },
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

        {/* Qoder 对话指引 */}
        <Card
          title={<Space><RobotOutlined /><span>与 Qoder 对话，一切交给我</span></Space>}
          className={styles.qoderCard}
        >
          <Paragraph type="secondary" className={styles.qoderDesc}>
            在 Qoder 对话框中直接说出你的需求，就像和同事聊天一样简单。
          </Paragraph>
          <Row gutter={[24, 16]}>
            {QODER_EXAMPLES.map((example) => (
              <Col key={example.prompt} xs={24} sm={8} md={8}>
                <Card size="small" hoverable className={styles.qoderExampleCard}>
                  <div className={styles.qoderExampleBody}>
                    <example.icon className={styles.qoderExampleIcon} />
                    <Text type="secondary" className={styles.qoderInputHint}>Qoder里直接输入：</Text>
                    <Text code className={styles.qoderPromptText}>"{example.prompt}"</Text>
                  </div>
                </Card>
              </Col>
            ))}
          </Row>
        </Card>

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
