import UIKit

extension Data {
    enum MockImages: String, CaseIterable {
        case godfather = "The Godfather"
        case darkKnight = "The Dark Knight"
        case killBill = "Kill Bill"
        case avengers = "The Avengers"
        case deadpool = "Deadpool"
        case greenKnight = "The Green Knight"
        case old = "Old"
        case iceAge = "The Ice Age Adventures of Buck Wild"
        case tesla = "Tesla"
        case vivarium = "Vivarium"
    }

    static func mockData(_ mockImage: MockImages) -> Data {
        UIImage(named: mockImage.rawValue)?.pngData() ?? Data()
    }
}
