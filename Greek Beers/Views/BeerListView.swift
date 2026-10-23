//
//  BeerListView.swift
//  Zythos
//

import SwiftData
import SwiftUI

// Beers as tappable rows, marked with what the user has tried
struct BeerList: View {

    @Environment(BeersViewModel.self) private var vm
    @Query private var logs: [BeerLog]

    let beers: [Beer]

    var body: some View {
        LazyVStack(spacing: 0) {
            ForEach(beers) { beer in
                let log = logs.first { $0.beerId == beer.id }
                NavigationLink(value: beer) {
                    BeerRowView(beer: beer, breweryName: producer(of: beer),
                                isTried: log?.isTried == true, rating: log?.rating)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.plain)

                if beer != beers.last {
                    Divider()
                }
            }
        }
    }

    // "VOREIA · Siris Craft Brewery" when the beer belongs to a brand, else the brewery alone
    private func producer(of beer: Beer) -> String? {
        let names = [vm.brand(for: beer)?.name, vm.brewery(for: beer)?.name].compactMap { $0 }
        return names.isEmpty ? nil : names.joined(separator: " · ")
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            BeerList(beers: Catalog.bundled.beers)
                .padding(.horizontal)
        }
        .background(Palette.background)
    }
    .environment(BeersViewModel())
    .modelContainer(for: [BeerLog.self, BreweryLog.self], inMemory: true)
}
