//
//  Location.swift
//  Greek Beers
//
//  Created by George Sidiropoulos on 11/7/23.
//

import Foundation
import MapKit

struct Location: Identifiable, Hashable {

    // Stable identifier, also used as the logo asset name
    let id: String
    let name: String
    let cityName: String
    let region: Region
    let founded: Int?
    let coordinates: CLLocationCoordinate2D
    let description: String
    let imageNames: [String]
    let link: URL?

    // Identity is the id alone, so edits to the other fields don't break selection
    static func == (lhs: Location, rhs: Location) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// The 13 administrative regions (Περιφέρειες) of Greece, roughly north to south
enum Region: String, CaseIterable, Identifiable {
    case easternMacedoniaThrace = "Ανατολική Μακεδονία και Θράκη"
    case centralMacedonia = "Κεντρική Μακεδονία"
    case westernMacedonia = "Δυτική Μακεδονία"
    case epirus = "Ήπειρος"
    case thessaly = "Θεσσαλία"
    case ionianIslands = "Ιόνια Νησιά"
    case westernGreece = "Δυτική Ελλάδα"
    case centralGreece = "Στερεά Ελλάδα"
    case attica = "Αττική"
    case peloponnese = "Πελοπόννησος"
    case northAegean = "Βόρειο Αιγαίο"
    case southAegean = "Νότιο Αιγαίο"
    case crete = "Κρήτη"

    var id: Self { self }
}
