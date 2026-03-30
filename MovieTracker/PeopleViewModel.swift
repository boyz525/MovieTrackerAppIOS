//
//  PeopleViewModel.swift
//  MovieTracker
//

import Foundation

@Observable
@MainActor
class PeopleViewModel {
    var people:        [Person] = []
    var isLoading:     Bool     = false
    var isLoadingMore: Bool     = false
    var errorMessage:  String?  = nil

    private var currentPage = 1
    private var totalPages  = 1
    private let service     = APIService()

    var canLoadMore: Bool { currentPage < totalPages && !isLoadingMore && !isLoading }

    func load() async {
        currentPage  = 1
        people       = []
        isLoading    = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let r  = try await service.fetchPeople(page: 1)
            people = r.results
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
            let r = try await service.fetchPeople(page: currentPage + 1)
            people.append(contentsOf: r.results)
            currentPage += 1
        } catch {}
    }
}
