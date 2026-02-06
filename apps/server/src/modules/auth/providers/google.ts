import axios from 'axios';
import { IOAuthProvider } from './base';
import { OAuthUserInfo, GoogleTokenResponse, GoogleUserInfo } from '../types';
import {
  UnauthorizedException,
  ExternalApiException,
  ErrorCode
} from '../../../utils/errors';

/**
 * 구글 OAuth Provider 구현체 (Server-side Authorization Code 플로우)
 *
 * 모바일에서 전달받은 authorization code를 서버에서 토큰으로 교환하여 처리합니다.
 */
export class GoogleProvider implements IOAuthProvider {
  readonly name = 'google';

  /** 교환된 access token (verifyToken 이후 사용) */
  private exchangedAccessToken: string | null = null;

  constructor(
    private readonly clientId: string,
    private readonly clientSecret: string
  ) {}

  /**
   * Authorization code를 Google 토큰으로 교환 및 검증
   * @param authCode - 모바일 SDK에서 획득한 serverAuthCode
   * @throws UnauthorizedException 코드 교환 실패 시
   * @throws ExternalApiException Google API 호출 실패 시
   */
  async verifyToken(authCode: string): Promise<void> {
    try {
      const response = await axios.post<GoogleTokenResponse>(
        'https://oauth2.googleapis.com/token',
        {
          code: authCode,
          client_id: this.clientId,
          client_secret: this.clientSecret,
          redirect_uri: '',
          grant_type: 'authorization_code',
        }
      );

      this.exchangedAccessToken = response.data.access_token;
    } catch (error: any) {
      if (error.response?.status === 400 || error.response?.status === 401) {
        throw new UnauthorizedException(ErrorCode.INVALID_ACCESS_TOKEN);
      }
      throw new ExternalApiException('google', error);
    }
  }

  /**
   * 교환된 access token으로 구글 사용자 정보 조회
   * @param _authCode - 사용하지 않음 (인터페이스 호환용)
   * @returns 정규화된 사용자 정보
   * @throws ExternalApiException 구글 API 호출 실패 시
   */
  async getUserInfo(_authCode: string): Promise<OAuthUserInfo> {
    if (!this.exchangedAccessToken) {
      throw new ExternalApiException('google', new Error('verifyToken을 먼저 호출해야 합니다'));
    }

    try {
      const response = await axios.get<GoogleUserInfo>(
        'https://www.googleapis.com/oauth2/v2/userinfo',
        {
          headers: { Authorization: `Bearer ${this.exchangedAccessToken}` }
        }
      );

      const { id, email, name, picture } = response.data;

      return {
        providerId: id,
        email: email ?? null,
        nickname: name ?? null,
        profileImage: picture ?? null,
      };
    } catch (error: any) {
      throw new ExternalApiException('google', error);
    }
  }
}
