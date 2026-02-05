import { Router } from 'express';
import { submitQuestion } from './handlers';
import { optionalAuthenticate } from '../../middleware/optional-auth';

/**
 * QnA 라우터
 * 사용자 질문을 GitHub Issues로 자동 등록하는 API를 제공합니다
 */
const router = Router();

/**
 * 질문 제출 (선택적 인증)
 * @route POST /qna/questions
 * @access Public (익명 사용자 허용)
 * @param {string} appCode - 앱 코드 (필수)
 * @param {string} title - 질문 제목 (필수, 1-256자)
 * @param {string} body - 질문 본문 (필수, 1-65536자)
 * @returns {201} questionId, issueNumber, issueUrl, createdAt
 * @returns {400} 입력 검증 실패
 * @returns {404} 앱 또는 QnA 설정을 찾을 수 없음
 * @returns {502} GitHub API 호출 실패
 */
router.post('/questions', optionalAuthenticate, submitQuestion);

export default router;
