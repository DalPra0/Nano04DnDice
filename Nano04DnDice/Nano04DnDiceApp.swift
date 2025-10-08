//
//  Nano04DnDiceApp.swift
//  Nano04DnDice
//
//  Created by Lucas Dal Pra Brascher on 08/10/25.
//

import SwiftUI
import CoreData

@main
struct Nano04DnDiceApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
