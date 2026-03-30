//
//  FavoritesManager.swift
//  MovieTracker
//

import Foundation

@Observable
@MainActor
final class FavoritesManager {
    static let shared = FavoritesManager()

    private(set) var movieIDs:  Set<Int> = []
    private(set) var showIDs:   Set<Int> = []
    private(set) var personIDs: Set<Int> = []

    private(set) var movies:  [Movie]   = []
    private(set) var shows:   [TVShow]  = []
    private(set) var people:  [Person]  = []

    private init() { load() }

    // MARK: - Toggle

    func toggle(_ movie: Movie) {
        if movieIDs.contains(movie.id) {
            movieIDs.remove(movie.id)
            movies.removeAll { $0.id == movie.id }
        } else {
            movieIDs.insert(movie.id)
            movies.append(movie)
        }
        save()
    }

    func toggle(_ show: TVShow) {
        if showIDs.contains(show.id) {
            showIDs.remove(show.id)
            shows.removeAll { $0.id == show.id }
        } else {
            showIDs.insert(show.id)
            shows.append(show)
        }
        save()
    }

    func toggle(_ person: Person) {
        if personIDs.contains(person.id) {
            personIDs.remove(person.id)
            people.removeAll { $0.id == person.id }
        } else {
            personIDs.insert(person.id)
            people.append(person)
        }
        save()
    }

    var isEmpty: Bool { movies.isEmpty && shows.isEmpty && people.isEmpty }

    // MARK: - Persistence

    private func save() {
        let enc = JSONEncoder()
        if let d = try? enc.encode(movies)  { UserDefaults.standard.set(d, forKey: "fav_movies") }
        if let d = try? enc.encode(shows)   { UserDefaults.standard.set(d, forKey: "fav_shows") }
        if let d = try? enc.encode(people)  { UserDefaults.standard.set(d, forKey: "fav_people") }
    }

    private func load() {
        let dec = JSONDecoder()
        if let d = UserDefaults.standard.data(forKey: "fav_movies"),
           let v = try? dec.decode([Movie].self, from: d) {
            movies = v; movieIDs = Set(v.map(\.id))
        }
        if let d = UserDefaults.standard.data(forKey: "fav_shows"),
           let v = try? dec.decode([TVShow].self, from: d) {
            shows = v; showIDs = Set(v.map(\.id))
        }
        if let d = UserDefaults.standard.data(forKey: "fav_people"),
           let v = try? dec.decode([Person].self, from: d) {
            people = v; personIDs = Set(v.map(\.id))
        }
    }
}
