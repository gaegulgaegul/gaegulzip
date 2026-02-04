import { Router } from 'express';
import * as handlers from './handlers';
import { authenticate } from '../../middleware/auth';

/**
 * WOD 라우터
 */
const router = Router();

// 모든 WOD 엔드포인트는 인증 필요
router.use(authenticate);

/**
 * WOD 등록
 * @route POST /wods
 */
router.post('/', handlers.registerWodHandler);

/**
 * 날짜별 WOD 조회
 * @route GET /wods/:boxId/:date
 */
router.get('/:boxId/:date', handlers.getWodsByDateHandler);

/**
 * 변경 제안 생성
 * @route POST /wods/proposals
 */
router.post('/proposals', handlers.createProposalHandler);

/**
 * 변경 승인
 * @route POST /wods/proposals/:proposalId/approve
 */
router.post('/proposals/:proposalId/approve', handlers.approveProposalHandler);

/**
 * 변경 거부
 * @route POST /wods/proposals/:proposalId/reject
 */
router.post('/proposals/:proposalId/reject', handlers.rejectProposalHandler);

/**
 * WOD 선택
 * @route POST /wods/:wodId/select
 */
router.post('/:wodId/select', handlers.selectWodHandler);

/**
 * 내 WOD 선택 기록 조회
 * @route GET /wods/selections
 */
router.get('/selections', handlers.getSelectionsHandler);

export default router;
