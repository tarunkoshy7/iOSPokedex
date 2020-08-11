//
//  Pokemon.swift
//  Pokedex
//
//  Created by Tarun Koshy on 05/08/2020.
//  Copyright © 2020 CS50. All rights reserved.
//

import Foundation

struct PokemonListResults: Codable {
    let results: [PokemonListResult]
}

struct PokemonListResult: Codable {
    let name: String
    let url: String
}

struct PokemonResult: Codable {
    let id: Int
    let name: String
    let types: [PokemonTypeEntry]
    let sprites: PokemonSprite
}

struct PokemonTypeEntry: Codable {
    let slot: Int
    let type: PokemonType
}

struct PokemonType: Codable {
    let name: String
}

struct PokemonSprite: Codable {
    let front_default: String
}

struct PokemonDescriptionList: Codable {
    let flavor_text_entries: [PokemonDescription]
}

struct PokemonDescription: Codable {
    let flavor_text: String
    let language: Language
}

struct Language: Codable {
    let name: String
}

var caughtPokemon: [Int] = []
