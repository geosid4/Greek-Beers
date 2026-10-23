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

    var searchText = ""
    var sortOrder: SortOrder = .name

    //Filters. An empty set means no filter on that dimension
    var selectedBreweryIds: Set<String> = []
    var selectedFamilies: Set<StyleFamily> = []
    var selectedRegions: Set<Region> = []
    var selectedTags: Set<BeerTag> = []
    var localIngredientsOnly = false

    var activeFilterCount: Int {
        selectedBreweryIds.count + selectedFamilies.count + selectedRegions.count + selectedTags.count
            + (localIngredientsOnly ? 1 : 0)
    }

    var filteredBeers: [Beer] {
        sorted(catalog.beers.filter { beer in
            (selectedBreweryIds.isEmpty || selectedBreweryIds.contains(beer.breweryId))
                && (selectedFamilies.isEmpty || selectedFamilies.contains(beer.styleFamily))
                && (selectedRegions.isEmpty || brewery(for: beer).map { selectedRegions.contains($0.region) } == true)
                && (selectedTags.isEmpty || !selectedTags.isDisjoint(with: beer.characteristics))
                && (!localIngredientsOnly || !beer.localIngredients.isEmpty)
                && matchesSearch(beer)
        })
    }

    var breweriesByName: [Brewery] {
        catalog.breweries.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    var selectedBreweries: [Brewery] {
        breweriesByName.filter { selectedBreweryIds.contains($0.id) }
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
            let count = catalog.beers.filter { brewery(for: $0)?.region == region }.count
            return count > 0 ? (region, count) : nil
        }
    }

    var tags: [(tag: BeerTag, count: Int)] {
        BeerTag.allCases.compactMap { tag in
            let count = catalog.beers.filter { $0.characteristics.contains(tag) }.count
            return count > 0 ? (tag, count) : nil
        }
    }

    init(catalog: Catalog = .bundled) {
        self.catalog = catalog
    }

    func toggle(_ brewery: Brewery) {
        selectedBreweryIds.formSymmetricDifference([brewery.id])
    }

    func toggle(_ family: StyleFamily) {
        selectedFamilies.formSymmetricDifference([family])
    }

    func toggle(_ region: Region) {
        selectedRegions.formSymmetricDifference([region])
    }

    func toggle(_ tag: BeerTag) {
        selectedTags.formSymmetricDifference([tag])
    }

    func clearFilters() {
        selectedBreweryIds = []
        selectedFamilies = []
        selectedRegions = []
        selectedTags = []
        localIngredientsOnly = false
    }

    func beerCount(for brewery: Brewery) -> Int {
        catalog.beers(for: brewery).count
    }

    func brewery(for beer: Beer) -> Brewery? {
        catalog.brewery(for: beer)
    }

    func brand(for beer: Beer) -> Brand? {
        catalog.brand(for: beer)
    }

    // Case and accent insensitive; also matches the brand, the brewery, its city and the local ingredients
    private func matchesSearch(_ beer: Beer) -> Bool {
        let query = searchText.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return true }
        let fields = [beer.name, beer.style, beer.styleFamily.name]
            + beer.localIngredients
            + beer.characteristics.map(\.name)
            + [brand(for: beer)?.name, brewery(for: beer)?.name, brewery(for: beer)?.city].compactMap { $0 }
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
