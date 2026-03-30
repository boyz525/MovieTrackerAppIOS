//
//  MainTabView.swift
//  MovieTracker
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            Tab("Фильмы", systemImage: "film") {
                MoviesListView()
            }
            Tab("Сериалы", systemImage: "tv") {
                TVShowsListView()
            }
            Tab("Актёры", systemImage: "person.2") {
                PeopleListView()
            }
            Tab("Избранное", systemImage: "heart.fill") {
                FavoritesView()
            }
            Tab(role: .search) {
                SearchView()
            }
        }
    }
}
