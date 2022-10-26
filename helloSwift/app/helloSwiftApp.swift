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
import os

@main
struct helloSwiftApp: App {
    @StateObject var cyberService = CyberService()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var phase
    @State var tappedCheckCard = false
    var body: some Scene {
        WindowGroup {
            CyberNav().environmentObject(cyberService)
                .onOpenURL { url in
                    guard url.scheme == "cyberme" else { return }
                    let input = url.description
                    switch input {
                    case _ where input.hasPrefix("cyberme://checkCardIfNeed"):
                        if TimeUtil.needCheckCard {
                            cyberService.checkCard {
                                Dashboard.updateWidget(inSeconds: 0)
                            }
                        }
                        break
                    case _ where input.hasPrefix("cyberme://checkCardForce"):
                        cyberService.checkCard(isForce:true) {
                            Dashboard.updateWidget(inSeconds: 0)
                        }
                        break
                    case _ where input.hasPrefix("cyberme://checkCardHCM"):
                        if let name = cyberService.settings["hcmShortcutName"], name != "" {
                            let url = URL(string: "shortcuts://run-shortcut?name=\(name)")!
                            self.tappedCheckCard = true
                            appDelegate.cyberService = cyberService
                            UIApplication.shared.open(url)
                        } else {
                            cyberService.alertInfomation = "请设置云上协同打卡的捷径名称（英文）"
                        }
                        break
                    case _ where input.hasPrefix("cyberme://syncTodo"):
                        cyberService.syncTodo {
                            cyberService.fetchSummary()
                            Dashboard.updateWidget(inSeconds: 0)
                        }
                        break
                    case _ where input.hasPrefix("cyberme://syncWidget"):
                        Dashboard.updateWidget(inSeconds: 0)
                        break
                    case _ where input.hasPrefix("cyberme://healthcard"):
                        if let name = cyberService.settings["healthURL"], name != "" {
                            let url = URL(string: name)!
                            UIApplication.shared.open(url)
                        } else {
                            let url = URL(string: "alipay://platformapi/startapp?appId=2021001132656455")!
                            UIApplication.shared.open(url)
                        }
                        break
                    case _ where input.hasPrefix("cyberme://uploadHealthData"):
                        cyberService.showBodyMassSheet = true
                        if let name = cyberService.settings["syncHealthShortcutName"],
                               name != "" {
                            let url = URL(string: "shortcuts://run-shortcut?name=\(name)")!
                            UIApplication.shared.open(url)
                        } else {
                            cyberService.alertInfomation = "请设置健身记录上传的捷径名称（英文）"
                        }
                        break
                    case _ where input.hasPrefix("cyberme://showWeather"):
                        let url = URL(string: "caiyunapppro://weather")!
                        UIApplication.shared.open(url)
                        break
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
                if tappedCheckCard {
                    print("wait check card finish and refresh in background...")
                    appDelegate.scheduleFetch()
                    DispatchQueue.main.async {
                        tappedCheckCard = false
                    }
                }
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
                type: "checkCardForce",
                localizedTitle: "打卡信息确认",
                localizedSubtitle: nil,
                icon: UIApplicationShortcutIcon(systemImageName: "wallet.pass"),
                userInfo: nil
            ),
            UIApplicationShortcutItem(
                type: "syncTodo",
                localizedTitle: "同步待办事项",
                localizedSubtitle: nil,
                icon: UIApplicationShortcutIcon(systemImageName: "arrow.triangle.2.circlepath"),
                userInfo: nil
            ),
            UIApplicationShortcutItem(
                type: "bodyMassManage",
                localizedTitle: "体重管理",
                localizedSubtitle: nil,
                icon:UIApplicationShortcutIcon(systemImageName: "scalemass")
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
        case "bodyMassManage":
            cyberService.showBodyMassSheet = true
            break
        default:
            break
        }
        AppDelegate.shortcutItem = nil
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: AppDelegate.self)
    )
    var cyberService: CyberService?
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions
                     launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        registerBackgroundTaks()
        return true
    }

    private func registerBackgroundTaks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "cyberme.refresh", using: nil) { task in
            Self.logger.info("enter background refresh:")
            self.cyberService?.checkCard(isForce: true) {
                Self.logger.info("background check card finished")
                Dashboard.updateWidget(inSeconds: 0)
                task.setTaskCompleted(success: true)
            }
            //reschedule by using:
            //self.scheduleFetch()
        }
    }


    //        func applicationDidEnterBackground(_ application: UIApplication) {
    //            print("app did enter background")
    //            scheduleFetch()
    //        }

    //e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateExpirationForTaskWithIdentifier:@"cyberme.refresh"]
    func scheduleFetch() {
        let request = BGProcessingTaskRequest(identifier: "cyberme.refresh")
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = true

        request.earliestBeginDate = Date(timeIntervalSinceNow: 1 * 60)

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule image fetch: \(error)")
        }
    }
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
