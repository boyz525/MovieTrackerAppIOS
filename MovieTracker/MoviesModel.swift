//
//  MoviesModel.swift
//  TestPlayground
//
//  Created by Александр Малахов on 30.03.2026.
//

import Foundation


struct Movie: Codable, Identifiable {

    let id: Int
    let title: String
    let overview: String?
    let voteAverage: Double
    let posterPath: String?
    let backdropPath: String?
    let voteCount: Int
    let releaseDate: String

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case voteAverage = "vote_average"
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case voteCount = "vote_count"
        case releaseDate = "release_date"
    }
}


struct MoviesResponse: Codable {
    let page: Int
    let results: [Movie]
}
