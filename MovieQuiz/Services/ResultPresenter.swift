//
//  ResultPresenter.swift
//  MovieQuiz
//
//  Created by Andrei Chenchik on 11/8/22.
//

import Foundation
import UIKit

class ResultPresenter: ResultPresenterProtocol {
    func displayResults(
        _ model: QuizResultViewModel,
        over viewController: UIViewController,
        completion: @escaping () -> Void
    ) {
        let alert = ResultAlertController(
            title: model.title,
            message: model.text,
            preferredStyle: .alert
        )

        let dimViewController = DimViewController(dimmedViewController: alert)

        let action = UIAlertAction(
            title: model.buttonText,
            style: .default
        ) { _ in
            dimViewController.dismiss(animated: false)
            completion()
        }

        alert.addAction(action)
        alert.delegate = dimViewController

        dimViewController.modalPresentationStyle = .overFullScreen
        viewController.present(dimViewController, animated: false)
    }
}
