//
//  APIService.swift
//  TestPlayground
//
//  Created by Александр Малахов on 30.03.2026.
//

import Foundation

struct APIService {

    private let apiKey = "YOURS_API_HERE"
    private let baseURL = "https://api.themoviedb.org/3"

    func fetchPopularMovies() async throws -> [Movie] {
        let urlString = "\(baseURL)/movie/popular?api_key=\(apiKey)&language=ru-RU"

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let responseObject = try decoder.decode(MoviesResponse.self, from: data)
        return responseObject.results
    }
}
