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
                    hapticManager.createPlayer(data: data)
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Invalid arguments", details: nil))
                }
            } else {
                result(FlutterError(code: "unsupported_version", message: "iOS version not supported", details: nil))
            }
        case "playPattern":
            if #available(iOS 13.0, *) {
                hapticManager.playPattern()
                result(nil)
            } else {
                result(FlutterError(code: "unsupported_version", message: "iOS version not supported", details: nil))
            }
        case "pattern":
            if #available(iOS 13.0, *) {
                if let args = call.arguments as? Dictionary<String, Any>,
                   let data = args["data"] as? String {
                    hapticManager.prepareHaptics()
                    hapticManager.createPlayer(data: data)
                    hapticManager.playPattern()
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Invalid arguments", details: nil))
                }
            } else {
                result(FlutterError(code: "unsupported_version", message: "iOS version not supported", details: nil))
            }
        case "selection":
            if #available(iOS 10.0, *) {
                let feedback = UISelectionFeedbackGenerator()
                feedback.prepare()
                feedback.selectionChanged()
                result(nil)
            } else {
                result(FlutterError(code: "unsupported_version", message: "iOS version not supported", details: nil))
            }
        case "error":
            if #available(iOS 10.0, *) {
                let feedback = UINotificationFeedbackGenerator()
                feedback.prepare()
                feedback.notificationOccurred(.error)
                result(nil)
            } else {
                result(FlutterError(code: "unsupported_version", message: "iOS version not supported", details: nil))
            }
        case "success":
            if #available(iOS 10.0, *) {
                let feedback = UINotificationFeedbackGenerator()
                feedback.prepare()
                feedback.notificationOccurred(.success)
                result(nil)
            } else {
                result(FlutterError(code: "unsupported_version", message: "iOS version not supported", details: nil))
            }
        case "warning":
            if #available(iOS 10.0, *) {
                let feedback = UINotificationFeedbackGenerator()
                feedback.prepare()
                feedback.notificationOccurred(.warning)
                result(nil)
            } else {
                result(FlutterError(code: "unsupported_version", message: "iOS version not supported", details: nil))
            }
        case "heavy":
            if #available(iOS 10.0, *) {
                let feedback = UIImpactFeedbackGenerator(style: .heavy)
                feedback.prepare()
                feedback.impactOccurred()
                result(nil)
            } else {
                result(FlutterError(code: "unsupported_version", message: "iOS version not supported", details: nil))
            }
        case "medium":
            if #available(iOS 10.0, *) {
                let feedback = UIImpactFeedbackGenerator(style: .medium)
                feedback.prepare()
                feedback.impactOccurred()
                result(nil)
            } else {
                result(FlutterError(code: "unsupported_version", message: "iOS version not supported", details: nil))
            }
        case "light":
            if #available(iOS 10.0, *) {
                let feedback = UIImpactFeedbackGenerator(style: .light)
                feedback.prepare()
                feedback.impactOccurred()
                result(nil)
            } else {
                result(FlutterError(code: "unsupported_version", message: "iOS version not supported", details: nil))
            }
        case "rigid":
            if #available(iOS 13.0, *) {
                let feedback = UIImpactFeedbackGenerator(style: .rigid)
                feedback.prepare()
                feedback.impactOccurred()
                result(nil)
            } else {
                result(FlutterError(code: "unsupported_version", message: "iOS version not supported", details: nil))
            }
        case "soft":
            if #available(iOS 13.0, *) {
                let feedback = UIImpactFeedbackGenerator(style: .soft)
                feedback.prepare()
                feedback.impactOccurred()
                result(nil)
            } else {
                result(FlutterError(code: "unsupported_version", message: "iOS version not supported", details: nil))
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
