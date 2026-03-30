//
//  PeopleView.swift
//  MovieTracker
//

import SwiftUI

// MARK: - People List

struct PeopleListView: View {
    @State private var viewModel = PeopleViewModel()
    @Environment(FavoritesManager.self) private var favorites

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            ZStack(alignment: .center) {
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.people) { person in
                            NavigationLink(value: person) {
                                PersonCard(person: person, favorites: favorites)
                            }
                            .buttonStyle(.plain)
                            .onAppear {
                                if person.id == viewModel.people.last?.id {
                                    Task { await viewModel.loadMore() }
                                }
                            }
                        }
                        if viewModel.isLoadingMore {
                            LoadMoreSpinner().gridCellColumns(3)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 100)
                }

                if viewModel.isLoading         { LoadingOverlay() }
                else if let e = viewModel.errorMessage { ErrorOverlay(message: e) }
            }
            .navigationTitle("Актёры")
            .navigationBarTitleDisplayMode(.large)
            .task { await viewModel.load() }
            .navigationDestination(for: Person.self) { person in
                PersonDetailView(person: person)
            }
        }
    }
}


struct PersonCard: View {
    let person: Person
    let favorites: FavoritesManager

    var body: some View {
        VStack(spacing: 8) {
            AsyncImage(url: person.profilePath.flatMap { $0.posterURL() }) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .overlay { Image(systemName: "person.fill").foregroundStyle(.tertiary) }
            }
            .frame(width: 80, height: 80)
            .clipShape(Circle())

            Text(person.name)
                .font(.caption.weight(.medium))
                .foregroundStyle(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.center)

            if let dept = person.knownForDepartment {
                Text(dept)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .glassEffect(in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(alignment: .topTrailing) {
            FavoriteButton(isFavorite: favorites.personIDs.contains(person.id)) {
                favorites.toggle(person)
            }
            .padding(4)
        }
    }
}


struct PersonDetailView: View {
    let person: Person
    @Environment(FavoritesManager.self) private var favorites

    private var photoURL: URL? {
        person.profilePath?.posterURL(size: "w780")
    }

    var body: some View {
        ZStack {
            DetailBlurBackground(url: photoURL)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    DetailReflection(url: photoURL)

                    DetailPosterCard(url: photoURL)
                        .padding(.top, -50)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 8)

                    DetailBlurTransition()

                    VStack(spacing: 20) {
                        Text(person.name)
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)

                        MetaPillsRow(items: [
                            (person.knownForDepartment ?? "Актёр", "theatermasks.fill"),
                            (String(format: "%.0f", person.popularity), "chart.line.uptrend.xyaxis")
                        ])
                        .frame(maxWidth: .infinity)

                        if let knownFor = person.knownFor, !knownFor.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Известен по")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(knownFor) { media in
                                            VStack(spacing: 6) {
                                                AsyncImage(url: media.posterPath.flatMap { $0.posterURL() }) { img in
                                                    img.resizable().aspectRatio(contentMode: .fill)
                                                } placeholder: {
                                                    Rectangle().fill(Color.gray.opacity(0.2))
                                                }
                                                .frame(width: 80, height: 120)
                                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                                                Text(media.displayTitle)
                                                    .font(.caption2)
                                                    .foregroundStyle(.white.opacity(0.75))
                                                    .lineLimit(2)
                                                    .multilineTextAlignment(.center)
                                                    .frame(width: 80)
                                            }
                                        }
                                    }
                                }
                            }
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
                FavoriteButton(isFavorite: favorites.personIDs.contains(person.id)) {
                    favorites.toggle(person)
                }
            }
        }
    }
}
