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

    //Brewery open in the sheet, nil while the sheet shows the list
    private(set) var selectedBrewery: Brewery?

    var cameraPosition: MapCameraPosition = .automatic

    var sheetDetent: SheetDetent = .collapsed

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
        self.cameraPosition = .region(Self.region(fitting: catalog.breweries))
    }

    //Frames every brewery that passes the filters, e.g. after the filters change
    func frameFilteredBreweries() {
        guard !filteredBreweries.isEmpty else { return }
        withAnimation(.snappy) {
            cameraPosition = .region(Self.region(fitting: filteredBreweries))
        }
    }

    // MapKit's .automatic framing gets clipped by the camera bounds, so frame the pins ourselves
    private static func region(fitting breweries: [Brewery]) -> MKCoordinateRegion {
        guard let first = breweries.first else {
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 38.6, longitude: 24.2),
                span: MKCoordinateSpan(latitudeDelta: 7, longitudeDelta: 7))
        }
        var minLat = first.latitude, maxLat = first.latitude
        var minLon = first.longitude, maxLon = first.longitude
        for brewery in breweries.dropFirst() {
            minLat = min(minLat, brewery.latitude)
            maxLat = max(maxLat, brewery.latitude)
            minLon = min(minLon, brewery.longitude)
            maxLon = max(maxLon, brewery.longitude)
        }
        // Margin so edge pins aren't cut off, and a floor so one pin doesn't zoom to street level
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLon + maxLon) / 2),
            span: MKCoordinateSpan(latitudeDelta: max((maxLat - minLat) * 1.4, 1.5),
                                   longitudeDelta: max((maxLon - minLon) * 1.4, 1.5)))
    }

    func select(_ brewery: Brewery) {
        withAnimation(.snappy) {
            selectedBrewery = brewery
            sheetDetent = .medium
            cameraPosition = .region(MKCoordinateRegion(
                center: brewery.coordinates,
                span: MKCoordinateSpan(latitudeDelta: 1.5, longitudeDelta: 1.5)))
        }
    }

    //Back to the list, with the map framing every visible pin again
    func deselect() {
        withAnimation(.snappy) {
            selectedBrewery = nil
            sheetDetent = .collapsed
        }
        frameFilteredBreweries()
    }
}
