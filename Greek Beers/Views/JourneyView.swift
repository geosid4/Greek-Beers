//
//  JourneyView.swift
//  Zythos
//

import SwiftData
import SwiftUI

// The Journey tab: what the user has tried, rated and saved
struct JourneyView: View {

    @Environment(BeersViewModel.self) private var beersVM
    @Environment(BreweriesViewModel.self) private var breweriesVM
    @Environment(AppRouter.self) private var router
    @Query private var beerLogs: [BeerLog]
    @Query private var breweryLogs: [BreweryLog]

    var body: some View {
        NavigationStack {
            Group {
                if tried.isEmpty && favoriteBeers.isEmpty && favoriteBreweries.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Palette.background)
            .navigationTitle("Journey")
            .navigationDestination(for: Beer.self) { beer in
                BeerDetailView(beer: beer)
            }
        }
    }
}

#Preview {
    JourneyView()
        .environment(BeersViewModel())
        .environment(BreweriesViewModel())
        .environment(AppRouter())
        .modelContainer(for: [BeerLog.self, BreweryLog.self], inMemory: true)
}

extension JourneyView {

    private var catalog: Catalog { beersVM.catalog }

    // Logs are joined to the catalog by id; logs for beers no longer in the catalog are skipped
    private var tried: [(beer: Beer, log: BeerLog)] {
        beerLogs
            .filter(\.isTried)
            .compactMap { log in catalog.beers.first { $0.id == log.beerId }.map { ($0, log) } }
            .sorted { ($0.log.triedAt ?? .distantPast) > ($1.log.triedAt ?? .distantPast) }
    }

    private var favoriteBeers: [Beer] {
        let ids = Set(beerLogs.filter(\.isFavorite).map(\.beerId))
        return catalog.beers.filter { ids.contains($0.id) }
    }

    private var favoriteBreweries: [Brewery] {
        let ids = Set(breweryLogs.filter(\.isFavorite).map(\.breweryId))
        return catalog.breweries.filter { ids.contains($0.id) }
    }

    private var list: some View {
        List {
            Group {
                Section {
                    summary
                }

                if !favoriteBeers.isEmpty {
                    Section("Αγαπημένες μπύρες") {
                        ForEach(favoriteBeers) { beer in
                            NavigationLink(value: beer) {
                                beerRow(beer)
                            }
                        }
                    }
                }

                if !favoriteBreweries.isEmpty {
                    Section("Αγαπημένες ζυθοποιίες") {
                        ForEach(favoriteBreweries) { brewery in
                            Button {
                                router.showOnMap(brewery, using: breweriesVM)
                            } label: {
                                HStack(spacing: 12) {
                                    BreweryLogoView(brewery: brewery, size: 40)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(brewery.name)
                                            .font(.headline)
                                        Text(brewery.city)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    Image(systemName: "map")
                                        .foregroundStyle(Color.accentColor)
                                }
                                .foregroundStyle(Color.primary)
                            }
                        }
                    }
                }

                if !tried.isEmpty {
                    Section("Δοκίμασες") {
                        ForEach(tried, id: \.beer.id) { beer, _ in
                            NavigationLink(value: beer) {
                                beerRow(beer)
                            }
                        }
                    }
                }
            }
            .listRowBackground(Palette.surface)
        }
        .listStyle(.insetGrouped)
        .appListBackground()
    }

    private func beerRow(_ beer: Beer) -> some View {
        let log = beerLogs.first { $0.beerId == beer.id }
        return BeerRowView(beer: beer, breweryName: beersVM.brewery(for: beer)?.name,
                           isTried: log?.isTried == true, rating: log?.rating)
    }

    // A first taste of the Beer Passport: how much of the catalog the user has covered
    private var summary: some View {
        let triedBeers = tried.map(\.beer)
        let breweryIds = Set(triedBeers.map(\.breweryId))
        let regions = Set(catalog.breweries.filter { breweryIds.contains($0.id) }.map(\.region))

        return HStack {
            stat(value: triedBeers.count, total: catalog.beers.count, label: "Μπύρες")
            Divider()
            stat(value: breweryIds.count, total: catalog.breweries.count, label: "Ζυθοποιίες")
            Divider()
            stat(value: regions.count, total: Region.allCases.count, label: "Περιφέρειες")
        }
        .padding(.vertical, 4)
    }

    private func stat(value: Int, total: Int, label: String) -> some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.title)
                .fontWeight(.bold)
                + Text(" / \(total)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("Το ταξίδι σου ξεκινά εδώ", systemImage: "medal")
        } description: {
            Text("Άνοιξε μια μπύρα και πάτα «Το δοκίμασα», βάλε αστέρια ή κράτα τις αγαπημένες σου.")
        } actions: {
            Button("Δες τις μπύρες") {
                router.tab = .beers
            }
            .buttonStyle(.borderedProminent)
            .foregroundStyle(Palette.background)
        }
    }
}
