//
//  MarsExplorerApp.swift
//  MarsExplorer
//
//  Created by Muhammed Kocabas on 2023-02-21.
//

import SwiftUI

@main
struct MarsExplorerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            FavouritePhotosView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
