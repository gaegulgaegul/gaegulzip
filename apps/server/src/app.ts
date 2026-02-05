import 'dotenv/config';
import express from 'express';
import swaggerUi from 'swagger-ui-express';
import YAML from 'yamljs';
import authRouter from './modules/auth';
import pushAlertRouter from './modules/push-alert';
import qnaRouter from './modules/qna';
import noticeRouter from './modules/notice';
import { authenticate } from './middleware/auth';
import { errorHandler } from './middleware/error-handler';

export const app = express();

// Middleware
app.use(express.json());

// Swagger UI (OpenAPI Documentation)
const swaggerDocument = YAML.load('./docs/openapi.yaml');
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocument, {
  customCss: '.swagger-ui .topbar { display: none }',
  customSiteTitle: 'gaegulzip-server API',
}));

// Routes
app.get('/', (req, res) => {
  res.json({ message: 'gaegulzip-server API', version: '1.0.0' });
});

app.get('/health', (req, res) => {
  res.json({ status: 'OK', uptime: process.uptime() });
});

app.use('/auth', authRouter);
app.use('/push', pushAlertRouter);
app.use('/qna', qnaRouter);
app.use('/notices', authenticate, noticeRouter);

// Error handling (must be last)
app.use(errorHandler);
