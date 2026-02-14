/**
 * 클라이언트 측 이미지 리사이즈
 *
 * Canvas API를 사용하여 최대 800px로 리사이즈하고
 * base64 문자열을 반환합니다 (data:image/jpeg;base64,... 에서 base64 부분만).
 *
 * @param file - 리사이즈할 이미지 파일
 * @param maxSize - 최대 너비/높이 (기본: 800px)
 * @returns base64 인코딩된 이미지 문자열
 */
export async function resizeImage(file: File, maxSize: number = 800): Promise<string> {
  return new Promise((resolve, reject) => {
    const img = new Image();
    const canvas = document.createElement('canvas');
    const ctx = canvas.getContext('2d');

    if (!ctx) {
      reject(new Error('Canvas context를 생성할 수 없습니다'));
      return;
    }

    img.onload = () => {
      let { width, height } = img;

      // 비율 유지하며 리사이즈
      if (width > height) {
        if (width > maxSize) {
          height = (height * maxSize) / width;
          width = maxSize;
        }
      } else {
        if (height > maxSize) {
          width = (width * maxSize) / height;
          height = maxSize;
        }
      }

      canvas.width = width;
      canvas.height = height;

      // 이미지를 캔버스에 그리기
      ctx.drawImage(img, 0, 0, width, height);

      // base64로 변환 (data:image/jpeg;base64,... 에서 base64 부분만 추출)
      const dataUrl = canvas.toDataURL(file.type || 'image/jpeg', 0.9);
      const base64 = dataUrl.split(',')[1];

      resolve(base64);
    };

    img.onerror = () => {
      reject(new Error('이미지를 로드할 수 없습니다'));
    };

    img.src = URL.createObjectURL(file);
  });
}

/**
 * File을 base64 문자열로 변환
 *
 * FileReader를 사용하여 파일을 읽고 base64 문자열로 변환합니다.
 * data:image/jpeg;base64,... 형식에서 base64 부분만 반환합니다.
 *
 * @param file - 변환할 파일
 * @returns base64 인코딩된 문자열
 */
export function fileToBase64(file: File): Promise<string> {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();

    reader.onload = () => {
      const result = reader.result as string;
      // "data:image/jpeg;base64," 부분 제거
      const base64 = result.split(',')[1];
      resolve(base64);
    };

    reader.onerror = () => {
      reject(new Error('파일을 읽을 수 없습니다'));
    };

    reader.readAsDataURL(file);
  });
}

/**
 * File의 MIME type 추출
 *
 * @param file - 파일 객체
 * @returns MIME type 문자열 (예: "image/jpeg")
 */
export function getMimeType(file: File): string {
  return file.type || 'image/jpeg';
}
