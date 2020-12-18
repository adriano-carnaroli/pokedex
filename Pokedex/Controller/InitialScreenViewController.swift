//
//  InitialScreenViewController.swift
//  Pokedex
//
//  Created by Adriano Carnaroli on 16/12/20.
//

import UIKit

class InitialScreenViewController: UIViewController {

    private let seguePokedex = "seguePokedex"
    private let seguePrimeiroAcesso = "seguePrimeiroAcesso"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func iniciar(_ sender: Any) {
        let defaults = UserDefaults.standard
        let character = defaults.string(forKey: "keyCharacter")
        let isFirstAccess = character == nil
        self.performSegue(withIdentifier: isFirstAccess ? seguePrimeiroAcesso : seguePokedex, sender: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }

}
