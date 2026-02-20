import type { Metadata } from 'next';
import Link from 'next/link';
import { Card } from '@/components/ui/card';

export const metadata: Metadata = {
  title: '개인정보처리방침 - 탈모상',
  description:
    '탈모상 서비스의 개인정보 보호 정책을 안내합니다. AI 두피 분석 서비스 탈모상의 데이터 처리 방침.',
  alternates: {
    canonical: 'https://talmosang.vercel.app/privacy',
  },
  openGraph: {
    title: '개인정보처리방침 - 탈모상',
    description: '탈모상 서비스의 개인정보 보호 정책을 안내합니다.',
    type: 'website',
    url: 'https://talmosang.vercel.app/privacy',
    locale: 'ko_KR',
  },
};

/**
 * 개인정보처리방침 페이지
 *
 * AdSense 필수 정책 페이지입니다.
 * 이미지는 서버에 저장하지 않으며, Google AdSense 및 Analytics 쿠키 정책을 포함합니다.
 */
const LAST_UPDATED = '2026년 2월 20일';

export default function PrivacyPage() {
  return (
    <main className="container mx-auto px-6 py-12 max-w-4xl">
      {/* 제목 */}
      <header className="text-center mb-12">
        <h1 className="font-nanum-pen text-5xl md:text-6xl text-charcoal rotate-[-1deg] mb-4">
          개인정보처리방침
          <div className="scribble-underline" />
        </h1>
        <p className="text-lg text-charcoal/70">
          탈모상 서비스의 개인정보 보호 정책을 안내하옵니다
        </p>
      </header>

      {/* 내용 카드 */}
      <Card className="paper-texture pencil-border p-8 md:p-12 space-y-8">
        {/* 1. 서비스 소개 */}
        <section>
          <h2 className="font-nanum-pen text-3xl text-charcoal mb-4">
            1. 서비스 소개
          </h2>
          <p className="text-charcoal/80 leading-relaxed">
            &ldquo;탈모상&rdquo;(이하 &ldquo;서비스&rdquo;)은 AI 기술을 활용하여
            두피 사진을 재미있게 분석하는 엔터테인먼트 웹 서비스입니다. 본
            서비스는 의료 진단이 아니며, 순수 재미 목적으로만 제공됩니다.
          </p>
        </section>

        {/* 2. 수집하지 않는 정보 */}
        <section>
          <h2 className="font-nanum-pen text-3xl text-charcoal mb-4">
            2. 수집하지 않는 정보
          </h2>
          <p className="text-charcoal/80 leading-relaxed mb-3">
            본 서비스는 사용자의 개인정보를 <strong>수집하지 않습니다</strong>:
          </p>
          <ul className="list-disc list-inside space-y-2 text-charcoal/80 ml-4">
            <li>업로드한 사진은 분석 후 즉시 삭제되며, 서버에 저장되지 않습니다</li>
            <li>사용자의 이름, 이메일, 전화번호 등 개인 식별 정보를 수집하지 않습니다</li>
            <li>회원가입이 필요하지 않으며, 로그인 정보를 저장하지 않습니다</li>
          </ul>
        </section>

        {/* 3. 쿠키 및 추적 기술 */}
        <section>
          <h2 className="font-nanum-pen text-3xl text-charcoal mb-4">
            3. 쿠키 및 추적 기술
          </h2>
          <p className="text-charcoal/80 leading-relaxed mb-3">
            본 서비스는 다음의 쿠키 및 추적 기술을 사용합니다:
          </p>

          <div className="space-y-4">
            <div className="bg-cream-light p-4 rounded-lg">
              <h3 className="font-noto-sans-kr font-bold text-lg mb-2">
                Google AdSense
              </h3>
              <p className="text-charcoal/80 leading-relaxed">
                광고를 표시하기 위해 Google AdSense를 사용합니다. Google은 쿠키를
                사용하여 사용자의 관심사에 맞는 광고를 표시합니다. 사용자는
                Google 광고 설정에서 맞춤 광고를 비활성화할 수 있습니다.
              </p>
              <a
                href="https://policies.google.com/technologies/ads"
                target="_blank"
                rel="noopener noreferrer"
                className="text-deep-blue underline hover:no-underline mt-2 inline-block"
              >
                Google 광고 정책 보기 →
              </a>
            </div>

            <div className="bg-cream-light p-4 rounded-lg">
              <h3 className="font-noto-sans-kr font-bold text-lg mb-2">
                Google Analytics (옵셔널)
              </h3>
              <p className="text-charcoal/80 leading-relaxed">
                서비스 개선을 위해 Google Analytics를 사용할 수 있습니다. 익명화된
                사용 통계(페이지 조회수, 방문 시간 등)만 수집되며, 개인을 식별할
                수 있는 정보는 포함되지 않습니다.
              </p>
              <a
                href="https://policies.google.com/privacy"
                target="_blank"
                rel="noopener noreferrer"
                className="text-deep-blue underline hover:no-underline mt-2 inline-block"
              >
                Google 개인정보처리방침 보기 →
              </a>
            </div>
          </div>
        </section>

        {/* 4. 이미지 처리 */}
        <section>
          <h2 className="font-nanum-pen text-3xl text-charcoal mb-4">
            4. 이미지 처리
          </h2>
          <p className="text-charcoal/80 leading-relaxed mb-3">
            업로드한 사진의 처리 과정:
          </p>
          <ol className="list-decimal list-inside space-y-2 text-charcoal/80 ml-4">
            <li>
              사용자가 업로드한 사진은 브라우저에서 리사이즈 후
              Base64 형식으로 인코딩됩니다
            </li>
            <li>
              인코딩된 이미지는 서비스 서버를 경유하여 Google Gemini API로
              전송되어 분석됩니다
            </li>
            <li>
              서비스 서버는 이미지를 일시적으로 중계만 하며, 분석이 완료되면
              즉시 폐기합니다. 별도의 서버나 데이터베이스에 저장하지 않습니다
            </li>
            <li>
              Google Gemini API의 데이터 처리 정책은{' '}
              <a
                href="https://ai.google.dev/gemini-api/terms"
                target="_blank"
                rel="noopener noreferrer"
                className="text-deep-blue underline hover:no-underline"
              >
                Gemini API 약관
              </a>
              을 참조하시기 바랍니다
            </li>
          </ol>
        </section>

        {/* 5. 제3자 서비스 */}
        <section>
          <h2 className="font-nanum-pen text-3xl text-charcoal mb-4">
            5. 제3자 서비스
          </h2>
          <p className="text-charcoal/80 leading-relaxed mb-3">
            본 서비스는 다음의 제3자 서비스를 사용합니다:
          </p>
          <ul className="list-disc list-inside space-y-2 text-charcoal/80 ml-4">
            <li>
              <strong>Google Gemini API</strong>: 두피 이미지 분석 및 시뮬레이션 이미지 생성
            </li>
            <li>
              <strong>Google AdSense</strong>: 광고 표시
            </li>
            <li>
              <strong>Vercel</strong>: 웹 호스팅 서비스
            </li>
          </ul>
        </section>

        {/* 6. 사용자 권리 */}
        <section>
          <h2 className="font-nanum-pen text-3xl text-charcoal mb-4">
            6. 사용자 권리
          </h2>
          <p className="text-charcoal/80 leading-relaxed mb-3">
            본 서비스는 직접적인 개인정보를 수집하지 않으나, 제3자
            서비스(Google AdSense)가 광고 목적으로 쿠키를 통해 이용자 데이터를
            수집할 수 있습니다. 사용자는 다음과 같은 권리를 행사할 수 있습니다:
          </p>
          <ul className="list-disc list-inside space-y-2 text-charcoal/80 ml-4">
            <li>브라우저 설정에서 쿠키를 삭제하거나 차단할 수 있습니다</li>
            <li>
              <a
                href="https://adssettings.google.com"
                target="_blank"
                rel="noopener noreferrer"
                className="text-deep-blue underline hover:no-underline"
              >
                Google 광고 설정
              </a>
              에서 맞춤 광고를 비활성화할 수 있습니다
            </li>
            <li>관련 법령에 따라 개인정보 열람·정정·삭제를 요청할 수 있습니다</li>
          </ul>
        </section>

        {/* 7. 면책 사항 */}
        <section>
          <h2 className="font-nanum-pen text-3xl text-charcoal mb-4">
            7. 면책 사항
          </h2>
          <div className="bg-coral/10 border-2 border-coral rounded-lg p-6">
            <p className="text-charcoal/80 leading-relaxed">
              <strong className="text-coral">중요:</strong> 본 서비스는{' '}
              <strong>의료 진단이 아니며</strong>, 순수 재미 목적의
              엔터테인먼트 콘텐츠입니다. 실제 두피 상태나 탈모 진단이 필요한
              경우, 반드시 의료 전문가와 상담하시기 바랍니다.
            </p>
          </div>
        </section>

        {/* 8. 정책 변경 */}
        <section>
          <h2 className="font-nanum-pen text-3xl text-charcoal mb-4">
            8. 정책 변경
          </h2>
          <p className="text-charcoal/80 leading-relaxed">
            본 개인정보처리방침은 법령 또는 서비스 정책 변경에 따라 수정될 수
            있습니다. 변경 시 본 페이지를 통해 공지합니다.
          </p>
          <p className="text-charcoal/70 text-sm mt-4">
            최종 업데이트: {LAST_UPDATED}
          </p>
        </section>

        {/* 9. 문의 */}
        <section>
          <h2 className="font-nanum-pen text-3xl text-charcoal mb-4">
            9. 문의
          </h2>
          <p className="text-charcoal/80 leading-relaxed">
            본 개인정보처리방침에 대한 문의 사항이 있으시면, 아래로 연락해주시기
            바랍니다:
          </p>
          <div className="bg-cream-light p-4 rounded-lg mt-3">
            <p className="text-charcoal/80">
              <strong>서비스명:</strong> 탈모상
            </p>
            <p className="text-charcoal/80">
              <strong>웹사이트:</strong>{' '}
              <Link
                href="/"
                className="text-deep-blue underline hover:no-underline"
              >
                https://talmosang.vercel.app
              </Link>
            </p>
            <p className="text-charcoal/80">
              <strong>문의:</strong>{' '}
              <a
                href="https://github.com/gaegulgaegul/gaegulzip/issues"
                target="_blank"
                rel="noopener noreferrer"
                className="text-deep-blue underline hover:no-underline"
              >
                GitHub Issues
              </a>
            </p>
          </div>
        </section>
      </Card>

      {/* 하단 안내 */}
      <footer className="text-center mt-12">
        <Link
          href="/"
          className="inline-block text-deep-blue underline hover:no-underline text-lg"
        >
          ← 탈모상 홈으로 돌아가기
        </Link>
      </footer>
    </main>
  );
}
