//
//  TVShowsViewModel.swift
//  MovieTracker
//

import Foundation

@Observable
@MainActor
class TVShowsViewModel {
    var shows:         [TVShow] = []
    var isLoading:     Bool     = false
    var isLoadingMore: Bool     = false
    var errorMessage:  String?  = nil
    var sortOption:    SortOption = .popular

    private var currentPage = 1
    private var totalPages  = 1
    private let service     = APIService()

    var canLoadMore: Bool { currentPage < totalPages && !isLoadingMore && !isLoading }

    func load() async {
        currentPage  = 1
        shows        = []
        isLoading    = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let r  = try await service.fetchShows(sort: sortOption, page: 1)
            shows  = r.results
            totalPages = r.totalPages
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func loadMore() async {
        guard canLoadMore else { return }
        isLoadingMore = true
        defer { isLoadingMore = false }
        do {
            let r = try await service.fetchShows(sort: sortOption, page: currentPage + 1)
            shows.append(contentsOf: r.results)
            currentPage += 1
        } catch {}
    }
}
