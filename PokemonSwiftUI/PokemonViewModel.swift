//
//  PokemonViewModel.swift
//  PokemonSwiftUI
//
//  Created by David McDermott on 9/11/23.
//

import Foundation

@MainActor
class PokemonViewModel: ObservableObject {
    enum Status {
        case notStarted
        case fetching
        case success
        case failed(error: Error)
    }
    
    @Published private(set) var status = Status.notStarted
    
    private let controller: FetchController
    
    init(controller: FetchController) {
        self.controller = controller
        
        // probably should only run this if there is less than 386 pokemon in coredata
        Task {
            await getPokemon()
        }
    }
    
    private func getPokemon() async {
        status = Status.fetching
        do {
            var pokedex = try await controller.fetchAllPokemon()
            // async means will not come back in order of id so needs sort
            pokedex.sort { $0.id < $1.id }
            
            for pokemon in pokedex {
                let newPokemon = Pokemon(context: PersistenceController.shared.container.viewContext)
                newPokemon.id = Int16(pokemon.id)
                newPokemon.name = pokemon.name
                newPokemon.types = pokemon.types
                newPokemon.hp = Int16(pokemon.hp)
                newPokemon.attack = Int16(pokemon.attack)
                newPokemon.defense = Int16(pokemon.defense)
                newPokemon.specialAttack = Int16(pokemon.specialAttack)
                newPokemon.specialDefense = Int16(pokemon.specialDefense)
                newPokemon.speed = Int16(pokemon.speed)
                newPokemon.sprite = pokemon.sprite
                newPokemon.shiny = pokemon.shiny
                newPokemon.favorite = false
                
                try PersistenceController.shared.container.viewContext.save()
            }
            
            status = Status.success
        } catch {
            status = Status.failed(error: error)
        }
    }
}
