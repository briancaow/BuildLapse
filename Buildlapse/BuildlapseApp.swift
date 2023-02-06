//
//  BuildlapseApp.swift
//  Buildlapse
//
//  Created by Brian Cao on 2/6/23.
//

import SwiftUI

@main
struct BuildlapseApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
