//
//  PokemonCell.swift
//  Pokedex
//
//  Created by Adriano Carnaroli on 16/12/20.
//

import UIKit

class PokemonCell: UICollectionViewCell {
    static let cellPokemon = "cellPokemon"
    
    @IBOutlet weak var lblNumber: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgPokemon: UIImageView!
    @IBOutlet weak var imgCatched: UIImageView!
    @IBOutlet weak var imgSeen: UIImageView!

}
