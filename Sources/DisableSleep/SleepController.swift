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
    private let sudo = "/usr/bin/sudo"

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
        let result = run(sudo, ["-n", pmset, "-a", "disablesleep", on ? "1" : "0"])
        // exit 1 from `sudo -n` means the NOPASSWD rule is not configured.
        needsSetup = result.status != 0
        refresh()
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
