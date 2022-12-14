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
import CoreData

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
                    AppDelegate.cyberService = cyberService
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
    
    private func handleOpenUrl(_ url: URL) {
        guard url.scheme == "cyberme" else { return }
        let input = url.description
        switch input {
        case _ where input.hasPrefix(CyberUrl.checkCardIfNeed):
            if TimeUtil.needCheckCard {
                cyberService.checkCard {
                    Dashboard.updateWidget(inSeconds: 0)
                    cyberService.fetchSummary()
                }
            }
            break
        case _ where input.hasPrefix(CyberUrl.checkCardForce):
            cyberService.checkCard(isForce:true) {
                Dashboard.updateWidget(inSeconds: 0)
                cyberService.fetchSummary()
            }
            break
        case _ where input.hasPrefix(CyberUrl.checkCardHCM):
            if let name = cyberService.settings[Setting.hcmShortcutName], name != "" {
                let url = URL(string: Default.UrlScheme.shortcutUrl(name))!
                //??????????????????????????????
                //self.tappedCheckCard = true
                UIApplication.shared.open(url)
            } else {
                cyberService.alertInfomation = "??????????????????????????????????????????????????????"
            }
            break
        case _ where input.hasPrefix(CyberUrl.syncTodo):
            cyberService.syncTodo {
                cyberService.fetchSummary()
                Dashboard.updateWidget(inSeconds: 0)
            }
            break
        case _ where input.hasPrefix(CyberUrl.syncWidget):
            Dashboard.updateWidget(inSeconds: 0)
            break
        case _ where input.hasPrefix(CyberUrl.healthCard):
            let url = URL(string: Default.UrlScheme.alipayHealthApp)!
            UIApplication.shared.open(url)
            break
        case _ where input.hasPrefix(CyberUrl.showBodyMass):
            cyberService.showBodyMassSheetFetch = (true, true)
            break
        case _ where input.hasPrefix(CyberUrl.uploadHealthData):
            if let name = cyberService.settings[Setting.syncHealthShortcutName],
                   name != "" {
                let url = URL(string: Default.UrlScheme.shortcutUrl(name))!
                UIApplication.shared.open(url)
            } else {
                cyberService.alertInfomation = "??????????????????????????????????????????????????????"
            }
            break
        case _ where input.hasPrefix(CyberUrl.showWeather):
            UIApplication.shared.open(URL(string: Default.UrlScheme.caiyunWeather)!)
            break
        case _ where input.hasPrefix(CyberUrl.showMiHome):
            UIApplication.shared.open(URL(string: Default.UrlScheme.miHome)!)
            break
        default:
            print("no handler for \(url)")
        }
    }
    
    private func addDynamicQuickActions() {
        UIApplication.shared.shortcutItems = [
            //            UIApplicationShortcutItem(
            //                type: "checkCardForce",
            //                localizedTitle: "??????????????????",
            //                localizedSubtitle: nil,
            //                icon: UIApplicationShortcutIcon(systemImageName: "wallet.pass"),
            //                userInfo: nil
            //            ),
            //            UIApplicationShortcutItem(
            //                type: "syncTodo",
            //                localizedTitle: "??????????????????",
            //                localizedSubtitle: nil,
            //                icon: UIApplicationShortcutIcon(systemImageName: "arrow.triangle.2.circlepath"),
            //                userInfo: nil
            //            ),
            UIApplicationShortcutItem(
                type: "alert",
                localizedTitle: "????????????",
                localizedSubtitle: "????????????????????????????????????",
                icon:UIApplicationShortcutIcon(systemImageName: "eye")
            ),
            UIApplicationShortcutItem(
                type: "noAlert",
                localizedTitle: "??????????????????",
                localizedSubtitle: nil,
                icon:UIApplicationShortcutIcon(systemImageName: "eye.slash")
            ),
            UIApplicationShortcutItem(
                type: "hcmCheckCard",
                localizedTitle: "HCM ??????",
                localizedSubtitle: nil,
                icon:UIApplicationShortcutIcon(systemImageName: "menucard.fill")
            ),
            UIApplicationShortcutItem(
                type: "bodyMassManage",
                localizedTitle: "????????????",
                localizedSubtitle: nil,
                icon:UIApplicationShortcutIcon(systemImageName: "scalemass")
            )
        ]
    }
    
    private func handleQuickAction() {
        guard let shortcutItem = appDelegate.shortcutItem else { return }
        switch shortcutItem.type {
        case "alert":
            CyberService.userDefault.set(true, forKey: "alert")
            //Dashboard.updateWidget(inSeconds: 0)
            UIApplication.shared.open(URL(string:Default.UrlScheme.shortcutUrl(
                Default.UrlScheme.alertShortcutName))!)
            break
        case "noAlert":
            CyberService.userDefault.set(false, forKey: "alert")
            //Dashboard.updateWidget(inSeconds: 0)
            UIApplication.shared.open(URL(string:Default.UrlScheme.shortcutUrl(
                Default.UrlScheme.noAlertShortcutName))!)
            break
        case "hcmCheckCard":
            if let name = cyberService.settings[Setting.hcmShortcutName], name != "" {
                let url = URL(string: Default.UrlScheme.shortcutUrl(name))!
                UIApplication.shared.open(url)
            }
            break
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
            cyberService.showBodyMassSheetFetch = (true,true)
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
    static var cyberService: CyberService?
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions
                     launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
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
