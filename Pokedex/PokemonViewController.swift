//
//  PokemonViewController.swift
//  Pokedex
//
//  Created by Tarun Koshy on 05/08/2020.
//  Copyright © 2020 CS50. All rights reserved.
//

import UIKit

class PokemonViewController: UIViewController {
    var url: String!
    var num: Int!
    let caughtMemory = UserDefaults.standard.object(forKey: "CaughtPokemon") as? [Int] ?? []

    // Linking these outlets to the fields in the storyboard
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var numberLabel: UILabel!
    @IBOutlet var type1Label: UILabel!
    @IBOutlet var type2Label: UILabel!
    @IBOutlet var catchButton: UIButton!
    @IBOutlet var spriteImage: UIImageView!
    @IBOutlet var descriptionLabel: UITextView!

    func capitalize(text: String) -> String {
        return text.prefix(1).uppercased() + text.dropFirst()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // resetting all placeholder values so that they dont display if a value passed from API is null/empty
        nameLabel.text = ""
        numberLabel.text = ""
        type1Label.text = ""
        type2Label.text = ""
        catchButton.setTitle("", for: .normal)
        spriteImage.image = nil
        descriptionLabel.text = ""
        
        loadPokemon()
    }

    func loadPokemon() {
        URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
            guard let data = data else {
                return
            }

            do {
                let result = try JSONDecoder().decode(PokemonResult.self, from: data)
                DispatchQueue.main.async {
                    self.navigationItem.title = self.capitalize(text: result.name)
                    self.nameLabel.text = self.capitalize(text: result.name)
                    self.numberLabel.text = String(format: "#%03d", result.id)
                    self.num = result.id
                    
                    let spriteURL = URL(string: result.sprites.front_default)!
                    let spriteData = try? Data(contentsOf: spriteURL)

                    if let imageData = spriteData {
                        self.spriteImage.image = UIImage(data: imageData)
                    }
                    
                    caughtPokemon = self.caughtMemory
                    
                    if caughtPokemon.contains(result.id) {
                        self.catchButton.setTitle("Release", for: .normal)
                    }
                    else {
                        self.catchButton.setTitle("Catch", for: .normal)
                    }

                    for typeEntry in result.types {
                        if typeEntry.slot == 1 {
                            self.type1Label.text = typeEntry.type.name
                        }
                        else if typeEntry.slot == 2 {
                            self.type2Label.text = typeEntry.type.name
                        }
                    }
                }
                
                guard let url2 = URL(string: "https://pokeapi.co/api/v2/pokemon-species/" + String(result.id)) else {
                    return
                }
                
                URLSession.shared.dataTask(with: url2) { (data, response, error) in
                    guard let data = data else {
                        return
                    }

                    do {
                        let result = try JSONDecoder().decode(PokemonDescriptionList.self, from: data)
                        DispatchQueue.main.async {
                            for entry in result.flavor_text_entries {
                                if entry.language.name == "en" {
                                    self.descriptionLabel.text = entry.flavor_text
                                    break
                                }
                            }
                        }
                    }
                    catch let error {
                        print(error)
                    }
                }.resume()
            }
            catch let error {
                print(error)
            }
        }.resume()
    }
    
    @IBAction func toggleCatch() {
        // toggles whether a pokemon has been caught or not and saves to UserDefaults so state can be saved when app is closed
        
        if caughtPokemon.contains(self.num) {
            catchButton.setTitle("Catch", for: .normal)
            if let index = caughtPokemon.firstIndex(of: self.num) {
                caughtPokemon.remove(at: index)
            }
        }
        else {
            catchButton.setTitle("Release", for: .normal)
            caughtPokemon.append(self.num)
        }
        
        UserDefaults.standard.set(caughtPokemon, forKey: "CaughtPokemon")
    }
}
