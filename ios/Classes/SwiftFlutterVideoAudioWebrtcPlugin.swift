import Flutter
import UIKit

public class SwiftFlutterVideoAudioWebrtcPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_video_audio_webrtc", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterVideoAudioWebrtcPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
