//
//  PokemonDetailViewController.swift
//  Pokedex
//
//  Created by Adriano Carnaroli on 13/12/20.
//

import UIKit

class PokemonDetailViewController: UIViewController {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblNumber: UILabel!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var imgPhoto: UIImageView!
    @IBOutlet weak var swtSeen: UISwitch!
    @IBOutlet weak var swtCatched: UISwitch!
    @IBOutlet weak var imgCatched: UIImageView!
    @IBOutlet weak var imgSeen: UIImageView!
    
    var pokemon:Pokemon!

    override func viewDidLoad() {
        super.viewDidLoad()
        lblName.text = pokemon.name
        lblNumber.text = "#\(pokemon.number!)"
        let types = pokemon.types!.split(separator: ",")
        var typesConcat = ""
        for type in types {
            typesConcat += "\((TypeEnum.init(rawValue: String(type))!.getName())), "
        }
        lblType.text = typesConcat.isEmpty ? "" : String(String(typesConcat.dropLast()).dropLast())
        imgPhoto.image = pokemon.image == nil ? nil : UIImage(data: pokemon.image!)
        swtSeen.isOn = pokemon.isSeen ?? false
        swtCatched.isOn = pokemon.isCatched ?? false
        imgSeen.image = UIImage(named: swtSeen.isOn ? "visto_b" : "visto_g")!
        imgCatched.image = UIImage(named: swtCatched.isOn ? "pokebola" : "pokebola_g")!
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func toogleSeen(_ sender: Any) {
        imgSeen.image = UIImage(named: swtSeen.isOn ? "visto_b" : "visto_g")!
        pokemon.isSeen = swtSeen.isOn
        pokemon.saveObject()
    }
    
    @IBAction func toogleCatched(_ sender: Any) {
        imgCatched.image = UIImage(named: swtCatched.isOn ? "pokebola" : "pokebola_g")!
        pokemon.isCatched = swtCatched.isOn
        pokemon.saveObject()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }

}
