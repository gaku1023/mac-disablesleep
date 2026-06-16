import SwiftUI

@main
struct DisableSleepApp: App {
    @StateObject private var controller = SleepController()
    @StateObject private var loginItem = LoginItem()

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
