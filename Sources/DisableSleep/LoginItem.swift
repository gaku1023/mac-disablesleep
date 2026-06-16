import Foundation
import ServiceManagement
import SwiftUI

/// Manages "launch at login" via `SMAppService` (macOS 13+).
///
/// On first run we enable it by default, but remember that we did so
/// (`didSetDefaultLoginItem`) so the user can later turn it off and have the
/// choice respected on subsequent launches.
@MainActor
final class LoginItem: ObservableObject {
    @Published private(set) var isEnabled = false

    private let service = SMAppService.mainApp

    init() {
        refresh()
    }

    /// Enable launch-at-login once, on the first ever run. Called eagerly from
    /// `DisableSleepApp.init()` — NOT from this object's `init` — because the
    /// `@StateObject` is created lazily (only when the menu is first opened),
    /// which would otherwise delay the default registration indefinitely.
    nonisolated static func enableByDefaultOnFirstRun() {
        let key = "didSetDefaultLoginItem"
        guard !UserDefaults.standard.bool(forKey: key) else { return }
        try? SMAppService.mainApp.register()
        UserDefaults.standard.set(true, forKey: key)
    }

    func refresh() {
        isEnabled = service.status == .enabled
    }

    func toggle() {
        setEnabled(!isEnabled)
    }

    func setEnabled(_ on: Bool) {
        do {
            if on {
                if service.status != .enabled {
                    try service.register()
                }
            } else {
                try service.unregister()
            }
        } catch {
            // Registration can fail (e.g. app not in /Applications). Leave the
            // published state in sync with reality rather than guessing.
        }
        refresh()
    }
}
