//
//  MostPopularMovies.swift
//  MovieQuiz
//
//  Created by Andrei Chenchik on 18/8/22.
//

import Foundation

struct MostPopularMovies: Codable {
    let errorMessage: String
    let items: [MostPopularMovie]
}

struct MostPopularMovie: Codable {
    let id: String
    let title: String
    let rating: String
    let imageURL: URL

    private enum CodingKeys: String, CodingKey {
        case id
        case title = "fullTitle"
        case rating = "imDbRating"
        case imageURL = "image"
    }
}
