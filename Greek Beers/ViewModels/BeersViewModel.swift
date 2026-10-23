//
//  BeersViewModel.swift
//  Zythos
//

import Foundation

// A group of beers the Beers tab can open on its own page
enum BeerCollection: Hashable {
    case family(StyleFamily)
    case localIngredients
    case region(Region)

    var title: String {
        switch self {
        case .family(let family): family.name
        case .localIngredients: "Με ελληνικά υλικά"
        case .region(let region): region.name
        }
    }
}

@Observable
final class BeersViewModel {

    enum SortOrder: String, CaseIterable, Identifiable {
        case name = "Όνομα"
        case strongest = "Πιο δυνατές"
        case lightest = "Πιο ελαφριές"

        var id: Self { self }
    }

    let catalog: Catalog

    var searchText = ""
    var sortOrder: SortOrder = .name

    var isSearching: Bool {
        !searchText.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var searchResults: [Beer] {
        sorted(catalog.beers.filter(matchesSearch))
    }

    var allBeers: [Beer] {
        sorted(catalog.beers)
    }

    var beersWithLocalIngredients: [Beer] {
        beers(in: .localIngredients)
    }

    //Style families and regions that have at least one beer, with how many
    var families: [(family: StyleFamily, count: Int)] {
        StyleFamily.allCases.compactMap { family in
            let count = catalog.beers.filter { $0.styleFamily == family }.count
            return count > 0 ? (family, count) : nil
        }
    }

    var regions: [(region: Region, count: Int)] {
        Region.allCases.compactMap { region in
            let count = beers(in: .region(region)).count
            return count > 0 ? (region, count) : nil
        }
    }

    init(catalog: Catalog = .bundled) {
        self.catalog = catalog
    }

    func beers(in collection: BeerCollection) -> [Beer] {
        let beers = catalog.beers.filter { beer in
            switch collection {
            case .family(let family): beer.styleFamily == family
            case .localIngredients: !beer.localIngredients.isEmpty
            case .region(let region): brewery(for: beer)?.region == region
            }
        }
        return sorted(beers)
    }

    func brewery(for beer: Beer) -> Brewery? {
        catalog.breweries.first { $0.id == beer.breweryId }
    }

    // Case and accent insensitive; also matches the brewery, its city and the local ingredients
    private func matchesSearch(_ beer: Beer) -> Bool {
        let query = searchText.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return true }
        let fields = [beer.name, beer.style, beer.styleFamily.name]
            + beer.localIngredients
            + [brewery(for: beer)?.name, brewery(for: beer)?.city].compactMap { $0 }
        return fields.contains { $0.localizedStandardContains(query) }
    }

    // Beers without a known ABV go last when sorting by strength
    private func sorted(_ beers: [Beer]) -> [Beer] {
        switch sortOrder {
        case .name:
            return beers.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        case .strongest:
            return beers.sorted { ($0.abv ?? -1) > ($1.abv ?? -1) }
        case .lightest:
            return beers.sorted { ($0.abv ?? .infinity) < ($1.abv ?? .infinity) }
        }
    }
}
