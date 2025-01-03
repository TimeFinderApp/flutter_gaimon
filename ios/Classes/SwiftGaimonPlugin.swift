import Flutter
import UIKit
import CoreHaptics

@available(iOS 13.0, *)
let hapticManager = HapticEngineManager()

public class SwiftGaimonPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "gaimon", binaryMessenger: registrar.messenger())
        let instance = SwiftGaimonPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "canSupportsHaptic":
            if #available(iOS 13.0, *) {
                result(CHHapticEngine.capabilitiesForHardware().supportsHaptics)
            } else {
                result(false)
            }
        case "prepareHaptics":
            if #available(iOS 13.0, *) {
                hapticManager.prepareHaptics()
                result(nil)
            } else {
                result(FlutterError(code: "unsupported_version", message: "iOS version not supported", details: nil))
            }
        case "createPlayer":
            if #available(iOS 13.0, *) {
                if let args = call.arguments as? [String: Any],
                   let data = args["data"] as? String {
                    let patternKey = args["patternKey"] as? String
                    hapticManager.createPlayer(data: data, patternKey: patternKey, result: result)
                } else {
                    result(FlutterError(code: "bad_args", message: "Invalid arguments", details: nil))
                }
            } else {
                result(FlutterError(code: "unsupported_version", message: "iOS version not supported", details: nil))
            }
        case "playPattern":
            if #available(iOS 13.0, *) {
                if let args = call.arguments as? [String: Any] {
                    let patternKey = args["patternKey"] as? String
                    hapticManager.playPattern(patternKey: patternKey, result: result)
                } else {
                    hapticManager.playPattern(patternKey: nil, result: result)
                }
            } else {
                result(FlutterError(code: "unsupported_version", message: "iOS version not supported", details: nil))
            }
        case "stopHaptics":
            if #available(iOS 13.0, *) {
                hapticManager.stopHaptics()
                result(nil)
            } else {
                result(FlutterError(code: "unsupported_version", message: "iOS version not supported", details: nil))
            }
        case "restartHaptics":
            if #available(iOS 13.0, *) {
                hapticManager.restartHaptics()
                result(nil)
            } else {
                result(FlutterError(code: "unsupported_version", message: "iOS version not supported", details: nil))
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
