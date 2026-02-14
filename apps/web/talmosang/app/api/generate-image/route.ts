import { NextRequest, NextResponse } from 'next/server';
import type { GenerateImageResponse } from '@/types/analysis';
import { ERROR_MESSAGES } from '@/lib/errors';

const GEMINI_API_KEY = process.env.GEMINI_API_KEY;
const GEMINI_IMAGE_ENDPOINT =
  'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent';

/**
 * POST /api/generate-image
 *
 * Gemini 2.0 Flash Exp API로 10년 뒤 헤어라인 시뮬레이션 이미지를 생성합니다.
 */
export async function POST(req: NextRequest) {
  // API 키 확인
  if (!GEMINI_API_KEY) {
    return NextResponse.json(
      { image: null, error: ERROR_MESSAGES.API_KEY_MISSING } satisfies GenerateImageResponse,
      { status: 500 }
    );
  }

  try {
    const { prompt } = await req.json();

    // 요청 페이로드 생성
    const payload = {
      contents: [
        {
          parts: [
            {
              text: prompt,
            },
          ],
        },
      ],
      generationConfig: {
        responseModalities: ['TEXT', 'IMAGE'],
      },
    };

    // Gemini API 호출
    const response = await fetch(`${GEMINI_IMAGE_ENDPOINT}?key=${GEMINI_API_KEY}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    });

    if (!response.ok) {
      console.error('Gemini 이미지 생성 실패:', await response.text());
      return NextResponse.json(
        { image: null, error: ERROR_MESSAGES.IMAGE_GENERATION_FAILED } satisfies GenerateImageResponse,
        { status: 500 }
      );
    }

    // 응답 파싱
    const data = await response.json();
    const imagePart = data.candidates?.[0]?.content?.parts?.find(
      (part: any) => part.inline_data
    );

    if (!imagePart) {
      return NextResponse.json(
        { image: null, error: ERROR_MESSAGES.IMAGE_GENERATION_FAILED } satisfies GenerateImageResponse,
        { status: 500 }
      );
    }

    // Base64 이미지를 data URI로 변환
    const imageBase64 = imagePart.inline_data.data;
    const mimeType = imagePart.inline_data.mime_type || 'image/png';
    const imageUrl = `data:${mimeType};base64,${imageBase64}`;

    return NextResponse.json({ image: imageUrl } satisfies GenerateImageResponse);
  } catch (error) {
    console.error('이미지 생성 오류:', error);

    // 네트워크 오류
    if (error instanceof TypeError && error.message.includes('fetch')) {
      return NextResponse.json(
        { image: null, error: ERROR_MESSAGES.NETWORK_ERROR } satisfies GenerateImageResponse,
        { status: 503 }
      );
    }

    // 일반 오류
    return NextResponse.json(
      { image: null, error: ERROR_MESSAGES.IMAGE_GENERATION_FAILED } satisfies GenerateImageResponse,
      { status: 500 }
    );
  }
}
