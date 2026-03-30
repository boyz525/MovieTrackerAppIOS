//
//  MovieView.swift
//  TestPlayground
//
//  Created by Александр Малахов on 30.03.2026.
//

import SwiftUI

// MARK: - List View

struct MoviesListView: View {
    @State private var viewModel = MoviesViewModel()
    @State private var selectedMovie: Movie? = nil

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.movies) { movie in
                            MovieCard(movie: movie)
                                .onTapGesture { selectedMovie = movie }
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 100)
                }

                if viewModel.isLoading {
                    LoadingOverlay()
                } else if let error = viewModel.errorMessage {
                    ErrorOverlay(message: error)
                }
            }
            .navigationTitle("Кино")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        Task { await viewModel.loadMovies() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .glassEffect(in: .circle)
                }
            }
            .task {
                await viewModel.loadMovies()
            }
            .sheet(item: $selectedMovie) { movie in
                MovieDetailView(movie: movie)
            }
        }
    }
}

// MARK: - Overlays

private struct LoadingOverlay: View {
    var body: some View {
        ProgressView()
            .scaleEffect(1.5)
            .tint(.white)
            .frame(width: 72, height: 72)
            .glassEffect(in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .transition(.opacity.animation(.spring()))
    }
}

private struct ErrorOverlay: View {
    let message: String

    var body: some View {
        Text(message)
            .foregroundStyle(.primary)
            .multilineTextAlignment(.center)
            .padding(20)
            .glassEffect(in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .padding(.horizontal, 32)
            .transition(.opacity.animation(.spring()))
    }
}

// MARK: - Movie Card

struct MovieCard: View {
    let movie: Movie

    private var releaseYear: String {
        String(movie.releaseDate.prefix(4))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w500\(movie.posterPath ?? "")")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
            }
            .frame(height: 200)
            .clipped()

            VStack(alignment: .leading, spacing: 5) {
                Text(movie.title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                HStack(spacing: 5) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundStyle(.yellow)
                    Text(String(format: "%.1f", movie.voteAverage))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("·")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                    Text(releaseYear)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 10)
            .padding(.top, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 72, alignment: .top)
        }
        .frame(maxWidth: .infinity)
        // clipShape до glassEffect — иначе изображение вылазит за скруглённые углы
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .glassEffect(in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

// MARK: - Movie Detail View

struct MovieDetailView: View {
    let movie: Movie
    @Environment(\.dismiss) private var dismiss

    private var formattedDate: String {
        let parts = movie.releaseDate.split(separator: "-")
        guard parts.count == 3,
              let monthNum = Int(parts[1]),
              monthNum >= 1 && monthNum <= 12 else { return movie.releaseDate }
        let months = ["янв", "фев", "мар", "апр", "май", "июн",
                      "июл", "авг", "сен", "окт", "ноя", "дек"]
        return "\(parts[2]) \(months[monthNum - 1]) \(parts[0])"
    }

    private var heroURL: URL? {
        if let path = movie.backdropPath {
            return URL(string: "https://image.tmdb.org/t/p/w1280\(path)")
        }
        if let path = movie.posterPath {
            return URL(string: "https://image.tmdb.org/t/p/w780\(path)")
        }
        return nil
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {

                // Hero image + кнопка закрытия
                ZStack(alignment: .topTrailing) {
                    AsyncImage(url: heroURL) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.25))
                            .aspectRatio(2/3, contentMode: .fit)
                    }
                    .frame(maxWidth: .infinity)
                    // Блюр-переход: ultraThinMaterial маскированный градиентом снизу вверх
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .frame(height: 110)
                            .mask {
                                LinearGradient(
                                    colors: [.clear, .black],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            }
                    }

                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.primary)
                            .frame(width: 36, height: 36)
                    }
                    .glassEffect(in: .circle)
                    .padding(16)
                }

                // Контент
                VStack(alignment: .leading, spacing: 20) {
                    Text(movie.title)
                        .font(.title2.bold())
                        .fixedSize(horizontal: false, vertical: true)

                    // Glass-таблетки с метаданными
                    HStack(spacing: 10) {
                        Label(String(format: "%.1f", movie.voteAverage), systemImage: "star.fill")
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .glassEffect(in: Capsule())

                        Label(formattedDate, systemImage: "calendar")
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .glassEffect(in: Capsule())

                        Label("\(movie.voteCount)", systemImage: "person.2.fill")
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .glassEffect(in: Capsule())
                    }
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                    if let overview = movie.overview, !overview.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Описание")
                                .font(.headline)
                            Text(overview)
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .lineSpacing(5)
                        }
                    }
                }
                .padding(20)
                .padding(.bottom, 48)
            }
        }
        .presentationBackground(.thinMaterial)
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(36)
    }
}

#Preview {
    MoviesListView()
}
