//
//  PokemonDetail.swift
//  PokemonSwiftUI
//
//  Created by David McDermott on 9/20/23.
//

import SwiftUI
import CoreData

struct PokemonDetail: View {
    
    // for core data saving
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject var pokemon: Pokemon
    @State var showShiny = false
    
    var body: some View {
        ScrollView {
            ZStack {
                Image(pokemon.background)
                    .resizable()
                    .scaledToFit()
                    .shadow(color: .black, radius: 6)
                
                AsyncImage(url: showShiny ? pokemon.shiny : pokemon.sprite) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .padding(.top, 50)
                        .shadow(color: .black, radius: 6)
                } placeholder: {
                    ProgressView()
                }
            }
            
            HStack {
                ForEach(pokemon.types!, id: \.self) { type in
                    Text(type.capitalized)
                        .font(.title2)
                        .shadow(color: .white, radius: 1)
                        .padding([.top, .bottom], 7)
                        .padding([.leading, .trailing])
                        .background(Color(type.capitalized))
                        .cornerRadius(50)
                }
                
                Spacer()
                
                Button {
                    withAnimation {
                        pokemon.favorite.toggle()
                        
                        // apply changes to core data
                        do {
                            try viewContext.save()
                        } catch {
                            let nsError = error as NSError
                            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                        }
                    }
                } label: {
                    if pokemon.favorite {
                        Image(systemName: "star.fill")
                    } else {
                        Image(systemName: "star")
                    }
                }
                .font(.largeTitle)
                .foregroundColor(.yellow)
            }
            .padding()
            
            Text("Stats")
                .font(.title)
                .padding(.bottom, -5)
            
            Stats()
                .environmentObject(pokemon)
            
        }
        .navigationTitle(pokemon.name!.capitalized)  // doesnt show in preview but is there
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showShiny.toggle()
                } label: {
                    if showShiny {
                        Image(systemName: "wand.and.stars")
                            .foregroundColor(.yellow)
                    } else {
                        Image(systemName: "wand.and.stars.inverse")
                    }
                }
            }
        }
    }
}

struct PokemonDetail_Previews: PreviewProvider {
    static var previews: some View {
        
        PokemonDetail()
            .environmentObject(SamplePokemon.samplePokemon)
    }
}
