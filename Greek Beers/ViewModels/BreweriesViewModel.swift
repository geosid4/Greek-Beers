//
//  BreweriesViewModel.swift
//  Zythos
//
//  Created by George Sidiropoulos on 11/7/23.
//

import Foundation
import MapKit
import SwiftUI

@Observable
final class BreweriesViewModel {

    let catalog: Catalog

    var breweries: [Brewery] { catalog.breweries }

    //Brewery currently shown on the map
    var selectedBrewery: Brewery? {
        didSet {
            if let selectedBrewery { updateMapRegion(brewery: selectedBrewery) }
        }
    }

    var cameraPosition: MapCameraPosition = .automatic
    private let mapSpan = MKCoordinateSpan(latitudeDelta: 7.0, longitudeDelta: 7.0)

    //Show list of breweries
    var showBreweryList = false

    //Show brewery detail sheet
    var sheetBrewery: Brewery?

    //Search and filters
    var searchText = ""
    var regionFilter: Region?
    var kindFilter: Brewery.Kind?
    var visitableOnly = false

    var isFiltering: Bool {
        !searchText.isEmpty || regionFilter != nil || kindFilter != nil || visitableOnly
    }

    //Only the regions and kinds that some brewery has, so filters never offer empty choices
    var availableRegions: [Region] {
        let used = Set(breweries.map(\.region))
        return Region.allCases.filter(used.contains)
    }

    var availableKinds: [Brewery.Kind] {
        let used = Set(breweries.map(\.kind))
        return Brewery.Kind.allCases.filter(used.contains)
    }

    //Breweries that pass the search and filters, in catalog order
    var filteredBreweries: [Brewery] {
        breweries.filter { brewery in
            (regionFilter == nil || brewery.region == regionFilter)
                && (kindFilter == nil || brewery.kind == kindFilter)
                && (!visitableOnly || brewery.visitable == true)
                && matchesSearch(brewery)
        }
    }

    // Case and accent insensitive, so "βεργινα" finds "Βεργίνα".
    // Also matches the brewery's beers, so "IPA" finds breweries that make one
    private func matchesSearch(_ brewery: Brewery) -> Bool {
        let query = searchText.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return true }
        let fields = [brewery.name, brewery.city, brewery.region.name]
            + catalog.beers(for: brewery).flatMap { [$0.name, $0.style] }
        return fields.contains { $0.localizedStandardContains(query) }
    }

    func clearFilters() {
        searchText = ""
        regionFilter = nil
        kindFilter = nil
        visitableOnly = false
    }

    //Filtered breweries grouped by region, in the order the regions are declared
    var breweriesByRegion: [(region: Region, breweries: [Brewery])] {
        let grouped = Dictionary(grouping: filteredBreweries, by: \.region)
        return Region.allCases.compactMap { region in
            guard let breweries = grouped[region] else { return nil }
            return (region, breweries.sorted { $0.name < $1.name })
        }
    }

    init(catalog: Catalog = .bundled) {
        self.catalog = catalog
        self.selectedBrewery = catalog.breweries.first
        if let first = catalog.breweries.first {
            updateMapRegion(brewery: first)
        }
    }

    private func updateMapRegion(brewery: Brewery) {
        withAnimation(.easeInOut) {
            cameraPosition = .region(MKCoordinateRegion(
                center: brewery.coordinates,
                span: mapSpan))
        }
    }

    func toggleBreweryList() {
        withAnimation(.easeInOut) {
            showBreweryList.toggle()
        }
    }

    func show(_ brewery: Brewery) {
        withAnimation(.easeInOut) {
            selectedBrewery = brewery
            showBreweryList = false
        }
    }

    // Steps through the breweries that pass the filters
    func nextButtonPressed() {
        let candidates = filteredBreweries
        guard let first = candidates.first else {
            print("Ώρα για Ουίσκι!")
            return
        }
        guard let selectedBrewery,
              let currentIndex = candidates.firstIndex(of: selectedBrewery) else {
            show(first)
            return
        }

        // Wrap around to the first brewery after the last one
        let nextIndex = (currentIndex + 1) % candidates.count
        show(candidates[nextIndex])
    }
}
