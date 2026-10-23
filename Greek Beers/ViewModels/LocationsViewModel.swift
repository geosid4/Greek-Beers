//
//  LocationsViewModel.swift
//  Greek Beers
//
//  Created by George Sidiropoulos on 11/7/23.
//

import Foundation
import MapKit
import SwiftUI

@Observable
final class LocationsViewModel {

    //All loaded locations
    let locations: [Location]

    //Current location on map
    var mapLocation: Location? {
        didSet {
            if let mapLocation { updateMapRegion(location: mapLocation) }
        }
    }

    var cameraPosition: MapCameraPosition = .automatic
    private let mapSpan = MKCoordinateSpan(latitudeDelta: 7.0, longitudeDelta: 7.0)

    //Show list of locations
    var showLocationsList = false

    //Show location detail sheet
    var sheetLocation: Location?

    //Locations grouped by region, in the order the regions are declared
    var locationsByRegion: [(region: Region, locations: [Location])] {
        let grouped = Dictionary(grouping: locations, by: \.region)
        return Region.allCases.compactMap { region in
            guard let locations = grouped[region] else { return nil }
            return (region, locations.sorted { $0.name < $1.name })
        }
    }

    init(locations: [Location] = LocationDataService.locations) {
        self.locations = locations
        self.mapLocation = locations.first
        if let first = locations.first {
            updateMapRegion(location: first)
        }
    }

    private func updateMapRegion(location: Location) {
        withAnimation(.easeInOut) {
            cameraPosition = .region(MKCoordinateRegion(
                center: location.coordinates,
                span: mapSpan))
        }
    }

    func toggleLocationsList() {
        withAnimation(.easeInOut) {
            showLocationsList.toggle()
        }
    }

    func showNextLocation(location: Location) {
        withAnimation(.easeInOut) {
            mapLocation = location
            showLocationsList = false
        }
    }

    func nextButtonPressed() {
        guard let mapLocation,
              let currentIndex = locations.firstIndex(of: mapLocation) else {
            print("Ώρα για Ουίσκι!")
            return
        }

        // Wrap around to the first location after the last one
        let nextIndex = (currentIndex + 1) % locations.count
        showNextLocation(location: locations[nextIndex])
    }
}
