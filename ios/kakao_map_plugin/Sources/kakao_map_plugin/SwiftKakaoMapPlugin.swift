import Flutter
import UIKit

public class SwiftKakaoMapPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "kakao_map_plugin", binaryMessenger: registrar.messenger())
    let instance = SwiftKakaoMapPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}

// CocoaPods exposes KakaoMapPlugin through the Objective-C forwarding class
// in ios/Classes. SwiftPM only supports one language per target, so expose
// the same registration entry point in Swift for Swift Package Manager builds.
#if SWIFT_PACKAGE
@objc(KakaoMapPlugin)
public class KakaoMapPlugin: SwiftKakaoMapPlugin {}
#endif
