'use client';

import { useState, useRef } from 'react';
import { Camera, ShieldCheck, X } from 'lucide-react';
import { Card } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { ERROR_MESSAGES } from '@/lib/errors';

interface UploadSectionProps {
  photo: File | null;
  previewUrl: string | null;
  error: string | null;
  onPhotoUpload: (file: File) => void;
  onAnalyze: () => void;
  onReset: () => void;
}

/**
 * 사진 업로드 섹션 컴포넌트
 *
 * 파일 업로드, 드래그앤드롭, 미리보기 기능을 제공합니다.
 * 모바일 카메라 촬영도 지원합니다.
 */
export default function UploadSection({
  photo,
  previewUrl,
  error,
  onPhotoUpload,
  onAnalyze,
  onReset,
}: UploadSectionProps) {
  const [isDragging, setIsDragging] = useState(false);
  const inputRef = useRef<HTMLInputElement>(null);

  /**
   * 파일 검증
   *
   * 허용 타입: image/jpeg, image/png, image/webp
   * 최대 크기: 10MB
   */
  const validateFile = (file: File): string | null => {
    // 파일 타입 검증
    const allowedTypes = ['image/jpeg', 'image/png', 'image/webp'];
    if (!allowedTypes.includes(file.type)) {
      return ERROR_MESSAGES.FILE_TYPE;
    }

    // 파일 크기 검증 (10MB)
    const maxSize = 10 * 1024 * 1024;
    if (file.size > maxSize) {
      return ERROR_MESSAGES.FILE_SIZE;
    }

    return null;
  };

  const handleDragEnter = (e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
    setIsDragging(true);
  };

  const handleDragLeave = (e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
    setIsDragging(false);
  };

  const handleDragOver = (e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
  };

  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
    setIsDragging(false);

    const file = e.dataTransfer.files[0];
    if (file) {
      const validationError = validateFile(file);
      if (validationError) {
        alert(validationError);
        return;
      }
      onPhotoUpload(file);
    }
  };

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      const validationError = validateFile(file);
      if (validationError) {
        alert(validationError);
        return;
      }
      onPhotoUpload(file);
    }
  };

  const handleUploadClick = () => {
    inputRef.current?.click();
  };

  return (
    <section className="upload-section">
      {/* 메인 카피 */}
      <div className="text-center mb-8">
        <h2 className="text-3xl md:text-4xl font-extrabold mb-2 rotate-[-1deg]">
          이보시오 관상가 양반, 내가 탈모가 될 상인가?
        </h2>
        <p className="text-sm text-charcoal opacity-60">
          AI 관상가가 그대의 모발 운명을 점지하리라
        </p>
      </div>

      {/* 업로드 카드 */}
      <Card className="paper-texture pencil-border p-6 md:p-8 hover:scale-[1.02] hover:rotate-[-0.5deg] transition-transform duration-300">
        {!photo ? (
          <div
            className={`drag-drop-zone ${isDragging ? 'dragging' : ''}`}
            onDragEnter={handleDragEnter}
            onDragOver={handleDragOver}
            onDragLeave={handleDragLeave}
            onDrop={handleDrop}
            onClick={handleUploadClick}
          >
            <Camera className="w-32 h-32 text-black" />
            <p className="text-2xl font-bold text-black mt-4">
              사진을 드래그하거나 클릭하여 업로드
            </p>
            <input
              ref={inputRef}
              type="file"
              accept="image/*"
              capture="user"
              className="hidden"
              onChange={handleFileChange}
            />
          </div>
        ) : (
          <div className="preview-section">
            {/* 폴라로이드 프레임 미리보기 */}
            <div className="polaroid-frame rotate-[2deg] mb-6 relative mx-auto max-w-md">
              {previewUrl && (
                // eslint-disable-next-line @next/next/no-img-element
                <img
                  src={previewUrl}
                  alt="업로드한 사진"
                  className="w-full rounded"
                />
              )}
              <div className="scribble-star absolute top-4 right-4" />

              {/* 다시 선택 버튼 (작은 X 버튼) */}
              <button
                onClick={onReset}
                className="absolute top-4 left-4 bg-white rounded-full p-2 shadow-lg hover:scale-110 transition-transform"
                aria-label="다시 선택"
              >
                <X className="w-4 h-4 text-charcoal" />
              </button>
            </div>

            {/* CTA 버튼 */}
            <div className="flex justify-center">
              <Button
                onClick={onAnalyze}
                disabled={!photo}
                className="btn-primary text-3xl px-20 py-8"
              >
                관상 보기
              </Button>
            </div>
          </div>
        )}
      </Card>

      {/* 에러 메시지 */}
      {error && (
        <div className="error-message">
          <p className="text-coral text-center font-medium">{error}</p>
        </div>
      )}

      {/* 안심 문구 */}
      <div className="reassurance-text">
        <ShieldCheck className="w-5 h-5 text-forest-green flex-shrink-0" />
        <p className="text-sm text-charcoal opacity-70">
          그대의 초상화는 관상을 본 즉시 소각되오니 안심하시옵소서
        </p>
      </div>
    </section>
  );
}
