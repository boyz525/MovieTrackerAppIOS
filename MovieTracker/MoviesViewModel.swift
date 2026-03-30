//
//  MoviesViewModel.swift
//  TestPlayground
//
//  Created by Александр Малахов on 30.03.2026.
//

import Foundation

@Observable
class MoviesViewModel {

    var movies: [Movie] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil

    private let service: APIService

    init(service: APIService = APIService()) {
        self.service = service
    }

    func loadMovies() async {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            movies = try await service.fetchPopularMovies()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
