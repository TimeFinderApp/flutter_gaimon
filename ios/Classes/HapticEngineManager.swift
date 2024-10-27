import Foundation
import CoreHaptics

@available(iOS 13.0, *)
class HapticEngineManager: NSObject {
    private var engine: CHHapticEngine?
    private var patternPlayer: CHHapticPatternPlayer?

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

    // Preload and cache the haptic pattern player
    func createPlayer(data: String) {
        guard let engine = self.engine else { return }
        
        // Convert the string data to a dictionary for CHHapticPattern
        guard let jsonData = data.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
              let patternDict = jsonObject as? [CHHapticPattern.Key: Any] else {
            print("Failed to parse JSON string into dictionary")
            return
        }

        do {
            let pattern = try CHHapticPattern(dictionary: patternDict)
            self.patternPlayer = try engine.makePlayer(with: pattern)
        } catch {
            print("Failed to create haptic player: \(error.localizedDescription)")
        }
    }

    // Play the cached haptic pattern
    func playPattern() {
        guard let player = self.patternPlayer else { return }
        do {
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Failed to play haptic pattern: \(error.localizedDescription)")
        }
    }

    // Handle engine interruptions
    private func installEngineRestartHandler() {
        engine?.resetHandler = { [weak self] in
            do {
                try self?.engine?.start()
                // Recreate the player, but we cannot reuse the old pattern directly
                // So ensure you recreate the pattern before this gets called again
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
