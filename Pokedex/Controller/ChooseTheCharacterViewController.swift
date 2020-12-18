//
//  ChooseTheCharacterViewController.swift
//  Pokedex
//
//  Created by Adriano Carnaroli on 13/12/20.
//

import UIKit

class ChooseTheCharacterViewController: UIViewController {

    private let segueBoy = "segueBoy"
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? ChooseYourNameViewController {
            controller.character = segue.identifier == segueBoy ? .boy : .girl
        }
    }

}
