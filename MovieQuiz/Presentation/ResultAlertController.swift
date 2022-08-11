//
//  ResultAlertController.swift
//  MovieQuiz
//
//  Created by Andrei Chenchik on 11/8/22.
//

import UIKit


class ResultAlertController: UIAlertController {
    weak var delegate: DimmedViewControllerDelegate?

    override func viewWillDisappear(_ animated: Bool) {
        delegate?.dimmedViewWillDisappear()
        super.viewWillDisappear(animated)
    }
}
