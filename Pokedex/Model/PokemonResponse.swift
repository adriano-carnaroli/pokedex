//
//  PokemonResponse.swift
//  Pokedex
//
//  Created by Adriano Carnaroli on 16/12/20.
//

import UIKit

struct PokemonResponse:Codable {
    let results: [Pokemon]
}

// MARK: - Result
struct Pokemon:Codable {
    let name: String
    let url: String
    var image:Data?
    var number:Int?
    var types:String?
    var isCatched:Bool?
    var isSeen:Bool?
    
    init() {
        self.name = ""
        self.url = ""
        self.image = nil
        self.number = nil
        self.types = ""
        self.isCatched = false
        self.isSeen = false
    }
    
    //MARK: CoreData Object
    func saveObject(){
        do {
            let object = self.getPokemon(number: self.number ?? 0)
            if object != nil {
                try removeObject(number: object!.number!)
            }
            try  CoreDataPersistenceManager().saveObject(object: self)
        } catch {
            print(error)
        }
    }
    
    func getAllPokemons()->[Pokemon]{
        let objects = CoreDataPersistenceManager().getAllObject(object:Pokemon.self)
        let sortedUsers = objects!.sorted {
            $0.number! < $1.number!
        }
        return sortedUsers
    }

    func removeObject(number:Int) throws {
        try CoreDataPersistenceManager().removeObject(fieldID: "number", valueID: number, object: Pokemon.self)
    }
    
    func getPokemon(number:Int)->Pokemon? {
        let objects = CoreDataPersistenceManager().getObject(fieldValues:["number":number], object: Pokemon.self)
        
        return objects.count > 0 ? objects.first : nil
    }
}
