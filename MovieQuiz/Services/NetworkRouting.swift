//
//  NetworkRouting.swift
//  MovieQuiz
//
//  Created by Andrei Chenchik on 31/8/22.
//

import Foundation

protocol NetworkRouting {
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void)
}
