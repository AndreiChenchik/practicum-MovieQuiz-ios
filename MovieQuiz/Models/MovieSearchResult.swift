//
//  MovieSearchResult.swift
//  MovieQuiz
//
//  Created by Andrei Chenchik on 18/8/22.
//

import Foundation

struct MovieSearchResult: Codable {
    let movies: [MovieInfo]

    private enum CodingKeys: String, CodingKey {
        case movies = "movie_results"
    }
}

struct MovieInfo: Codable {
    let posterPath: String

    private enum CodingKeys: String, CodingKey {
        case posterPath = "poster_path"
    }
}
