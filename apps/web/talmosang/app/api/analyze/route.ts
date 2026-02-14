import { NextRequest, NextResponse } from 'next/server';
import type { AnalysisResult } from '@/types/analysis';
import { ERROR_MESSAGES } from '@/lib/errors';

const GEMINI_API_KEY = process.env.GEMINI_API_KEY;
const GEMINI_VISION_ENDPOINT =
  'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

/**
 * 두피 분석 프롬프트 (사극 말투 + 유머)
 */
const ANALYSIS_PROMPT = `너는 영화 "관상"에 나올 법한 전설적인 탈모 관상가야.
업로드된 사진을 보고 사극 말투 + 유머를 섞어서 모발 상태를 판결해줘.
이건 의료 진단이 아니라 100% 재미/엔터테인먼트 목적이야.

영화 "관상"의 "내가 왕이 될 상인가?" 대사를 패러디해서,
"내가 탈모가 될 상인가?"에 대한 답변을 내려주는 컨셉이야.
사극풍 말투(~이로다, ~하도다, ~이니라, 그대, ~하였느니라 등)를 자연스럽게 섞되 너무 딱딱하지 않게.

사진이 두피/머리카락이 아니더라도, 사진 속 어떤 요소든 창의적으로 연결해서 재미있게 분석해줘.
예를 들어 고양이 사진이면 "이 고양이의 털 기운으로 보아..." 식으로.

반드시 아래 JSON 형식으로만 응답해. 다른 텍스트는 절대 포함하지 마.

{
  "grade": "숲" | "풀밭" | "사막" | "바위" 중 하나,
  "gradeEmoji": "🌳" | "🌿" | "🏜️" | "🪨" 중 grade에 맞는 것,
  "gradeVerdict": "관상 판결문 한 줄 (사극 말투)",
  "hairAge": 모발 추정 나이 (숫자, 20~80),
  "baldProbability5yr": 5년 내 탈모 확률 (숫자, 0~100),
  "baldType": "M자" | "O자" | "정수리" | "원형" | "해당없음" 중 하나,
  "celebrity": {
    "name": "닮은 대머리 유명인 이름",
    "comment": "사극풍 유머 코멘트"
  },
  "tips": ["사극풍 관리팁1", "사극풍 관리팁2", "사극풍 관리팁3"],
  "comment": "종합 판결 2~3문장 (사극 말투)",
  "imagePrompt": "10년 뒤 헤어라인 시뮬레이션 영어 프롬프트"
}`;

/**
 * POST /api/analyze
 *
 * 두피 이미지를 Gemini 2.5 Flash Vision API로 분석합니다.
 */
export async function POST(req: NextRequest) {
  // API 키 확인
  if (!GEMINI_API_KEY) {
    return NextResponse.json(
      { error: ERROR_MESSAGES.API_KEY_MISSING },
      { status: 500 }
    );
  }

  try {
    const { image, mimeType } = await req.json();

    // 요청 페이로드 생성
    const payload = {
      contents: [
        {
          parts: [
            {
              text: ANALYSIS_PROMPT,
            },
            {
              inline_data: {
                mime_type: mimeType,
                data: image,
              },
            },
          ],
        },
      ],
      generationConfig: {
        temperature: 1.0,
        responseMimeType: 'application/json',
      },
    };

    // Gemini API 호출
    const response = await fetch(`${GEMINI_VISION_ENDPOINT}?key=${GEMINI_API_KEY}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    });

    if (!response.ok) {
      const errorData = await response.json();
      console.error('Gemini API 오류:', errorData);

      // Rate Limit 에러 처리
      if (response.status === 429) {
        return NextResponse.json({ error: ERROR_MESSAGES.RATE_LIMIT }, { status: 429 });
      }

      throw new Error('Gemini API 호출 실패');
    }

    // 응답 파싱
    const data = await response.json();
    const resultText = data.candidates?.[0]?.content?.parts?.[0]?.text;

    if (!resultText) {
      throw new Error('Gemini API 응답 형식 오류');
    }

    const analysisResult: AnalysisResult = JSON.parse(resultText);

    return NextResponse.json(analysisResult);
  } catch (error) {
    console.error('분석 오류:', error);

    // 네트워크 오류
    if (error instanceof TypeError && error.message.includes('fetch')) {
      return NextResponse.json({ error: ERROR_MESSAGES.NETWORK_ERROR }, { status: 503 });
    }

    // 일반 오류
    return NextResponse.json({ error: ERROR_MESSAGES.API_ERROR }, { status: 500 });
  }
}
