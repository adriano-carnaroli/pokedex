//
//  PokemonDetails.swift
//  Pokedex
//
//  Created by Adriano Carnaroli on 17/12/20.
//

import UIKit

struct PokemonDetails: Codable {
    let sprites:Sprites
    let types:[Type]
}

struct Type:Codable {
    let type:PokeType
}

struct PokeType:Codable {
    let name:String
}

struct Sprites: Codable {
    let other: Other?
}

struct Other: Codable {
    let officialArtwork: OfficialArtwork
    enum CodingKeys: String, CodingKey {
        case officialArtwork = "official-artwork"
    }
}

struct OfficialArtwork: Codable {
    let frontDefault: String
    enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
    }
}

extension String {
    var html2AttributedString: NSAttributedString? {
        guard
            let data = data(using: .utf8)
            else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }

    static func htmlFontProject(_ string:String, hexColor:String) -> String {
        return String(format:"<span style=\"font-family: '%@'; color:%@; font-size: 13px; \">%@</span>", "Helvetica", hexColor, string)
    }
}

enum TypeEnum:String {
    case grass
    case fire
    case poison
    case flying
    case water
    case bug
    case normal
    case electric
    case ground
    case fairy
    case fighting
    case psychic
    case rock
    case steel
    case ice
    case ghost
    case dragon
    
    func getName() -> String {
        switch self {
        case .grass:
            return "grama"
        case .poison:
            return "venenoso"
        case .fire:
            return "fogo"
        case .flying:
            return "voador"
        case .water:
            return "aquático"
        case .bug:
            return "inseto"
        case .normal:
            return "normal"
        case .electric:
            return "elétrico"
        case .ground:
            return "terrestre"
        case .fairy:
            return "fada"
        case .fighting:
            return "lutador"
        case .psychic:
            return "psíquico"
        case .rock:
            return "pedra"
        case .steel:
            return "aço"
        case .ice:
            return "gelo"
        case .ghost:
            return "fantasma"
        case .dragon:
            return "dragão"
        }
    }
}
