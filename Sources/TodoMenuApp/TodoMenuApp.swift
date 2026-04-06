import AppKit
import Darwin
import ServiceManagement
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let launchAtLoginPreferenceKey = "launchAtLoginUserPreference"
    private let launchAtLoginInitializedKey = "launchAtLoginPreferenceInitialized"
    private var singleInstanceLockFileDescriptor: Int32 = -1

    func applicationWillFinishLaunching(_ notification: Notification) {
        guard acquireSingleInstanceLock() else {
            activateExistingInstance()
            DispatchQueue.main.async {
                NSApp.terminate(nil)
            }
            return
        }

        // Apply accessory policy before the app becomes active to avoid Dock presence.
        NSApp.setActivationPolicy(.accessory)
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        configureLaunchAtLogin()
        NSApp.deactivate()
    }

    private func configureLaunchAtLogin() {
        guard canManageLaunchAtLogin else {
            return
        }

        let defaults = UserDefaults.standard

        if !defaults.bool(forKey: launchAtLoginInitializedKey) {
            defaults.set(true, forKey: launchAtLoginInitializedKey)
            let shouldLaunchAtLogin = presentLaunchAtLoginPrompt()
            defaults.set(shouldLaunchAtLogin, forKey: launchAtLoginPreferenceKey)
        }

        let shouldLaunchAtLogin = defaults.object(forKey: launchAtLoginPreferenceKey) as? Bool ?? true

        do {
            if shouldLaunchAtLogin {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            NSLog("Failed to configure launch at login: \(error.localizedDescription)")
        }
    }

    private var canManageLaunchAtLogin: Bool {
        Bundle.main.bundleURL.pathExtension == "app"
    }

    private func presentLaunchAtLoginPrompt() -> Bool {
        NSApp.activate(ignoringOtherApps: true)

        let alert = NSAlert()
        alert.messageText = "Start TodoMenu at login?"
        alert.informativeText = "You can change this later in Login Items settings."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Enable")
        alert.addButton(withTitle: "Not Now")

        let response = alert.runModal()
        return response == .alertFirstButtonReturn
    }

    private func acquireSingleInstanceLock() -> Bool {
        let lockURL = FileManager.default.temporaryDirectory.appendingPathComponent("todomenu-single-instance.lock")
        let fd = open(lockURL.path, O_CREAT | O_RDWR, S_IRUSR | S_IWUSR)

        guard fd >= 0 else {
            return true
        }

        if flock(fd, LOCK_EX | LOCK_NB) == 0 {
            singleInstanceLockFileDescriptor = fd
            return true
        }

        close(fd)
        return false
    }

    private func activateExistingInstance() {
        guard let executableURL = Bundle.main.executableURL else {
            return
        }

        let existingInstance = NSWorkspace.shared.runningApplications.first { app in
            app.processIdentifier != ProcessInfo.processInfo.processIdentifier && app.executableURL == executableURL
        }

        existingInstance?.activate(options: [.activateIgnoringOtherApps, .activateAllWindows])
    }
}

@main
struct TodoMenuApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        MenuBarExtra("todomenu", systemImage: "checklist") {
            MenuBarView()
        }
        .menuBarExtraStyle(.window)
    }
}
