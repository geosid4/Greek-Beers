//
//  BeersViewModel.swift
//  Zythos
//

import Foundation

@Observable
final class BeersViewModel {

    enum SortOrder: String, CaseIterable, Identifiable {
        case name = "Όνομα"
        case strongest = "Πιο δυνατές"
        case lightest = "Πιο ελαφριές"

        var id: Self { self }
    }

    let catalog: Catalog

    //Search, filters and sorting
    var searchText = ""
    var familyFilter: StyleFamily?
    var localIngredientsOnly = false
    var sortOrder: SortOrder = .name

    var isFiltering: Bool {
        !searchText.isEmpty || familyFilter != nil || localIngredientsOnly
    }

    //Only the families some beer belongs to, so filters never offer empty choices
    var availableFamilies: [StyleFamily] {
        let used = Set(catalog.beers.map(\.styleFamily))
        return StyleFamily.allCases.filter(used.contains)
    }

    //Beers that pass the search and filters, grouped by style family in declaration order
    var beersByFamily: [(family: StyleFamily, beers: [Beer])] {
        let filtered = catalog.beers.filter { beer in
            (familyFilter == nil || beer.styleFamily == familyFilter)
                && (!localIngredientsOnly || !beer.localIngredients.isEmpty)
                && matchesSearch(beer)
        }
        let grouped = Dictionary(grouping: filtered, by: \.styleFamily)
        return StyleFamily.allCases.compactMap { family in
            guard let beers = grouped[family] else { return nil }
            return (family, sorted(beers))
        }
    }

    init(catalog: Catalog = .bundled) {
        self.catalog = catalog
    }

    func brewery(for beer: Beer) -> Brewery? {
        catalog.breweries.first { $0.id == beer.breweryId }
    }

    func clearFilters() {
        searchText = ""
        familyFilter = nil
        localIngredientsOnly = false
    }

    // Case and accent insensitive; also matches the brewery and the local ingredients
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
