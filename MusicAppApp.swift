//
//  MusicAppApp.swift
//  MusicApp
//
//  Created by Dawid Nowacki on 03/02/2024.
//

import SwiftUI

@main
struct MusicAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView(expandSheet: .constant(true), animation: Namespace().wrappedValue)
                .preferredColorScheme(.dark)
        }
    }
}
