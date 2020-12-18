//
//  PokedexViewController.swift
//  Pokedex
//
//  Created by Adriano Carnaroli on 13/12/20.
//

import UIKit

class PokedexViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imgCharacter: UIImageView!
    @IBOutlet weak var lblTrainerName: UILabel!
    private var listPokemon:[Pokemon] = []
    private let segueDetail = "segueDetail"
    private let urlApiPokemons = "https://pokeapi.co/api/v2/pokemon?limit=151&offset=0"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = UserDefaults.standard
        let character = defaults.string(forKey: "keyCharacter")
        let name = defaults.string(forKey: "keyTrainerName")
        lblTrainerName.text = name!.uppercased()
        imgCharacter.image = UIImage(named: character!)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let pokemons = Pokemon().getAllPokemons()
        if pokemons.isEmpty {
            let alert = UIAlertController(title: nil, message: "", preferredStyle: .alert)
            
            let jeremyGif = UIImage.gifImageWithName("loading")
            let imageView = UIImageView(image: jeremyGif)
            imageView.frame = CGRect(x: -40, y: -(self.view.frame.size.width - 80) / 2, width: self.view.frame.size.width - 26, height: self.view.frame.size.width - 80)
            alert.view.addSubview(imageView)
            present(alert, animated: true, completion: nil)
            getFromWeb()
        } else {
            listPokemon = pokemons
            collectionView.reloadData()
        }
    }
    
    func getFromWeb() {
        let url : String = urlApiPokemons
        URLSession.shared.dataTask(with: URL(string: url)!) { data, response, error in
            if error == nil {
                let decoder = JSONDecoder()
                if let json = try? decoder.decode(PokemonResponse.self, from: data!) {
                    self.listPokemon = json.results
                    self.getImage(index:0)
                }
            } else {
                print("Erro ao recuperar informações da API.")
            }
        }.resume()
    }
    
    func getImage(index:Int) {
        URLSession.shared.dataTask(with: URL(string: listPokemon[index].url)!) { data, response, error in
            if error == nil {
                let decoder = JSONDecoder()
                if let json = try? decoder.decode(PokemonDetails.self, from: data!) {
                    let url = URL(string: json.sprites.other!.officialArtwork.frontDefault)
                    let data = try? Data(contentsOf: url!)
                    self.listPokemon[index].image = data
                    var typeString = ""
                    for type in json.types {
                        typeString += "\(type.type.name),"
                    }
                    typeString = typeString.isEmpty ? "" : String(typeString.dropLast())
                    self.listPokemon[index].types = typeString
                    self.listPokemon[index].number = index + 1
                    self.listPokemon[index].isCatched = false
                    self.listPokemon[index].isSeen = false
                    self.listPokemon[index].saveObject()
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                    if index < self.listPokemon.count - 1 {
                        self.getImage(index: index+1)
                    } else {
                        DispatchQueue.main.async {
                            self.dismiss(animated: false, completion: nil)
                        }
                    }
                }
            } else {
                print("Erro ao recuperar informações da API.")
            }
        }.resume()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listPokemon.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PokemonCell.cellPokemon, for: indexPath) as? PokemonCell else { return UICollectionViewCell() }
        let item = listPokemon[indexPath.row]
        cell.lblName.text = item.name
        cell.lblNumber.text = "#\(item.number ?? indexPath.row + 1)"
        cell.imgPokemon.image = item.image == nil ? nil : UIImage(data: item.image!)
        cell.imgCatched.image = UIImage(named: item.isCatched ?? false ? "pokebola" : "pokebola_g")!
        cell.imgSeen.image = UIImage(named: item.isSeen ?? false ? "visto_b" : "visto_g")!
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.bounds.size.width / 2 - 8
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: segueDetail, sender: listPokemon[indexPath.row])
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? PokemonDetailViewController {
            controller.pokemon = sender as? Pokemon
        }
    }

}
