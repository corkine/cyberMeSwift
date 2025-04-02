//
//  helloSwiftApp.swift
//  helloSwift
//
//  Created by corkine on 2022/8/31.
//

import SwiftUI
import BackgroundTasks
import WidgetKit
import CarPlay
import UIKit
import os
import CoreData

import Flutter
import FlutterPluginRegistrant

private enum CoreDataStack {
  static var viewContext: NSManagedObjectContext = {
    let container = NSPersistentContainer(name: "FoodAccount")
    container.loadPersistentStores { _, error in
      guard error == nil else {
        fatalError("\(#file), \(#function), \(error!.localizedDescription)")
      }
    }
    return container.viewContext
  }()
  static func save() {
    guard viewContext.hasChanges else { return }
    do {
      try viewContext.save()
    } catch {
      fatalError("\(#file), \(#function), \(error.localizedDescription)")
    }
  }
}

@main
struct CyberApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  @Environment(\.scenePhase) private var phase
  @StateObject var cyberService = CyberService()
  @State var tappedCheckCard = false
  var body: some Scene {
    WindowGroup {
      CyberNav()
        .environmentObject(cyberService)
        .environment(\.managedObjectContext, CoreDataStack.viewContext)
        .onOpenURL(perform: handleOpenUrl)
    }
    .onChange(of: phase) { newValue in
      AppDelegate.cyberService = cyberService
      switch newValue {
      case .active:
        handleQuickAction()
        cyberService.setDashboardDataIfNeed()
        Dashboard.updateWidget(inSeconds: 300)
        break
      case .background:
        if self.tappedCheckCard {
          print("enter background and begin to fetch...")
          SceneDelegate.needFetch = true
          DispatchQueue.main.async {
            self.tappedCheckCard = false
          }
        }
        addDynamicQuickActions()
        CoreDataStack.save()
        break
      default: break
      }
    }
  }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  private static let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier!,
    category: String(describing: AppDelegate.self)
  )
  
  static let flutterEngine = FlutterEngine(name: "flutterEngine")
  static var cyberService: CyberService?
  static var conn: Connectivity?
  static var shortcutItem: UIApplicationShortcutItem?
  
  var shortcutItem: UIApplicationShortcutItem? { AppDelegate.shortcutItem }
  
  static func openFlutterApp1(route: String = "/menu") {
    if flutterEngine.viewController == nil {
      guard
        let windowScene = UIApplication.shared.connectedScenes
          .first(where: { $0.activationState == .foregroundActive && $0 is UIWindowScene }) as? UIWindowScene,
        let window = windowScene.windows.first(where: \.isKeyWindow),
        let rootViewController = window.rootViewController
      else { return }
      let flutterViewController = FlutterViewController(
        engine: AppDelegate.flutterEngine,
        nibName: nil,
        bundle: nil)
      
      flutterViewController.pushRoute(route)
      flutterViewController.modalPresentationStyle = .overCurrentContext
      flutterViewController.isViewOpaque = true
      
      rootViewController.present(flutterViewController, animated: true)
    } else {
      DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
        flutterEngine.viewController!.pushRoute(route)
      }
    }
  }
  
  static func openFlutterApp(route: String = "/menu") {
      if flutterEngine.viewController == nil {
          guard
              let windowScene = UIApplication.shared.connectedScenes
                  .first(where: { $0.activationState == .foregroundActive && $0 is UIWindowScene }) as? UIWindowScene,
              let window = windowScene.windows.first(where: \.isKeyWindow),
              let rootViewController = window.rootViewController
          else { return }
          
          let flutterViewController = FlutterViewController(
              engine: AppDelegate.flutterEngine,
              nibName: nil,
              bundle: nil)
          
          // For initial navigation, use a simple route without query params
          // or set the initial route to a base route like "/home"
          flutterViewController.modalPresentationStyle = .overCurrentContext
          flutterViewController.isViewOpaque = true
          
          rootViewController.present(flutterViewController, animated: true)
          
          // After presenting, navigate to the specific route with params
          DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
              navigateToFlutterRoute(route)
          }
      } else {
          DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
              navigateToFlutterRoute(route)
          }
      }
  }
  
  private static func navigateToFlutterRoute(_ route: String) {
      let methodChannel = FlutterMethodChannel(
          name: "flutter/nativeSimpleChannel",
          binaryMessenger: flutterEngine.binaryMessenger)
      
      methodChannel.invokeMethod("navigateTo", arguments: route)
  }
  
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions
                   launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    Self.logger.info("register watch connectivity...")
    Self.conn = Connectivity.shared
    Self.logger.info("register background task..")
    BGTaskScheduler.shared.register(forTaskWithIdentifier: "cyberme.refresh", using: nil) { task in
      Self.logger.info("enter background refresh: service is \(AppDelegate.cyberService == nil)")
      Self.cyberService?.checkCard(isForce: true) {
        Self.logger.info("background check card finished")
        Dashboard.updateWidget(inSeconds: 0)
        task.setTaskCompleted(success: true)
      }
      //reschedule by using:
      //self.scheduleFetch()
    }
    Self.flutterEngine.run(withEntrypoint: nil);
    GeneratedPluginRegistrant.register(with: Self.flutterEngine);
    let flutterViewController = FlutterViewController(
      engine: Self.flutterEngine,
      nibName: nil,
      bundle: nil)
    let channel = FlutterMethodChannel(name: "flutter/nativeSimpleChannel", binaryMessenger: flutterViewController.binaryMessenger)
    channel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "refreshWidget" {
        Dashboard.updateWidget(inSeconds: 0)
        result(nil)
      } else if call.method == "setQuickAction" {
        guard let args = call.arguments as? String,
              let jsonData = args.data(using: .utf8),
              let items = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [[String: Any]] else {
          result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid argument", details: nil))
          return
        }
        
        let quickActions: [(String, String)] = items.compactMap { item in
          guard let quick = item["quick"] as? Bool,
                quick,
                let id = item["id"] as? String,
                let name = item["name"] as? String else {
            return nil
          }
          return (id, name)
        }
        
        UserDefaults.standard.setQuickActions(quickActions)
        
        result(nil)
      } else {
        result(FlutterMethodNotImplemented)
      }
    })
    
    DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + .seconds(2)) {
      CommandRegister.dashboardRegCommand(service: AppDelegate.cyberService!)
    }
    
    return true
  }
  
  //e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"cyberme.refresh"]
  static func scheduleFetch() {
    //let request = BGAppRefreshTaskRequest(identifier: "cyberme.refresh")
    let request = BGProcessingTaskRequest(identifier: "cyberme.refresh")
    request.requiresExternalPower = true
    request.requiresNetworkConnectivity = true
    request.earliestBeginDate = Date(timeIntervalSinceNow: 60)
    
    do {
      try BGTaskScheduler.shared.submit(request)
    } catch {
      print("Could not schedule image fetch: \(error)")
    }
  }
  
  func application(
    _ application: UIApplication,
    configurationForConnecting connectingSceneSession: UISceneSession,
    options: UIScene.ConnectionOptions
  ) -> UISceneConfiguration {
    
    if let shortcutItem = options.shortcutItem {
      AppDelegate.shortcutItem = shortcutItem
    }
    
    if connectingSceneSession.role == UISceneSession.Role.carTemplateApplication {
      let scene = UISceneConfiguration(name: "CarPlay", sessionRole: connectingSceneSession.role)
      scene.delegateClass = CarPlaySceneDelegate.self
      return scene
    } else {
      let sceneConfiguration = UISceneConfiguration(
        name: "Scene Configuration",
        sessionRole: connectingSceneSession.role
      )
      sceneConfiguration.delegateClass = SceneDelegate.self
      return sceneConfiguration
    }
  }
}

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  static var needFetch: Bool = false
  func windowScene(
    _ windowScene: UIWindowScene,
    performActionFor shortcutItem: UIApplicationShortcutItem,
    completionHandler: @escaping (Bool) -> Void
  ) {
    AppDelegate.shortcutItem = shortcutItem
    completionHandler(true)
  }
  func sceneDidEnterBackground(_ scene: UIScene) {
    print("enter \(#function)")
    if Self.needFetch {
      Self.needFetch = false
      BGTaskScheduler.shared.cancelAllTaskRequests()
      print("\(#function) schedule fetch")
      AppDelegate.scheduleFetch()
    }
  }
}
