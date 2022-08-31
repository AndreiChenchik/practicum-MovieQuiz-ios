import Foundation

struct IMDBApiResponse: Codable {
    let error: String

    private enum CodingKeys: String, CodingKey {
        case error = "errorMessage"
    }
}
