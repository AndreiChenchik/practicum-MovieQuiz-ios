//
//  MoviePosters.swift
//  MovieQuiz
//
//  Created by Andrei Chenchik on 18/8/22.
//

import Foundation

struct MoviePosters: Codable {
    let posters: [MoviePoster]
}

struct MoviePoster: Codable {
    let imageURL: URL

    private enum CodingKeys: String, CodingKey {
        case imageURL = "link"
    }
}
