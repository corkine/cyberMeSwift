//
//  helloSwiftApp.swift
//  helloSwift
//
//  Created by corkine on 2022/8/31.
//

import SwiftUI
import BackgroundTasks
import WidgetKit
import UIKit

@main
struct helloSwiftApp: App {
    @StateObject var cyberService = CyberService()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var phase
    var body: some Scene {
        WindowGroup {
            CyberNav().environmentObject(cyberService)
                .onOpenURL { url in
                    guard url.scheme == "cyberme" else { return }
                    switch url.description {
                    case "cyberme://checkCardIfNeed":
                        if TimeUtil.needCheckCard {
                            cyberService.checkCard {
                                Dashboard.updateWidget(inSeconds: 0)
                            }
                        }
                        break
                    case "cyberme://checkCardForce":
                        cyberService.checkCard(isForce:true) {
                            Dashboard.updateWidget(inSeconds: 0)
                        }
                        break
                    case "cyberme://syncTodo":
                        cyberService.syncTodo {
                            cyberService.fetchSummary()
                            Dashboard.updateWidget(inSeconds: 0)
                        }
                        break
                    case "cyberme://syncWidget":
                        Dashboard.updateWidget(inSeconds: 0)
                        break
                    case "cyberme://healthcard":
                        let url = URL(string: "alipay://platformapi/startapp?appId=2021001132656455")!
                        UIApplication.shared.open(url)
                    default:
                        print("no handler for \(url)")
                    }
                }
        }
        .onChange(of: phase) { newValue in
            switch newValue {
            case .active:
                handleQuickAction()
                Dashboard.updateWidget(inSeconds: 300)
                break
            case .background:
                addDynamicQuickActions()
                break
            default: break
            }
        }
        //        .onChange(of: phase) { newValue in
        //            switch newValue {
        //            case .background: scheduleAppRefresh()
        //            default: break
        //            }
        //        }
        //        .backgroundTask(.appRefresh("cyberme.refresh")) {
        //            WidgetCenter.shared.reloadAllTimelines()
        //        }
        
    }
    
    //    func scheduleAppRefresh() {
    //        let req = BGAppRefreshTaskRequest(identifier: "cyberme.refresh")
    //        //req.earliestBeginDate = Date().addingTimeInterval(24 * 3600)
    //        try? BGTaskScheduler.shared.submit(req)
    //    }
    
    private func addDynamicQuickActions() {
        UIApplication.shared.shortcutItems = [
            UIApplicationShortcutItem(
                type: "syncTodo",
                localizedTitle: "同步待办事项",
                localizedSubtitle: nil,
                icon: UIApplicationShortcutIcon(systemImageName: "arrow.triangle.2.circlepath"),
                userInfo: nil
            ),
            UIApplicationShortcutItem(
                type: "checkCardForce",
                localizedTitle: "打卡信息确认",
                localizedSubtitle: nil,
                icon: UIApplicationShortcutIcon(systemImageName: "wallet.pass"),
                userInfo: nil
            ),
            UIApplicationShortcutItem(
                type: "addLog",
                localizedTitle: "新建项目日志",
                localizedSubtitle: nil,
                icon:UIApplicationShortcutIcon(systemImageName: "tray.and.arrow.down")
            )
        ]
    }
    
    private func handleQuickAction() {
        guard let shortcutItem = appDelegate.shortcutItem else { return }
        switch shortcutItem.type {
        case "syncTodo":
            cyberService.syncTodo {
                cyberService.fetchSummary()
                Dashboard.updateWidget(inSeconds: 0)
            }
            break
        case "checkCardForce":
            cyberService.checkCard(isForce: true) {
                Dashboard.updateWidget(inSeconds: 0)
            }
            break
        case "addLog":
            break
        default:
            break
        }
        AppDelegate.shortcutItem = nil
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    //    func application(_ application: UIApplication,
    //                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    //        registerBackgroundTaks()
    //        return true
    //    }
    //
    //    private func registerBackgroundTaks() {
    //        BGTaskScheduler.shared.register(forTaskWithIdentifier: "cyberme.refresh", using: nil) { task in
    //            print("enter background refresh:")
    //            Dashboard.updateWidget(inSeconds: 300)
    //            task.setTaskCompleted(success: true)
    //            task.expirationHandler = {
    //                self.scheduleRefresh()
    //            }
    //            self.scheduleRefresh()
    //        }
    //    }
    //
    //
    //    func applicationDidEnterBackground(_ application: UIApplication) {
    //        //scheduleRefresh()
    //    }
    //
    //    //e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateExpirationForTaskWithIdentifier:@"cyberme.refresh"]
    //    func scheduleRefresh() {
    //        let request = BGAppRefreshTaskRequest(identifier: "cyberme.refresh")
    //        request.earliestBeginDate = Date(timeIntervalSinceNow: 5 * 60)
    //        do {
    //            try BGTaskScheduler.shared.submit(request)
    //            print("submit refresh task")
    //        } catch {
    //            print("Could not schedule refresh: \(error)")
    //        }
    //    }
    //
    //    func cancelAllPendingBGTask() {
    //        BGTaskScheduler.shared.cancelAllTaskRequests()
    //    }
    //
    //    func checkBackgroundRefreshStatus() {
    //      switch UIApplication.shared.backgroundRefreshStatus {
    //      case .available:
    //        print("Background fetch is enabled")
    //      case .denied:
    //        print("Background fetch is explicitly disabled")
    //
    //        // Redirect user to Settings page only once; Respect user's choice is important
    //        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    //      case .restricted:
    //        // Should not redirect user to Settings since he / she cannot toggle the settings
    //        print("Background fetch is restricted, e.g. under parental control")
    //      default:
    //        print("Unknown property")
    //      }
    //    }
    
    var shortcutItem: UIApplicationShortcutItem? { AppDelegate.shortcutItem }
    
    fileprivate static var shortcutItem: UIApplicationShortcutItem?
    
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        if let shortcutItem = options.shortcutItem {
            AppDelegate.shortcutItem = shortcutItem
        }
        
        let sceneConfiguration = UISceneConfiguration(
            name: "Scene Configuration",
            sessionRole: connectingSceneSession.role
        )
        sceneConfiguration.delegateClass = SceneDelegate.self
        
        return sceneConfiguration
    }
}

private final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    func windowScene(
        _ windowScene: UIWindowScene,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        AppDelegate.shortcutItem = shortcutItem
        completionHandler(true)
    }
}
