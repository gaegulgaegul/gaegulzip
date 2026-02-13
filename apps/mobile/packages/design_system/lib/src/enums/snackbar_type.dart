/// Snackbar 메시지의 의미론적 타입.
enum SnackbarType {
  /// 성공 - 초록 배경, 체크마크 아이콘
  success,

  /// 정보 - 파랑 배경, i 아이콘
  info,

  /// 경고 - 노랑 배경, 삼각형 + ! 아이콘
  warning,

  /// 에러 - 빨강 배경, x 아이콘
  error,
}
