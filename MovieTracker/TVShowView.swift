//
//  TVShowView.swift
//  MovieTracker
//

import SwiftUI

// MARK: - TV Shows List

struct TVShowsListView: View {
    @State private var viewModel = TVShowsViewModel()
    @Environment(FavoritesManager.self) private var favorites

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            ZStack(alignment: .center) {
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.shows) { show in
                            NavigationLink(value: show) {
                                TVShowCard(show: show, favorites: favorites)
                            }
                            .buttonStyle(.plain)
                            .onAppear {
                                if show.id == viewModel.shows.last?.id {
                                    Task { await viewModel.loadMore() }
                                }
                            }
                        }
                        if viewModel.isLoadingMore {
                            LoadMoreSpinner().gridCellColumns(2)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 100)
                }

                if viewModel.isLoading              { LoadingOverlay() }
                else if let e = viewModel.errorMessage { ErrorOverlay(message: e) }
            }
            .navigationTitle("Сериалы")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    SortMenuButton(current: viewModel.sortOption) { option in
                        viewModel.sortOption = option
                        Task { await viewModel.load() }
                    }
                }
            }
            .task(id: viewModel.sortOption) { await viewModel.load() }
            .navigationDestination(for: TVShow.self) { show in
                TVShowDetailView(show: show)
            }
        }
    }
}

// MARK: - TV Show Card

struct TVShowCard: View {
    let show: TVShow
    let favorites: FavoritesManager

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            PosterImage(path: show.posterPath, height: 200)

            VStack(alignment: .leading, spacing: 5) {
                Text(show.name)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(2)
                    .foregroundStyle(.primary)

                HStack(spacing: 5) {
                    Image(systemName: "star.fill").font(.caption2).foregroundStyle(.yellow)
                    Text(String(format: "%.1f", show.voteAverage))
                        .font(.caption2).foregroundStyle(.secondary)
                    if let year = show.firstAirDate?.releaseYear, !year.isEmpty {
                        Text("·").font(.caption2).foregroundStyle(.tertiary)
                        Text(year).font(.caption2).foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.top, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 72, alignment: .top)
        }
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .glassEffect(in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(alignment: .topTrailing) {
            FavoriteButton(isFavorite: favorites.showIDs.contains(show.id)) {
                favorites.toggle(show)
            }
            .padding(8)
        }
    }
}

// MARK: - TV Show Detail (iOS 26 / Apple Music style)

struct TVShowDetailView: View {
    let show: TVShow
    @Environment(FavoritesManager.self) private var favorites

    private var posterURL: URL? {
        show.posterPath?.posterURL(size: "w780")
    }

    var body: some View {
        ZStack {
            DetailBlurBackground(url: posterURL)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    DetailReflection(url: posterURL)

                    DetailPosterCard(url: posterURL)
                        .padding(.top, -50)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 8)

                    DetailBlurTransition()

                    VStack(spacing: 20) {
                        Text(show.name)
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)

                        MetaPillsRow(items: [
                            (String(format: "%.1f", show.voteAverage), "star.fill"),
                            (show.firstAirDate?.formattedDate() ?? "—", "calendar"),
                            ("\(show.voteCount)", "person.2.fill")
                        ])
                        .frame(maxWidth: .infinity)

                        if let overview = show.overview, !overview.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Описание")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                Text(overview)
                                    .font(.body)
                                    .foregroundStyle(.white.opacity(0.75))
                                    .lineSpacing(5)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 24)
                    .padding(.bottom, 60)
                }
            }
            .ignoresSafeArea(edges: .top)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                FavoriteButton(isFavorite: favorites.showIDs.contains(show.id)) {
                    favorites.toggle(show)
                }
            }
        }
    }
}
