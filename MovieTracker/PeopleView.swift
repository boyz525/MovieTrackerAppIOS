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

// MARK: - Person Card

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

// MARK: - Person Detail (push-экран)

struct PersonDetailView: View {
    let person: Person
    @Environment(FavoritesManager.self) private var favorites

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // Фото — полный экран, под навбар
                AsyncImage(url: person.profilePath.flatMap { $0.posterURL(size: "w780") }) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .aspectRatio(2/3, contentMode: .fit)
                }
                .frame(maxWidth: .infinity)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .frame(height: 110)
                        .mask {
                            LinearGradient(
                                colors: [.clear, .black],
                                startPoint: .top, endPoint: .bottom
                            )
                        }
                }

                VStack(alignment: .leading, spacing: 20) {
                    Text(person.name)
                        .font(.title2.bold())
                        .fixedSize(horizontal: false, vertical: true)

                    MetaPillsRow(items: [
                        (person.knownForDepartment ?? "Актёр", "theatermasks.fill"),
                        (String(format: "%.0f", person.popularity), "chart.line.uptrend.xyaxis")
                    ])

                    // Известен по
                    if let knownFor = person.knownFor, !knownFor.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Известен по").font(.headline)
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
                .padding(20)
                .padding(.bottom, 48)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationTitle(person.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                FavoriteButton(isFavorite: favorites.personIDs.contains(person.id)) {
                    favorites.toggle(person)
                }
            }
        }
    }
}
