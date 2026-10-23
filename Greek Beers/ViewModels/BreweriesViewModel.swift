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

    //Breweries grouped by region, in the order the regions are declared
    var breweriesByRegion: [(region: Region, breweries: [Brewery])] {
        let grouped = Dictionary(grouping: breweries, by: \.region)
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

    func nextButtonPressed() {
        guard let selectedBrewery,
              let currentIndex = breweries.firstIndex(of: selectedBrewery) else {
            print("Ώρα για Ουίσκι!")
            return
        }

        // Wrap around to the first brewery after the last one
        let nextIndex = (currentIndex + 1) % breweries.count
        show(breweries[nextIndex])
    }
}
