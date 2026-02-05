# Admin Auth - TDD Plan

## 개요

어드민 대시보드에 비밀번호 기반 인증을 추가한다.
Next.js 자체 완결 (Express 서버 수정 없음).

## 아키텍처

```
비밀번호 입력 → POST /api/auth/login → SHA-256 해시 비교 → HttpOnly 쿠키 발급
                                                              ↓
대시보드 접근 → middleware.ts → 쿠키 확인 → 통과 or /login 리디렉트
                                                              ↓
쿠키 만료 → 자동으로 /login 리디렉트 (로그아웃 불필요)
```

- 비밀번호: SHA-256 해시를 코드 내 상수로 보관 (환경변수 불필요)
- `admin-session`: HttpOnly 쿠키로 세션 관리
- `middleware.ts`: /dashboard 등 보호 경로에서 인증 체크

## 테스트 (Playwright E2E)

### 0. 테스트 환경 설정
- [x] Playwright 설치 및 설정

### 1. 로그인 페이지 표시
- [x] `/login`에 접속하면 비밀번호 입력 폼이 보인다

### 2. 로그인 실패
- [x] 잘못된 비밀번호를 입력하면 에러 메시지가 표시된다

### 3. 로그인 성공
- [x] 올바른 비밀번호를 입력하면 `/dashboard`로 리디렉트된다

### 4. 미인증 접근 차단
- [x] 로그인하지 않고 `/dashboard`에 접근하면 `/login`으로 리디렉트된다

### 5. 인증된 대시보드 접근
- [x] 로그인 후 `/dashboard`에 접근하면 정상적으로 페이지가 표시된다

### 6. 이미 로그인된 상태에서 로그인 페이지
- [x] 이미 로그인된 상태에서 `/login`에 접근하면 `/dashboard`로 리디렉트된다
