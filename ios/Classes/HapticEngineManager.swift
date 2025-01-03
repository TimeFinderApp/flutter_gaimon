import Foundation
import CoreHaptics

@available(iOS 13.0, *)
class HapticEngineManager: NSObject {
    private var engine: CHHapticEngine?
    private var patternPlayers: [String: CHHapticPatternPlayer] = [:]
    private var currentPatternKey: String = "default"

    // Initialize the haptic engine once
    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        if engine == nil {
            do {
                self.engine = try CHHapticEngine()
                try self.engine?.start()
                // Handle engine resets and interruptions
                installEngineRestartHandler()
                installEngineStoppedHandler()
            } catch {
                print("Failed to start haptic engine: \(error.localizedDescription)")
            }
        }
    }

    // Stop the haptic engine when the app goes to the background
    func stopHaptics() {
        guard let engine = self.engine else { return }
        do {
            try engine.stop()
            print("Haptic engine stopped successfully.")
        } catch {
            print("Failed to stop haptic engine: \(error.localizedDescription)")
        }
    }

    // Restart the haptic engine when the app returns to the foreground
    func restartHaptics() {
        guard let engine = self.engine else {
            prepareHaptics()
            return
        }
        do {
            try engine.start()
            print("Haptic engine restarted successfully.")
            // Recreate all pattern players after engine restart
            recreatePatternPlayers()
        } catch {
            print("Failed to restart haptic engine: \(error.localizedDescription)")
        }
    }

    // Store pattern data for recreation after engine restarts
    private var patternData: [String: [CHHapticPattern.Key: Any]] = [:]

    // Preload and cache the haptic pattern player
    func createPlayer(data: String, patternKey: String?, result: @escaping FlutterResult) {
        guard let engine = self.engine else {
            result(FlutterError(code: "engine_not_initialized", message: "Haptic engine is not initialized", details: nil))
            return
        }
        
        let key = patternKey ?? "default"
        
        // Convert the string data to a dictionary for CHHapticPattern
        guard let jsonData = data.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
              let patternDict = jsonObject as? [CHHapticPattern.Key: Any] else {
            result(FlutterError(code: "invalid_json", message: "Failed to parse JSON string into dictionary", details: nil))
            return
        }

        do {
            let pattern = try CHHapticPattern(dictionary: patternDict)
            let player = try engine.makePlayer(with: pattern)
            patternPlayers[key] = player
            patternData[key] = patternDict
            currentPatternKey = key
            result(nil) // Success case, return nil (indicating success)
        } catch {
            result(FlutterError(code: "player_creation_failed", message: "Failed to create haptic player", details: error.localizedDescription))
        }
    }

    // Play the cached haptic pattern
    func playPattern(patternKey: String?, result: @escaping FlutterResult) {
        let key = patternKey ?? currentPatternKey
        guard let player = patternPlayers[key] else {
            result(FlutterError(code: "player_not_initialized", message: "Haptic player not found for key: \(key)", details: nil))
            return
        }
        
        do {
            try player.start(atTime: CHHapticTimeImmediate)
            result(nil) // Success case
        } catch {
            result(FlutterError(code: "playback_failed", message: "Failed to play haptic pattern", details: error.localizedDescription))
        }
    }

    // Recreate all pattern players after engine restart
    private func recreatePatternPlayers() {
        for (key, patternDict) in patternData {
            do {
                let pattern = try CHHapticPattern(dictionary: patternDict)
                patternPlayers[key] = try engine?.makePlayer(with: pattern)
            } catch {
                print("Failed to recreate pattern player for key \(key): \(error.localizedDescription)")
            }
        }
    }

    // Handle engine interruptions
    private func installEngineRestartHandler() {
        engine?.resetHandler = { [weak self] in
            do {
                try self?.engine?.start()
                self?.recreatePatternPlayers()
            } catch {
                print("Failed to restart haptic engine: \(error.localizedDescription)")
            }
        }
    }

    private func installEngineStoppedHandler() {
        engine?.stoppedHandler = { reason in
            print("Haptic engine stopped: \(reason.rawValue)")
        }
    }
}
