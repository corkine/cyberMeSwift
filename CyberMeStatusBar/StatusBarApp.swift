//
//  CyberMeWGStatusBarApp.swift
//  CyberMeWGStatusBar
//
//  Created by Corkine on 2023/4/30.
//

import Cocoa
import SwiftUI

@main
struct CyberMeWGStatusBarApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  var body: some Scene {
    Settings {
      EmptyView()
    }
  }
}

class AppDelegate: NSObject, NSApplicationDelegate {
  static private(set) var instance: AppDelegate!

  lazy var statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
  let menu = MainMenu()

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    AppDelegate.instance = self

    statusBarItem.button?.image = NSImage(named: NSImage.Name("kyan-logo"))
    statusBarItem.button?.imagePosition = .imageLeading
    statusBarItem.menu = menu.build()
  }
}

class MainMenu: NSObject {
  let menu = NSMenu()
  let menuItems = Bundle.main.object(forInfoDictionaryKey: "CyberData") as! [String: String]

  func build() -> NSMenu {
    let contentView = NSHostingController(rootView: RouteView())
    contentView.view.frame.size = CGSize(width: 200, height: 60)

    let customMenuItem = NSMenuItem()
    customMenuItem.view = contentView.view
    menu.addItem(customMenuItem)

    menu.addItem(NSMenuItem.separator())

    let toggleItem = NSMenuItem(
      title: "Toggle VPN",
      action: #selector(toggleVPN),
      keyEquivalent: ""
    )
    toggleItem.target = self

    menu.addItem(toggleItem)
    menu.addItem(NSMenuItem.separator())

    let quitMenuItem = NSMenuItem(
      title: "Quit",
      action: #selector(quit),
      keyEquivalent: "q"
    )
    quitMenuItem.target = self
    menu.addItem(quitMenuItem)

    return menu
  }

  @objc func linkSelector(sender: NSMenuItem) {
    let link = sender.representedObject as! String
    guard let url = URL(string: link) else { return }
    NSWorkspace.shared.open(url)
  }

  @objc func about(sender: NSMenuItem) {
    NSApp.orderFrontStandardAboutPanel()
  }
    
  @objc func toggleVPN(sender: NSMenuItem) {
      let task = Process()
      task.launchPath = "/bin/zsh"
      task.arguments =
      ["-c", menuItems["script"] ?? ""]
      
      let pipe = Pipe()
      task.standardOutput = pipe
      task.launch()
      
      let data = pipe.fileHandleForReading.readDataToEndOfFile()
      let output = String(data: data, encoding: .utf8) ?? "Invoke vpn failed!"
      
      print(output)
  }

  @objc func quit(sender: NSMenuItem) {
    NSApp.terminate(self)
  }
}
