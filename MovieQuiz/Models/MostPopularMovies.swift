import Foundation

struct MostPopularMovies: Codable {
    let errorMessage: String
    let items: [MostPopularMovie]
}

struct MostPopularMovie: Codable {
    let id: String
    let title: String
    let rating: Float
    let imageURL: URL

    private enum CodingKeys: String, CodingKey {
        case id
        case title = "fullTitle"
        case rating = "imDbRating"
        case imageURL = "image"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        imageURL = try container.decode(URL.self, forKey: .imageURL)

        var ratingString = try container.decode(String.self, forKey: .rating)
        ratingString = ratingString.isEmpty ? "0" : ratingString

        if let ratingValue = Float(ratingString) {
            rating = ratingValue
        } else {
            throw DecodingError.typeMismatch(
                MostPopularMovie.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Can't convert rating to Float")
            )
        }
    }
}
