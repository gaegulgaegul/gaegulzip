import type { NextConfig } from 'next';

const nextConfig: NextConfig = {
  reactStrictMode: true,
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: 'generativelanguage.googleapis.com',
      },
    ],
  },
  // CSP 설정
  async headers() {
    return [
      {
        source: '/(.*)',
        headers: [
          {
            key: 'Content-Security-Policy',
            value: [
              "default-src 'self'",
              "script-src 'self' 'unsafe-inline' 'unsafe-eval' https://pagead2.googlesyndication.com",
              "style-src 'self' 'unsafe-inline'",
              "img-src 'self' data: blob: https:",
              "connect-src 'self' https://generativelanguage.googleapis.com",
              "frame-src https://googleads.g.doubleclick.net",
            ].join('; '),
          },
        ],
      },
    ];
  },
};

export default nextConfig;
