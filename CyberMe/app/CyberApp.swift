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
    func checkAddExpress() {
        if let content = UIPasteboard.general.string {
            if !content.isEmpty && (content.allSatisfy({ $0.isNumber })
                                    || content.lowercased().starts(with: "sf")
                                    || content.lowercased().starts(with: "jd")) {
                cyberService.expressTrackFromAutoDetect = true
                cyberService.showExpressTrack = true
                return
            }
        }
        cyberService.showExpressTrack = false
    }
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
                checkAddExpress()
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
                //暂时不再触发背景刷新
                //self.tappedCheckCard = true
                UIApplication.shared.open(url)
            } else {
                cyberService.alertInfomation = "请设置云上协同打卡的捷径名称（英文）"
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
        case _ where input.hasPrefix(CyberUrl.showBodyMass):
            cyberService.showBodyMassView(withFetch: true)
            break
        case _ where input.hasPrefix(CyberUrl.uploadHealthData):
            if let name = cyberService.settings[Setting.syncHealthShortcutName],
                   name != "" {
                let url = URL(string: Default.UrlScheme.shortcutUrl(name))!
                UIApplication.shared.open(url)
            } else {
                cyberService.alertInfomation = "请设置健身记录上传的捷径名称（英文）"
            }
            break
        case _ where input.hasPrefix(CyberUrl.showWeather):
            UIApplication.shared.open(URL(string: Default.UrlScheme.caiyunWeather)!)
            break
        case _ where input.hasPrefix(CyberUrl.showMiHome):
            UIApplication.shared.open(URL(string: Default.UrlScheme.miHome)!)
            break
        case _ where input.hasPrefix(CyberUrl.showTodoist):
            UIApplication.shared.open(URL(string: Default.UrlScheme.todoist)!)
            break
        case _ where input.hasPrefix(CyberUrl.show12306):
            UIApplication.shared.open(URL(string: Default.UrlScheme.train12306)!)
            break
        case _ where input.hasPrefix(CyberUrl.showCal):
            UIApplication.shared.open(URL(string: Default.UrlScheme.calApp)!)
            break
        case _ where input.hasPrefix(CyberUrl.goLink):
            print("handle add short link \(url)")
            cyberService.originUrl = url.queryOf("url") ?? ""
            cyberService.showGoView = true
        case _ where input.hasPrefix(CyberUrl.addNoteLink):
            print("handle add note link \(url)")
            cyberService.noteContent = url.queryOf("content") ?? ""
            cyberService.showAddNoteView = true
        case _ where input.hasPrefix(CyberUrl.gptQuestion):
            if let question = url.queryOf("question"),
               let decodeQuestion = question.fromBase64() {
                cyberService.questionContent = "AUTO" + decodeQuestion
                print("handle gpt question \(cyberService.questionContent)")
                cyberService.showGptQuestionView = true
            } else if let translate = url.queryOf("translate"),
                      let decodeTraslate = translate.fromBase64() {
                cyberService.questionContent = "AUTO" + decodeTraslate
                print("handle gpt translate \(cyberService.questionContent)")
                cyberService.showGptTranslateView = true
            }
        case _ where input.hasPrefix(CyberUrl.showLastDiary):
            cyberService.showLastDiary = true
        default:
            print("no handler for \(url)")
        }
    }
    
    private func addDynamicQuickActions() {
        UIApplication.shared.shortcutItems = [
            UIApplicationShortcutItem(
                type: "hcmCheckCard",
                localizedTitle: "HCM 打卡",
                localizedSubtitle: nil,
                icon:UIApplicationShortcutIcon(systemImageName: "checkmark.square")
            ),
//            UIApplicationShortcutItem(
//                type: "todayDiary",
//                localizedTitle: "今天日记",
//                localizedSubtitle: nil,
//                icon:UIApplicationShortcutIcon(systemImageName: "book.closed")
//            )
            UIApplicationShortcutItem(
                type: "syncTodo",
                localizedTitle: "TODO 同步",
                localizedSubtitle: nil,
                icon:UIApplicationShortcutIcon(systemImageName: "arrow.triangle.2.circlepath")
            ),
            UIApplicationShortcutItem(
                type: "alert",
                localizedTitle: "警戒模式",
                localizedSubtitle: nil,
                icon:UIApplicationShortcutIcon(systemImageName: "eye")
            ),
            UIApplicationShortcutItem(
                type: "noAlert",
                localizedTitle: "退出警戒模式",
                localizedSubtitle: nil,
                icon:UIApplicationShortcutIcon(systemImageName: "eye.slash")
            ),
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
            cyberService.syncTodo = true
            cyberService.syncTodo {
                cyberService.syncTodo = false
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
        case "foodBalanceAdd":
            cyberService.goToView = .foodBalanceAdd
            break
        case "bodyMassManage":
            cyberService.showBodyMassView(withFetch: true)
            break
        case "todayDiary":
            cyberService.showLastDiary = true
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
    static let flutterEngine = FlutterEngine(name: "flutterEngine")
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
        Self.flutterEngine.run();
        GeneratedPluginRegistrant.register(with: Self.flutterEngine);
        
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
