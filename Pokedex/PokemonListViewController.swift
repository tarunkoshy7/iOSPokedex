//
//  PokemonListViewController.swift
//  Pokedex
//
//  Created by Tarun Koshy on 05/08/2020.
//  Copyright © 2020 CS50. All rights reserved.
//

import UIKit

class PokemonListViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet var searchBar: UISearchBar!
    
    var pokemon: [PokemonListResult] = []
    var search: Bool = false
    var searchResults: [PokemonListResult] = []
    
    func capitalize(text: String) -> String {
        return text.prefix(1).uppercased() + text.dropFirst()
    }
    
    override func viewDidLoad() {
        // function that gets called when the screed loads up
        super.viewDidLoad()
        
        searchBar.delegate = self
        self.tableView.keyboardDismissMode = .onDrag
        
        // making sure our url field isn't nil (telling compiler to continue only if url is assigned)
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=964") else {
            return
        }
        
        // downloading the data from the URL
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                return
            }
            
            do {
                // Decode JSON file to swift list and assign to pokemon variable defined above
                // self is there because we are in a closure (defined in URLSession line above)
                let entries = try JSONDecoder().decode(PokemonListResults.self, from: data)
                self.pokemon = entries.results
                
                // moves the table reloading to the foreground instead of the background
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            catch let error {
                print(error)
            }
        }.resume()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // defines sections, subsections, etc.
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if search == false {
            // returns number of rows in table
            return pokemon.count
        }
        else {
            return searchResults.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PokemonCell", for: indexPath)
        // function to fill in the actual data to be represented in the cells in this view
        
        // lets you access the pool of cells that iOS pulls when they are being viewed on the screen
        if search == false {
            cell.textLabel?.text = capitalize(text: pokemon[indexPath.row].name)
        }
        else {
            cell.textLabel?.text = capitalize(text: searchResults[indexPath.row].name)
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // controls the segue from each table cell to the PokemonViewController data to be displayed
        
        // if segue.destination can be casted to a PokemonViewController type, then enter branch
        if segue.identifier == "ShowPokemonSegue",
                let destination = segue.destination as? PokemonViewController,
                let index = tableView.indexPathForSelectedRow?.row {
            if search == false{
                destination.url = pokemon[index].url
            }
            else {
                destination.url = searchResults[index].url
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // gets called every time the text changes in search bar
        
        searchResults = []
        
        if searchText.isEmpty {
            search = false
        }
        else {
            search = true
        }
        
        for mon in pokemon {
            if mon.name.localizedCaseInsensitiveContains(searchText) {
                searchResults.append(mon)
            }
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // makes the keyboard go away after search button pressed
        
        self.searchBar.endEditing(true)
    }
}
