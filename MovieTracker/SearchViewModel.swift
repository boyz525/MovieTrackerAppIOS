//
//  SearchViewModel.swift
//  MovieTracker
//

import Foundation

@Observable
@MainActor
class SearchViewModel {
    var query:     String         = ""
    var results:   [SearchResult] = []
    var isLoading: Bool           = false

    private let service = APIService()
    private var task: Task<Void, Never>?

    func search() {
        task?.cancel()
        let q = query.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { results = []; return }

        task = Task {
            try? await Task.sleep(nanoseconds: 400_000_000)
            guard !Task.isCancelled else { return }
            isLoading = true
            defer { isLoading = false }
            if let r = try? await service.search(query: q) {
                results = r.results
            }
        }
    }

    func clear() {
        task?.cancel()
        query   = ""
        results = []
    }
}
