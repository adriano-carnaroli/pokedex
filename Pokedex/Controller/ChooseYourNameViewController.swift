//
//  ChooseYourNameViewController.swift
//  Pokedex
//
//  Created by Adriano Carnaroli on 13/12/20.
//

import UIKit

enum EnumCharacter:String {
    case boy
    case girl
}

class ChooseYourNameViewController: UIViewController, UITextFieldDelegate {

    var character:EnumCharacter!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var imgCharacter: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imgCharacter.image = UIImage(named: character.rawValue)
    }

    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        txtName.resignFirstResponder()
        return true
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return !txtName.text!.isEmpty
    }
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let defaults = UserDefaults.standard
        defaults.set(character.rawValue, forKey: "keyCharacter")
        defaults.set(txtName.text!, forKey: "keyTrainerName")
    }

}
