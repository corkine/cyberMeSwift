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
    //@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var phase
    var body: some Scene {
        WindowGroup {
            CyberNav().environmentObject(cyberService)
                .onOpenURL { url in
                    guard url.scheme == "cyberme" else { return }
                    switch url.description {
                    case "cyberme://checkCardIfNeed":
                        if TimeUtil.needCheckCard {
                            cyberService.checkCard()
                        }
                        break
                    default:
                        print("no handler for \(url)")
                    }
                }
        }
        .onChange(of: phase) { newValue in
            switch newValue {
            case .active:
                Dashboard.updateWidget(inSeconds: 300)
                break
            case .background:
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
}
