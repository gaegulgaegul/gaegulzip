import { describe, it, expect, vi, beforeEach } from 'vitest';
import axios from 'axios';
import { GoogleProvider } from '../../../../src/modules/auth/providers/google';
import { UnauthorizedException, ExternalApiException } from '../../../../src/utils/errors';

vi.mock('axios');
const mockedAxios = vi.mocked(axios);

describe('GoogleProvider', () => {
  let provider: GoogleProvider;

  beforeEach(() => {
    provider = new GoogleProvider('google-client-id', 'google-client-secret');
    vi.clearAllMocks();
  });

  describe('verifyToken', () => {
    it('should verify token successfully when valid', async () => {
      mockedAxios.get.mockResolvedValueOnce({
        data: {
          iss: 'accounts.google.com',
          sub: 'google-user-id',
          aud: 'google-client-id',
          exp: '9999999999',
          email: 'test@gmail.com',
          name: 'Hong Gildong',
          picture: 'https://example.com/image.jpg',
        },
      });

      await expect(provider.verifyToken('valid-id-token')).resolves.not.toThrow();
    });

    it('should throw UnauthorizedException when token is invalid (400)', async () => {
      const error: any = new Error('Invalid token');
      error.response = { status: 400 };
      mockedAxios.get.mockRejectedValueOnce(error);

      await expect(provider.verifyToken('invalid-token')).rejects.toThrow(UnauthorizedException);
    });

    it('should throw UnauthorizedException when token is invalid (401)', async () => {
      const error: any = new Error('Unauthorized');
      error.response = { status: 401 };
      mockedAxios.get.mockRejectedValueOnce(error);

      await expect(provider.verifyToken('invalid-token')).rejects.toThrow(UnauthorizedException);
    });

    it('should wrap other axios errors in ExternalApiException', async () => {
      mockedAxios.get.mockRejectedValueOnce(new Error('Network error'));

      await expect(provider.verifyToken('invalid-token')).rejects.toThrow(ExternalApiException);
    });
  });

  describe('getUserInfo', () => {
    it('should return normalized user info from verified payload', async () => {
      mockedAxios.get.mockResolvedValueOnce({
        data: {
          iss: 'accounts.google.com',
          sub: 'google-user-id',
          aud: 'google-client-id',
          exp: '9999999999',
          email: 'test@gmail.com',
          name: 'Hong Gildong',
          picture: 'https://example.com/image.jpg',
        },
      });
      await provider.verifyToken('valid-id-token');

      const result = await provider.getUserInfo('valid-id-token');

      expect(result).toEqual({
        providerId: 'google-user-id',
        email: 'test@gmail.com',
        nickname: 'Hong Gildong',
        profileImage: 'https://example.com/image.jpg',
      });
    });

    it('should handle optional fields as null', async () => {
      mockedAxios.get.mockResolvedValueOnce({
        data: {
          iss: 'accounts.google.com',
          sub: 'google-user-id',
          aud: 'google-client-id',
          exp: '9999999999',
        },
      });
      await provider.verifyToken('valid-id-token');

      const result = await provider.getUserInfo('valid-id-token');

      expect(result).toEqual({
        providerId: 'google-user-id',
        email: null,
        nickname: null,
        profileImage: null,
      });
    });

    it('should throw ExternalApiException when verifyToken not called', async () => {
      await expect(provider.getUserInfo('some-token')).rejects.toThrow(ExternalApiException);
    });
  });
});
