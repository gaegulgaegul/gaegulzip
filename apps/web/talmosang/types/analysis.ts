/**
 * 두피 분석 요청
 */
export interface AnalyzeRequest {
  /** Base64 인코딩된 이미지 */
  image: string;
  /** 이미지 MIME 타입 */
  mimeType: string;
}

/**
 * 두피 분석 결과
 */
export interface AnalysisResult {
  /** 모발 등급 */
  grade: string;

  /** 등급 이모지 (🌳, 🌿, 🏜️, 🪨) */
  gradeEmoji: string;

  /** 등급 판결문 (사극 말투) */
  gradeVerdict: string;

  /** 모발 추정 나이 */
  hairAge: number;

  /** 5년 내 탈모 확률 (0-100) */
  baldProbability5yr: number;

  /** 탈모 유형 */
  baldType: string;

  /** 닮은 대머리 유명인 */
  celebrity: {
    name: string;
    comment: string;
  };

  /** 관리 팁 (사극 말투) */
  tips: string[];

  /** 종합 판결 (사극 말투) */
  comment: string;

  /** 10년 뒤 헤어라인 시뮬레이션 프롬프트 (영어) */
  imagePrompt: string;

  /** 10년 뒤 시뮬레이션 이미지 (옵셔널) */
  simulationImage?: string | null;
}

/**
 * 이미지 생성 요청
 */
export interface GenerateImageRequest {
  /** 이미지 생성 프롬프트 (영어) */
  prompt: string;
}

/**
 * 이미지 생성 응답
 */
export interface GenerateImageResponse {
  /** 생성된 이미지 (data URI 형식) */
  image: string | null;
  /** 에러 메시지 (옵셔널) */
  error?: string;
}
