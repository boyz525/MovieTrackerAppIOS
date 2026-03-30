//
//  SearchView.swift
//  MovieTracker
//

import SwiftUI

// MARK: - Search View (используется внутри Tab(role: .search))

struct SearchView: View {
    @State private var viewModel = SearchViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.query.isEmpty {
                    emptyPrompt
                } else if viewModel.isLoading {
                    LoadingOverlay()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.results.isEmpty {
                    noResults
                } else {
                    resultsList
                }
            }
            .navigationTitle("Поиск")
            .navigationBarTitleDisplayMode(.large)
            // navigationDestination объявляется здесь — внутри NavigationStack
            .navigationDestination(for: SearchResult.self) { result in
                SearchResultDetailView(result: result)
            }
        }
        // .searchable на NavigationStack — iOS автоматически активирует поле
        // когда Tab(role: .search) нажат
        .searchable(
            text: $viewModel.query,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Фильмы, сериалы, актёры..."
        )
        .onChange(of: viewModel.query) { _, _ in viewModel.search() }
    }

    // MARK: - States

    private var emptyPrompt: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 52))
                .foregroundStyle(.tertiary)
            Text("Начните вводить запрос")
                .font(.title3)
                .foregroundStyle(.secondary)
            Text("Поиск по фильмам, сериалам и актёрам")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private var noResults: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.magnifyingglass")
                .font(.system(size: 52))
                .foregroundStyle(.tertiary)
            Text("Ничего не найдено")
                .font(.title3)
                .foregroundStyle(.secondary)
            Text("Попробуйте другой запрос")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private var resultsList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 8) {
                ForEach(viewModel.results) { result in
                    // NavigationLink делает каждый результат кликабельным
                    NavigationLink(value: result) {
                        SearchResultRow(result: result)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .padding(.bottom, 32)
        }
    }
}

// MARK: - Result Row

struct SearchResultRow: View {
    let result: SearchResult

    private var typeLabel: String {
        switch result.mediaType {
        case "movie":  return "Фильм"
        case "tv":     return "Сериал"
        case "person": return "Актёр"
        default:       return "Медиа"
        }
    }

    private var typeIcon: String {
        switch result.mediaType {
        case "movie":  return "film"
        case "tv":     return "tv"
        case "person": return "person.fill"
        default:       return "questionmark"
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            // Постер / фото
            AsyncImage(url: result.imagePath.flatMap { $0.posterURL() }) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .overlay {
                        Image(systemName: typeIcon)
                            .foregroundStyle(.tertiary)
                    }
            }
            .frame(width: 58, height: 84)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            // Текст
            VStack(alignment: .leading, spacing: 6) {
                Text(result.displayTitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                HStack(spacing: 6) {
                    Label(typeLabel, systemImage: typeIcon)
                        .font(.caption2.weight(.medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .glassEffect(in: Capsule())
                        .foregroundStyle(.secondary)

                    if !result.displayYear.isEmpty {
                        Text(result.displayYear)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }

                if let rating = result.voteAverage, rating > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(.yellow)
                        Text(String(format: "%.1f", rating))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// MARK: - Search Result Detail View (iOS 26 / Apple Music style)

struct SearchResultDetailView: View {
    let result: SearchResult
    @Environment(FavoritesManager.self) private var favorites

    private var heroURL: URL? {
        result.imagePath?.posterURL(size: "w780")
    }

    private var formattedDate: String {
        (result.releaseDate ?? result.firstAirDate ?? "").formattedDate()
    }

    var body: some View {
        ZStack {
            DetailBlurBackground(url: heroURL)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    DetailReflection(url: heroURL)

                    DetailPosterCard(url: heroURL)
                        .padding(.top, -50)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 8)

                    DetailBlurTransition()

                    VStack(spacing: 20) {
                        Text(result.displayTitle)
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)

                        HStack(spacing: 10) {
                            if let rating = result.voteAverage, rating > 0 {
                                Label(String(format: "%.1f", rating), systemImage: "star.fill")
                                    .padding(.horizontal, 14).padding(.vertical, 8)
                                    .glassEffect(in: Capsule())
                            }
                            if !formattedDate.isEmpty {
                                Label(formattedDate, systemImage: "calendar")
                                    .padding(.horizontal, 14).padding(.vertical, 8)
                                    .glassEffect(in: Capsule())
                            }
                        }
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.85))
                        .frame(maxWidth: .infinity)

                        if let overview = result.overview, !overview.isEmpty {
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
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 60)
                }
            }
            .ignoresSafeArea(edges: .top)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}
