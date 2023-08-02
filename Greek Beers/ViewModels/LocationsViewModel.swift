//
//  LocationsViewModel.swift
//  Greek Beers
//
//  Created by George Sidiropoulos on 11/7/23.
//

import Foundation
import MapKit
import SwiftUI


class LocationsViewModel: ObservableObject {
    
    //All loaded locations
    @Published var locations: [Location]
    
    //Current location on map
    @Published var mapLocation: Location {
        didSet{
            updateMapRegion(location: mapLocation)
        }
    }
    
    @Published var mapRegion: MKCoordinateRegion = MKCoordinateRegion()
    let mapSpan = MKCoordinateSpan(latitudeDelta: 7.0, longitudeDelta: 7.0)
    
    //Show list of locations
    @Published var showLocationsList: Bool = false
    
    
    init(){
        let locations = LocationDataService.locations
        self.locations = locations
        self.mapLocation = locations.first!
        
        self.updateMapRegion(location: locations.first!)
    }
    
    private func updateMapRegion(location: Location) {
        withAnimation(.easeInOut) {
            mapRegion = MKCoordinateRegion(
                center: location.coordinates,
                span: mapSpan)        }
    }
    
     func toggleLocationsList() {
        withAnimation(.easeInOut) {
            showLocationsList = !showLocationsList
        }
    }
    
    func showNextLocation(location: Location) {
        withAnimation(.easeInOut) {
            mapLocation = location
            showLocationsList = false
            
            
        }
    }
        func nextButtonPressed() {
            //get the current index
            guard let currentIndex = locations.firstIndex(where: { $0 == mapLocation}) else {
                print("Ώρα για Ουίσκι!")
                return
            }
            
            //check if the currentIndex is valid
            let nextIndex = currentIndex + 1
            guard locations.indices.contains(nextIndex) else {
                //next index is not valid
                //restart from 0
                guard let firstLocation = locations.first else {return}
                showNextLocation(location: firstLocation)
                return
            }
            
            // Next index IS valid
            let nextLocation = locations[nextIndex]
            showNextLocation(location: nextLocation)
        
        
   }
}
