//
//  StatisticsService.swift
//  MovieQuiz
//
//  Created by Andrei Chenchik on 12/8/22.
//

import Foundation

final class StatisticService: StatisticsStoring, StatisticsReporting {
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }


    private enum Keys: String {
        case totalAccuracy, bestGame, gamesCount
    }

    private(set) var totalAccuracy: Double {
        get { userDefaults.double(forKey: Keys.totalAccuracy.rawValue) }
        set { userDefaults.set(newValue, forKey: Keys.totalAccuracy.rawValue) }
    }

    private(set) var gamesCount: Int {
        get { userDefaults.integer(forKey: Keys.gamesCount.rawValue) }
        set { userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue) }
    }

    private(set) var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                let record = try? JSONDecoder().decode(
                    GameRecord.self, from: data
                ) else {
                return .init(correct: 0, total: 0, date: Date())
            }

            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                fatalError("Невозможно сохранить результат")
            }

            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }

    func store(correct count: Int, total amount: Int) {
        let gameRecord = bestGame
        let newGameRecord = GameRecord(
            correct: count, total: amount, date: Date()
        )

        totalAccuracy = (
            totalAccuracy * Double(gamesCount)
            + newGameRecord.score
        ) / Double(gamesCount + 1)

        gamesCount += 1

        if newGameRecord > gameRecord {
            bestGame = newGameRecord
        }
    }
}
