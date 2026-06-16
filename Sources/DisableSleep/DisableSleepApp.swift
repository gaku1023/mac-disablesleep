import ServiceManagement
import SwiftUI

/// Custom entry point so the uninstaller can cleanly remove the login item.
///
/// `DisableSleep --unregister` deregisters the SMAppService login item and
/// exits without showing the menu bar UI, so deleting the app bundle never
/// leaves an orphaned entry in System Settings → Login Items.
@main
struct Entry {
    static func main() {
        if CommandLine.arguments.contains("--unregister") {
            try? SMAppService.mainApp.unregister()
            return
        }
        if CommandLine.arguments.contains("--status") {
            // Diagnostic: 0=notRegistered 1=enabled 2=requiresApproval 3=notFound
            print("login item status: \(SMAppService.mainApp.status.rawValue)")
            return
        }
        DisableSleepApp.main()
    }
}

struct DisableSleepApp: App {
    @StateObject private var controller = SleepController()
    @StateObject private var loginItem = LoginItem()

    init() {
        LoginItem.enableByDefaultOnFirstRun()
    }

    var body: some Scene {
        MenuBarExtra {
            MenuContent(controller: controller, loginItem: loginItem)
        } label: {
            Image(systemName: controller.isDisabled ? "sun.max.fill" : "moon.fill")
        }
        .menuBarExtraStyle(.menu)
    }
}

struct MenuContent: View {
    @ObservedObject var controller: SleepController
    @ObservedObject var loginItem: LoginItem

    var body: some View {
        Text(controller.isDisabled
             ? "Sleep is DISABLED (stays awake)"
             : "Sleep is enabled (normal)")

        Divider()

        Button(controller.isDisabled ? "Allow sleep" : "Disable sleep") {
            controller.toggle()
        }

        Button("Refresh status") {
            controller.refresh()
        }

        if controller.needsSetup {
            Divider()
            Text("⚠︎ Setup needed — run install.sh")
        }

        Divider()

        Toggle("Launch at login", isOn: Binding(
            get: { loginItem.isEnabled },
            set: { loginItem.setEnabled($0) }
        ))

        Divider()

        Button("Quit") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}
