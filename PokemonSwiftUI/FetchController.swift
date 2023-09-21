//
//  FetchController.swift
//  PokemonSwiftUI
//
//  Created by David McDermott on 9/11/23.
//

import Foundation
import CoreData

struct FetchController {
    enum NetworkError: Error {
        case badUrl, badResponse, badData
    }
    
    private let baseUrl = URL(string: "https://pokeapi.co/api/v2/pokemon")!
    
    func fetchAllPokemon() async throws -> [TempPokemon]? {
        if havePokemon() {
            return nil
        }
        
        var allPokemon: [TempPokemon] = []
        
        var fetchComponents = URLComponents(url: baseUrl, resolvingAgainstBaseURL: true)
        fetchComponents?.queryItems = [URLQueryItem(name: "limit", value: "386")]
        // up to gen 3 pokemon is why the 386
        
        guard let fetchUrl = fetchComponents?.url else {
            throw NetworkError.badUrl
        }
        
        let (data, response) = try await URLSession.shared.data(from: fetchUrl)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkError.badResponse
        }
        
        // raw going through json response because we don't have a model for this call yet (ie no TempPokemon yet)
        guard let pokeDict = try JSONSerialization.jsonObject(with: data) as? [String: Any], let pokedex = pokeDict["results"] as? [[String: String]] else {
            throw NetworkError.badData
        }
        
        for pokemon in pokedex {
            if let url = pokemon["url"] {
                allPokemon.append(try await fetchPokemon(from: URL(string: url)!))
            }
        }
        
        return allPokemon
    }
    
    private func fetchPokemon(from url: URL) async throws -> TempPokemon {
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkError.badResponse
        }
        
        let tempPokemon = try JSONDecoder().decode(TempPokemon.self, from: data)
        
        print("fetched temp pokemon \(tempPokemon.name) with id \(tempPokemon.id)")
        return tempPokemon
    }
    
    private func havePokemon() -> Bool {
        let context = PersistenceController.shared.container.newBackgroundContext()
        
        let fetchRequest: NSFetchRequest<Pokemon> = Pokemon.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id IN %@", [1, 386])
        //check first and last pokemon with predicate
        
        do {
            let checkPokemon = try context.fetch(fetchRequest)
            if checkPokemon.count == 2 {
                return true
            } else {
                return false
            }
        } catch {
            print("fetch 1 and 386th failed \(error)")
            return false
        }
    }
}
