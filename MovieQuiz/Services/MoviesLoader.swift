import Foundation

struct MoviesLoader: MoviesLoading {
    private let networkClient: NetworkRouting

    init(networkClient: NetworkRouting) {
        self.networkClient = networkClient
    }

    func loadMovies(
        handler: @escaping (Result<MostPopularMovies, Error>) -> Void
    ) {
        networkClient.fetch(url: .apiURL(.mostPopularMovies)) { result in
            switch result {
            case .success(let data):
                do {
                    let apiResponse = try JSONDecoder().decode(
                        IMDBApiResponse.self, from: data
                    )

                    if !apiResponse.error.isEmpty {
                        throw ApiError.genericError(message: apiResponse.error)
                    }

                    let mostPopularMovies = try JSONDecoder().decode(
                        MostPopularMovies.self, from: data
                    )

                    handler(.success(mostPopularMovies))
                } catch {
                    handler(.failure(error))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}
