//
//  SharedViews.swift
//  MovieTracker
//

import SwiftUI



struct FavoriteButton: View {
    let isFavorite: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(isFavorite ? .red : .white)
                .frame(width: 32, height: 32)
        }
        .glassEffect(in: .circle)
    }
}



struct SortMenuButton: View {
    let current: SortOption
    let onSelect: (SortOption) -> Void

    var body: some View {
        Menu {
            ForEach(SortOption.allCases) { option in
                Button {
                    if option != current { onSelect(option) }
                } label: {
                    if option == current {
                        Label(option.title, systemImage: "checkmark")
                    } else {
                        Label(option.title, systemImage: option.icon)
                    }
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
                .frame(width: 36, height: 36)
        }
        .glassEffect(in: .circle)
    }
}



struct LoadingOverlay: View {
    var body: some View {
        ProgressView()
            .scaleEffect(1.4)
            .frame(width: 64, height: 64)
            .glassEffect(in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct ErrorOverlay: View {
    let message: String

    var body: some View {
        Text(message)
            .foregroundStyle(.primary)
            .multilineTextAlignment(.center)
            .padding(20)
            .glassEffect(in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .padding(.horizontal, 32)
    }
}



struct PosterImage: View {
    let path: String?
    let height: CGFloat

    var body: some View {
        Group {
            if let path, let url = path.posterURL() {
                AsyncImage(url: url) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    posterPlaceholder
                }
            } else {
                posterPlaceholder
            }
        }
        .frame(height: height)
        .clipped()
    }

    private var posterPlaceholder: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .overlay { Image(systemName: "photo").foregroundStyle(.tertiary) }
    }
}



struct MetaPillsRow: View {
    let items: [(String, String)]

    var body: some View {
        HStack(spacing: 10) {
            ForEach(items, id: \.0) { text, icon in
                Label(text, systemImage: icon)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .glassEffect(in: Capsule())
            }
        }
        .font(.caption.weight(.medium))
        .foregroundStyle(.white.opacity(0.85))
    }
}


struct LoadMoreSpinner: View {
    var body: some View {
        HStack {
            Spacer()
            ProgressView()
            Spacer()
        }
        .padding(.vertical, 16)
    }
}


struct DetailBlurBackground: View {
    let url: URL?

    var body: some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .blur(radius: 70)
                .scaleEffect(1.5) 
                .overlay(Color.black.opacity(0.42))
        } placeholder: {
            Color.black.opacity(0.8)
        }
    }
}


struct DetailReflection: View {
    let url: URL?

    var body: some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .scaleEffect(x: 1, y: -1, anchor: .center)
        } placeholder: {
            Color.clear
        }
        .frame(maxWidth: .infinity)
        .frame(height: 220)
        .clipped()
        .mask {
            LinearGradient(
                stops: [
                    .init(color: .black.opacity(0.55), location: 0),
                    .init(color: .black.opacity(0.15), location: 0.55),
                    .init(color: .clear, location: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}


struct DetailPosterCard: View {
    let url: URL?

    var body: some View {
        AsyncImage(url: url) { image in
            image.resizable().scaledToFit()
        } placeholder: {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.gray.opacity(0.35))
                .aspectRatio(2/3, contentMode: .fit)
        }
        .frame(maxWidth: 300)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.65), radius: 36, x: 0, y: 18)
    }
}


struct DetailBlurTransition: View {
    var body: some View {
        Rectangle()
            .fill(.ultraThinMaterial)
            .frame(height: 80)
            .mask {
                LinearGradient(
                    colors: [.clear, .black],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
    }
}
