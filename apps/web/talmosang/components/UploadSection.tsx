'use client';

import { useState, useRef } from 'react';
import { Camera, X } from 'lucide-react';
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
      {/* 업로드 카드 */}
      <Card className="paper-texture pencil-border p-4 md:p-5 h-[400px] md:h-[250px] flex items-center justify-center hover:scale-[1.02] hover:rotate-[-0.5deg] transition-transform duration-300">
        {!photo ? (
          <div
            className={`drag-drop-zone ${isDragging ? 'dragging' : ''}`}
            onDragEnter={handleDragEnter}
            onDragOver={handleDragOver}
            onDragLeave={handleDragLeave}
            onDrop={handleDrop}
            onClick={handleUploadClick}
          >
            <Camera className="w-12 h-12 text-black" />
            <p className="text-sm font-bold text-black mt-2 text-center">
              사진을 올려주세요
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
          <div className="preview-section flex flex-col items-center gap-2">
            {/* 미리보기 이미지 */}
            <div className="polaroid-frame rotate-[2deg] relative p-2">
              {previewUrl && (
                // eslint-disable-next-line @next/next/no-img-element
                <img
                  src={previewUrl}
                  alt="업로드한 사진"
                  className="h-[100px] md:h-[120px] w-auto rounded block mx-auto"
                />
              )}

              {/* 다시 선택 버튼 */}
              <button
                onClick={onReset}
                className="absolute top-1 left-1 bg-white rounded-full p-1.5 shadow-lg hover:scale-110 transition-transform"
                aria-label="다시 선택"
              >
                <X className="w-3 h-3 text-charcoal" />
              </button>
            </div>

            {/* CTA 버튼 */}
            <Button
              onClick={onAnalyze}
              disabled={!photo}
              className="btn-primary"
              style={{ fontSize: '16px', padding: '12px 32px' }}
            >
              관상 보기
            </Button>
          </div>
        )}
      </Card>

      {/* 에러 메시지 */}
      {error && (
        <div className="error-message">
          <p className="text-white text-center font-medium">{error}</p>
        </div>
      )}

    </section>
  );
}
