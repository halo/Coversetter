import SwiftUI
import AVKit
import AVFoundation

@main
struct CoversetterApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  var body: some Scene {
    WindowGroup {
      PlayerView()
        .environmentObject(CoverManager())
    }
    .windowStyle(.hiddenTitleBar)
    .commands {
      CommandGroup(replacing: .saveItem) { }
      CommandGroup(replacing: .newItem) { }
      CommandMenu("File") {
        Button("Save Cover Image") {
          NotificationCenter.default.post(name: .saveCover, object: nil)
        }
        .keyboardShortcut("s", modifiers: .command)
      }
    }
  }
}

class AppDelegate: NSObject, NSApplicationDelegate {
  func applicationDidFinishLaunching(_ notification: Notification) {
    if let window = NSApplication.shared.windows.first {
      window.styleMask = [.borderless, .resizable]
      window.isMovableByWindowBackground = true

      if let window = NSApplication.shared.windows.first {
        let windowSize: CGSize = CGSize(width: 600, height: 600 * 9/16)
        window.setContentSize(windowSize)
      }
    }
  }
}
