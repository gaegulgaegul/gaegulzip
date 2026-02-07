import axios from 'axios';
import { IOAuthProvider } from './base';
import { OAuthUserInfo, GoogleIdTokenPayload } from '../types';
import {
  UnauthorizedException,
  ExternalApiException,
  ErrorCode
} from '../../../utils/errors';

/**
 * 구글 OAuth Provider 구현체 (ID Token 검증 방식)
 *
 * 모바일에서 전달받은 idToken을 Google tokeninfo endpoint로 검증합니다.
 * Apple 로그인과 동일한 패턴입니다.
 */
export class GoogleProvider implements IOAuthProvider {
  readonly name = 'google';

  /** 검증된 idToken 페이로드 (verifyToken 이후 사용) */
  private verifiedPayload: GoogleIdTokenPayload | null = null;

  constructor(
    private readonly clientId: string,
    private readonly clientSecret: string
  ) {}

  /**
   * Google ID Token 검증
   * @param idToken - 모바일 SDK에서 획득한 idToken
   * @throws UnauthorizedException 토큰이 유효하지 않은 경우
   * @throws ExternalApiException Google API 호출 실패 시
   */
  async verifyToken(idToken: string): Promise<void> {
    try {
      const response = await axios.get<GoogleIdTokenPayload>(
        'https://oauth2.googleapis.com/tokeninfo',
        { params: { id_token: idToken } }
      );

      this.verifiedPayload = response.data;
    } catch (error: any) {
      if (error.response?.status === 400 || error.response?.status === 401) {
        throw new UnauthorizedException(ErrorCode.INVALID_ACCESS_TOKEN);
      }
      throw new ExternalApiException('google', error);
    }
  }

  /**
   * 검증된 idToken 페이로드에서 사용자 정보 추출
   * @param _idToken - 사용하지 않음 (인터페이스 호환용)
   * @returns 정규화된 사용자 정보
   * @throws ExternalApiException 페이로드가 없는 경우
   */
  async getUserInfo(_idToken: string): Promise<OAuthUserInfo> {
    if (!this.verifiedPayload) {
      throw new ExternalApiException('google', new Error('verifyToken을 먼저 호출해야 합니다'));
    }

    const { sub, email, name, picture } = this.verifiedPayload;

    return {
      providerId: sub,
      email: email ?? null,
      nickname: name ?? null,
      profileImage: picture ?? null,
    };
  }
}
