//
//  FavoritesView.swift
//  MovieTracker
//

import SwiftUI

struct FavoritesView: View {
    @Environment(FavoritesManager.self) private var favorites

    var body: some View {
        NavigationStack {
            Group {
                if favorites.isEmpty {
                    emptyState
                } else {
                    favoritesList
                }
            }
            .navigationTitle("Избранное")
            .navigationBarTitleDisplayMode(.large)
            // Навигация внутри вкладки Избранное
            .navigationDestination(for: Movie.self)  { MovieDetailView(movie: $0) }
            .navigationDestination(for: TVShow.self) { TVShowDetailView(show: $0) }
            .navigationDestination(for: Person.self) { PersonDetailView(person: $0) }
        }
    }


    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.slash")
                .font(.system(size: 56))
                .foregroundStyle(.tertiary)
            Text("Нет избранного")
                .font(.title3.weight(.semibold))
            Text("Нажмите ♥ на фильме, сериале или\nактёре, чтобы добавить")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }


    private var favoritesList: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 28) {
                if !favorites.movies.isEmpty {
                    FavSection(title: "Фильмы", icon: "film") {
                        horizontalMovies
                    }
                }
                if !favorites.shows.isEmpty {
                    FavSection(title: "Сериалы", icon: "tv") {
                        horizontalShows
                    }
                }
                if !favorites.people.isEmpty {
                    FavSection(title: "Актёры", icon: "person.2.fill") {
                        horizontalPeople
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 100)
        }
    }

    private var horizontalMovies: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(favorites.movies) { movie in
                    NavigationLink(value: movie) {
                        FavPosterCard(title: movie.title, posterPath: movie.posterPath)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var horizontalShows: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(favorites.shows) { show in
                    NavigationLink(value: show) {
                        FavPosterCard(title: show.name, posterPath: show.posterPath)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var horizontalPeople: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(favorites.people) { person in
                    NavigationLink(value: person) {
                        FavPersonCard(person: person)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}


private struct FavSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.headline)
                .padding(.leading, 4)
            content()
        }
    }
}

private struct FavPosterCard: View {
    let title: String
    let posterPath: String?

    var body: some View {
        VStack(spacing: 0) {
            AsyncImage(url: posterPath.flatMap { $0.posterURL() }) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle().fill(Color.gray.opacity(0.2))
            }
            .frame(width: 110, height: 160)
            .clipped()

            Text(title)
                .font(.caption2.weight(.medium))
                .foregroundStyle(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .padding(8)
                .frame(width: 110, height: 46, alignment: .top)
        }
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .glassEffect(in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct FavPersonCard: View {
    let person: Person

    var body: some View {
        VStack(spacing: 8) {
            AsyncImage(url: person.profilePath.flatMap { $0.posterURL() }) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle().fill(Color.gray.opacity(0.2))
            }
            .frame(width: 72, height: 72)
            .clipShape(Circle())

            Text(person.name)
                .font(.caption2.weight(.medium))
                .foregroundStyle(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: 80)
        }
        .padding(10)
        .glassEffect(in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
