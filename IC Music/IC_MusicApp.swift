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
    
    var body: some Scene {
        WindowGroup {
            IC_SpotifyLoginView(spotifyDefaultViewModel: spotifyDefaultViewModel)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onOpenURL { url in
                    spotifyDefaultViewModel.onOpenURLOrig(url: url)
                }
                .onAppear {
                    spotifyDefaultViewModel.didBecomeActive()
                }
                .onDisappear {
                    spotifyDefaultViewModel.willResignActive()
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
            IC_SpinningPlaylistView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onOpenURL { url in
                    spotifyDefaultViewModel.onOpenURL(url: url)
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didFinishLaunchingNotification), perform: { _ in
                    spotifyDefaultViewModel.connectUser()
                })
                .onAppear {
                    spotifyDefaultViewModel.connectUser()
                    spotifyDefaultViewModel.didBecomeActive()
                }
                .onDisappear {
                    spotifyDefaultViewModel.willResignActive()
                }
            
        }
        .onChange(of: scenePhase) { //phase in
            switch scenePhase {
            case .background:
                print("background")
                try? persistenceController.container.viewContext.save()
            case .active:
                
                if !hasTimeElapsed {
                    hasTimeElapsed = true
                }
                else {
                    spotifyDefaultViewModel.connect()
                }
            default: break
            }
        }
    }
    */
}