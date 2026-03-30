//
//  MoviesModel.swift
//  MovieTracker
//

import Foundation


enum SortOption: String, CaseIterable, Identifiable {
    case popular, topRated, latest

    var id: String { rawValue }

    var title: String {
        switch self {
        case .popular:  return "Популярные"
        case .topRated: return "Топ рейтинг"
        case .latest:   return "Новинки"
        }
    }

    var icon: String {
        switch self {
        case .popular:  return "flame.fill"
        case .topRated: return "star.fill"
        case .latest:   return "sparkles"
        }
    }

    var movieEndpoint: String {
        switch self {
        case .popular:  return "/movie/popular"
        case .topRated: return "/movie/top_rated"
        case .latest:   return "/movie/now_playing"
        }
    }

    var tvEndpoint: String {
        switch self {
        case .popular:  return "/tv/popular"
        case .topRated: return "/tv/top_rated"
        case .latest:   return "/tv/on_the_air"
        }
    }
}


struct Movie: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let overview: String?
    let voteAverage: Double
    let posterPath: String?
    let backdropPath: String?
    let voteCount: Int
    let releaseDate: String

    enum CodingKeys: String, CodingKey {
        case id, title, overview
        case voteAverage  = "vote_average"
        case posterPath   = "poster_path"
        case backdropPath = "backdrop_path"
        case voteCount    = "vote_count"
        case releaseDate  = "release_date"
    }
}

struct MoviesResponse: Codable {
    let page: Int
    let results: [Movie]
    let totalPages: Int

    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
    }
}


struct TVShow: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let overview: String?
    let voteAverage: Double
    let posterPath: String?
    let backdropPath: String?
    let voteCount: Int
    let firstAirDate: String?

    enum CodingKeys: String, CodingKey {
        case id, name, overview
        case voteAverage  = "vote_average"
        case posterPath   = "poster_path"
        case backdropPath = "backdrop_path"
        case voteCount    = "vote_count"
        case firstAirDate = "first_air_date"
    }
}

struct TVShowsResponse: Codable {
    let page: Int
    let results: [TVShow]
    let totalPages: Int

    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
    }
}


struct Person: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let profilePath: String?
    let knownForDepartment: String?
    let popularity: Double
    let knownFor: [KnownForMedia]?

    enum CodingKeys: String, CodingKey {
        case id, name, popularity
        case profilePath        = "profile_path"
        case knownForDepartment = "known_for_department"
        case knownFor           = "known_for"
    }
}

struct KnownForMedia: Codable, Identifiable, Hashable {
    let id: Int
    let title: String?
    let name: String?
    let mediaType: String?
    let posterPath: String?

    var displayTitle: String { title ?? name ?? "" }

    enum CodingKeys: String, CodingKey {
        case id, title, name
        case mediaType  = "media_type"
        case posterPath = "poster_path"
    }
}

struct PeopleResponse: Codable {
    let page: Int
    let results: [Person]
    let totalPages: Int

    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
    }
}


struct SearchResult: Codable, Identifiable, Hashable {
    let id: Int
    let mediaType: String?
    let title: String?
    let name: String?
    let overview: String?
    let posterPath: String?
    let profilePath: String?
    let voteAverage: Double?
    let releaseDate: String?
    let firstAirDate: String?

    var displayTitle: String  { title ?? name ?? "" }
    var imagePath: String?    { posterPath ?? profilePath }
    var displayYear: String   { String((releaseDate ?? firstAirDate ?? "").prefix(4)) }

    enum CodingKeys: String, CodingKey {
        case id, title, name, overview
        case mediaType   = "media_type"
        case posterPath  = "poster_path"
        case profilePath = "profile_path"
        case voteAverage = "vote_average"
        case releaseDate = "release_date"
        case firstAirDate = "first_air_date"
    }
}

struct SearchResponse: Codable {
    let page: Int
    let results: [SearchResult]
    let totalPages: Int

    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
    }
}


extension String {
    func posterURL(size: String = "w500") -> URL? {
        URL(string: "https://image.tmdb.org/t/p/\(size)\(self)")
    }

    var releaseYear: String { String(prefix(4)) }

    func formattedDate() -> String {
        let parts = split(separator: "-")
        guard parts.count == 3,
              let m = Int(parts[1]), m >= 1, m <= 12 else { return self }
        let months = ["янв","фев","мар","апр","май","июн",
                      "июл","авг","сен","окт","ноя","дек"]
        return "\(parts[2]) \(months[m - 1]) \(parts[0])"
    }
}
