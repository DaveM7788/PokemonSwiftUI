//
//  PokemonSwiftUIApp.swift
//  PokemonSwiftUI
//
//  Created by David McDermott on 9/11/23.
//

import SwiftUI

@main
struct PokemonSwiftUIApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
