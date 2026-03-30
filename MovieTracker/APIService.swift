//
//  APIService.swift
//  MovieTracker
//

import Foundation

struct APIService {
    private let apiKey  = "Your_Token_Here"
    private let baseURL = "https://api.themoviedb.org/3"
    private var lang: String { "language=ru-RU&api_key=\(apiKey)" }

    // MARK: - Movies

    func fetchMovies(sort: SortOption = .popular, page: Int = 1) async throws -> MoviesResponse {
        try await get("\(sort.movieEndpoint)?\(lang)&page=\(page)")
    }

    // MARK: - TV Shows

    func fetchShows(sort: SortOption = .popular, page: Int = 1) async throws -> TVShowsResponse {
        try await get("\(sort.tvEndpoint)?\(lang)&page=\(page)")
    }

    // MARK: - People

    func fetchPeople(page: Int = 1) async throws -> PeopleResponse {
        try await get("/person/popular?\(lang)&page=\(page)")
    }

    // MARK: - Search

    func search(query: String, page: Int = 1) async throws -> SearchResponse {
        guard !query.isEmpty else { return SearchResponse(page: 1, results: [], totalPages: 0) }
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        return try await get("/search/multi?\(lang)&query=\(encoded)&page=\(page)")
    }

    // MARK: - Generic

    private func get<T: Decodable>(_ path: String) async throws -> T {
        guard let url = URL(string: baseURL + path) else { throw URLError(.badURL) }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
}
