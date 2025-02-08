//
//  IC_MusicApp.swift
//  IC Music
//
//  Created by Andreas Franke on 25.02.24.
//

import SwiftUI
import Combine
import UIKit

// no changes in your AppDelegate class
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print(">> your code here !!")
        // Override point for customization after application launch.
        let defaults = UserDefaults.standard
        let isPreloaded = defaults.bool(forKey: "isPreloaded")
        if !isPreloaded {
            print("Preloading data for the first time")
            //preloadData()
            defaults.set(true, forKey: "isPreloaded")
        }
        return true
    }
}

@main
struct IC_MusicApp: App {
    @StateObject var spotifyDefaultViewModel = { IC_SpotifyDefaultViewModel.shared } ()
    
    let persistenceController = PersistenceController.shared
    
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            IC_SpotifyLoginView(spotifyDefaultViewModel: spotifyDefaultViewModel)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onOpenURL { url in
                    print("onOpenURL WindwGroup")
                    spotifyDefaultViewModel.onOpenURL(url: url)
                }
            //.onReceive(NotificationCenter.default.publisher(for: UIApplication.didFinishLaunchingNotification), perform: { _ in
            //    spotifyDefaultViewModel.connect()
            //})
                .onAppear {
                    print("onAppear WindwGroup")
                    spotifyDefaultViewModel.didBecomeActive()
                }
                .onDisappear {
                    print("onDisappear WindwGroup")
                    spotifyDefaultViewModel.willResignActive()
                }
        }
        .onChange(of: scenePhase) { //phase in
            switch scenePhase {
            case .background:
                print("scene in background")
                let context = persistenceController.container.viewContext
                if context.hasChanges {
                    do {
                        try context.save()
                    } catch {
                        // Replace this implementation with code to handle the error appropriately.
                        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                        let nserror = error as NSError
                        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                    }
                }
                break
                
            case .inactive:
                //print("inactive scene")
                break
            case .active:
                //print("aktive scene")
                break
                
            default: break
            }
        }
    }
    /*
     // inject into SwiftUI life-cycle via adaptor !!!
     @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
     
     @Environment(\.scenePhase) var scenePhase
     
     @State private var hasTimeElapsed = false
     var body: some Scene {
     WindowGroup {
     //IC_MusicPlaylistsSelectionView()
     //IC_SpinningPlaylistView()
     IC_SpotifyLoginView(spotifyDefaultViewModel: spotifyDefaultViewModel)
     .environment(\.managedObjectContext, persistenceController.container.viewContext)
     .onOpenURL { url in
     spotifyDefaultViewModel.onOpenURL(url: url)
     }
     /*.onReceive(NotificationCenter.default.publisher(for: UIApplication.didFinishLaunchingNotification), perform: { _ in
      spotifyDefaultViewModel.connectUser()
      })*/
     .onAppear {
     //spotifyDefaultViewModel.connectUser()
     //spotifyDefaultViewModel.didBecomeActive()
     spotifyDefaultViewModel.didPressPlayPauseButton()
     }
     .onDisappear {
     spotifyDefaultViewModel.willResignActive()
     }
     
     }
     .onChange(of: scenePhase) { //phase in
     switch scenePhase {
     case .background:
     print("background")
     
     //try? persistenceController.container.viewContext.save()
     let context = persistenceController.container.viewContext
     if context.hasChanges {
     do {
     try context.save()
     } catch {
     // Replace this implementation with code to handle the error appropriately.
     // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
     let nserror = error as NSError
     fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
     }
     }
     break
     
     case .inactive:
     
     break
     //case .active:
     //
     //    if !hasTimeElapsed {
     //        hasTimeElapsed = true
     //    }
     //    else {
     //       spotifyDefaultViewModel.connect()
     //    }
     
     default: break
     }
     }
     }
     */
}
