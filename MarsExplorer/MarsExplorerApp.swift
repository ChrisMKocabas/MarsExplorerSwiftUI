//
//  MarsExplorerApp.swift
//  MarsExplorer
//
//  Created by Muhammed Kocabas on 2023-02-21.
//

import SwiftUI
import Firebase
import FirebaseCore
import FirebaseAuth


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main 
struct MarsExplorerApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    let persistenceController = PersistenceController.shared
    // create an instance of AuthenticationViewModel and pass it as an environment object
    
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                AuthenticatedView {
                    FavouritePhotosView()
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                }
            }
        }
    }
}
