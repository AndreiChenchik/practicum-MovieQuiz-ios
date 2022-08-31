import XCTest
@testable import MovieQuiz

final class DataTests: XCTestCase {
    func testAllMockAssets() throws {
        // Given
        let mockImages = Data.MockImages.allCases
        let emptyData = Data()

        // When
        for mockImage in mockImages {
            let imageData = Data.mockData(mockImage)

            // Then
            XCTAssertNotEqual(imageData, emptyData)
        }
    }
}
