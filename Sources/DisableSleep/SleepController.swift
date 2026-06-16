import Foundation
import SwiftUI

/// Reads and toggles the macOS `pmset -a disablesleep` setting.
///
/// `disablesleep 1` prevents the Mac from sleeping at all — including when the
/// lid is closed (clamshell). It requires root, so writes go through `sudo -n`,
/// which only succeeds if the matching NOPASSWD rule from `install.sh` is in
/// place. We use `-n` (non-interactive) so a missing rule fails fast instead of
/// hanging on a hidden password prompt.
@MainActor
final class SleepController: ObservableObject {
    /// `true` when sleep is currently disabled (SleepDisabled = 1).
    @Published private(set) var isDisabled = false
    /// `true` once we detect the NOPASSWD sudoers rule is missing/broken.
    @Published private(set) var needsSetup = false

    private let pmset = "/usr/bin/pmset"

    init() {
        refresh()
    }

    func refresh() {
        let result = run(pmset, ["-g"])
        for rawLine in result.output.split(separator: "\n") {
            guard rawLine.contains("SleepDisabled") else { continue }
            let tokens = rawLine.split(whereSeparator: { $0 == " " || $0 == "\t" })
            isDisabled = tokens.last == "1"
            return
        }
    }

    func toggle() {
        setDisabled(!isDisabled)
    }

    func setDisabled(_ on: Bool) {
        let status = Self.applyDisableSleep(on)
        // exit 1 from `sudo -n` means the NOPASSWD rule is not configured.
        needsSetup = status != 0
        refresh()
    }

    /// Runs `sudo -n pmset -a disablesleep {0,1}` and returns the exit status.
    /// `nonisolated` + `static` so it can be called from the app's terminate
    /// handler (to restore normal sleep on quit) without touching the actor.
    @discardableResult
    nonisolated static func applyDisableSleep(_ on: Bool) -> Int32 {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/sudo")
        process.arguments = ["-n", "/usr/bin/pmset", "-a", "disablesleep", on ? "1" : "0"]
        do {
            try process.run()
            process.waitUntilExit()
            return process.terminationStatus
        } catch {
            return -1
        }
    }

    private func run(_ launchPath: String, _ args: [String]) -> (output: String, status: Int32) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: launchPath)
        process.arguments = args

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            return ("", -1)
        }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return (String(data: data, encoding: .utf8) ?? "", process.terminationStatus)
    }
}
