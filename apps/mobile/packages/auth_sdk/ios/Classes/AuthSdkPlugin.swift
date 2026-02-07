import Flutter
import UIKit
import NidThirdPartyLogin

/// auth_sdk iOS 플러그인
///
/// 네이버 로그인 SDK 5.0의 OAuth 콜백을 자동으로 처리합니다.
/// registrar.addApplicationDelegate를 통해 URL 콜백을 수신합니다.
public class AuthSdkPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = AuthSdkPlugin()
        registrar.addApplicationDelegate(instance)

        // 네이버 SDK 설정값 디버그 출력
        let info = Bundle.main.infoDictionary
        print("[AuthSdkPlugin] NidClientID: \(info?["NidClientID"] as? String ?? "nil")")
        print("[AuthSdkPlugin] NidUrlScheme: \(info?["NidUrlScheme"] as? String ?? "nil")")
        print("[AuthSdkPlugin] NidAppName: \(info?["NidAppName"] as? String ?? "nil")")
        print("[AuthSdkPlugin] NidClientSecret 존재: \((info?["NidClientSecret"] as? String) != nil)")
    }

    public func application(_ app: UIApplication, open url: URL,
                            options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        print("[AuthSdkPlugin] URL 콜백 수신: \(url.scheme ?? "nil")://\(url.host ?? "nil")")
        if NidOAuth.shared.handleURL(url) {
            print("[AuthSdkPlugin] NidOAuth가 URL 처리 완료")
            return true
        }
        print("[AuthSdkPlugin] NidOAuth가 URL 처리하지 않음")
        return false
    }
}
