//
//  MovieTrackerApp.swift
//  MovieTracker
//

import SwiftUI

@main
struct MovieTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(FavoritesManager.shared)
        }
    }
}
