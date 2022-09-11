import Foundation

struct ApiErrorResponse: Codable {
    let error: String

    private enum CodingKeys: String, CodingKey {
        case error = "errorMessage"
    }
}
