import SwiftUI
import AppKit
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    var dataManager = DataManager.shared
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        // Request notification permissions with detailed error logging
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("DEBUG: Notification permission granted")
            } else if let error = error {
                print("DEBUG: Notification permission denied: \(error.localizedDescription)")
            } else {
                print("DEBUG: Notification permission denied (unknown)")
            }
        }
        
        // Create the status bar item with slightly larger size for visibility
        statusItem = NSStatusBar.system.statusItem(withLength: 26)
        
        if let button = statusItem.button {
            // Use the pixel art icon
            button.image = NSImage(named: "AppIcon")
            button.image?.size = NSSize(width: 22, height: 22) // Increased from 18x18
            button.action = #selector(togglePopover)
        }
        
        // Create the popover
        popover = NSPopover()
        popover.contentSize = NSSize(width: 320, height: 420)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: ContentView())
        
        // Hide dock icon
        NSApp.setActivationPolicy(.accessory)
    }
    
    @objc func togglePopover() {
        if let button = statusItem.button {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }
    
    func closePopover() {
        popover.performClose(nil)
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show banner and play sound even if app is in foreground
        if #available(macOS 14.0, *) {
            completionHandler([.banner, .sound])
        } else {
            completionHandler([.alert, .sound])
        }
    }
}
