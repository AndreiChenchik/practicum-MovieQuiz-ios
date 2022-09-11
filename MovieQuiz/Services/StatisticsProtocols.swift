import Foundation

protocol StatisticsReporting {
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
}

protocol StatisticsStoring {
    func store(correct count: Int, total amount: Int, date: Date)
}
