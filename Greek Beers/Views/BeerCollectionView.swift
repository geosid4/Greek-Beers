//
//  BeerCollectionView.swift
//  Zythos
//

import SwiftData
import SwiftUI

// One style family, region or the local-ingredients beers, opened from the Beers tab
struct BeerCollectionView: View {

    @Environment(BeersViewModel.self) private var vm

    let collection: BeerCollection

    var body: some View {
        let beers = vm.beers(in: collection)

        ScrollView {
            if beers.isEmpty {
                ContentUnavailableView("Καμία μπύρα", systemImage: "mug")
                    .padding(.top, 60)
            } else {
                BeerCardList(beers: beers)
                    .padding(.vertical)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(collection.title)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                SortMenu()
            }
        }
    }
}

#Preview {
    NavigationStack {
        BeerCollectionView(collection: .family(.lager))
    }
    .environment(BeersViewModel())
    .modelContainer(for: [BeerLog.self, BreweryLog.self], inMemory: true)
}

// Beers as tappable cards, marked with what the user has tried
struct BeerCardList: View {

    @Environment(BeersViewModel.self) private var vm
    @Query private var logs: [BeerLog]

    let beers: [Beer]

    var body: some View {
        LazyVStack(spacing: 10) {
            ForEach(beers) { beer in
                let log = logs.first { $0.beerId == beer.id }
                NavigationLink(value: beer) {
                    BeerCardView(beer: beer, brewery: vm.brewery(for: beer),
                                 isTried: log?.isTried == true, rating: log?.rating)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
    }
}
