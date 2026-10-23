//
//  Brewery.swift
//  Zythos
//
//  Created by George Sidiropoulos on 11/7/23.
//

import Foundation
import MapKit

struct Brewery: Identifiable, Hashable, Decodable {

    // Stable identifier. Never change it once published: user data refers to it
    let id: String
    let name: String
    let city: String
    let region: Region
    let kind: Kind
    let founded: Int?
    let latitude: Double
    let longitude: Double
    let description: String
    let imageNames: [String]
    let website: URL?
    // nil when we don't know yet whether it accepts visitors
    let visitable: Bool?
    // Where the information came from, and when someone last checked it
    let source: URL?
    let lastVerified: Date?

    var coordinates: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    // Gypsy brewers have no place of their own; unknown visitability still gets a stamp
    var canBeVisited: Bool {
        kind != .gypsy && visitable != false
    }

    enum Kind: String, Decodable, CaseIterable, Identifiable {
        case microbrewery
        case industrial
        case brewpub
        // Brands that brew at someone else's facility
        case gypsy

        var id: Self { self }

        var name: String {
            switch self {
            case .microbrewery: "Μικροζυθοποιία"
            case .industrial: "Ζυθοποιία"
            case .brewpub: "Brewpub"
            case .gypsy: "Gypsy brewer"
            }
        }
    }
}

// The 13 administrative regions (Περιφέρειες) of Greece, roughly north to south
enum Region: String, Decodable, CaseIterable, Identifiable {
    case easternMacedoniaThrace = "eastern-macedonia-thrace"
    case centralMacedonia = "central-macedonia"
    case westernMacedonia = "western-macedonia"
    case epirus
    case thessaly
    case ionianIslands = "ionian-islands"
    case westernGreece = "western-greece"
    case centralGreece = "central-greece"
    case attica
    case peloponnese
    case northAegean = "north-aegean"
    case southAegean = "south-aegean"
    case crete

    var id: Self { self }

    var name: String {
        switch self {
        case .easternMacedoniaThrace: "Ανατολική Μακεδονία και Θράκη"
        case .centralMacedonia: "Κεντρική Μακεδονία"
        case .westernMacedonia: "Δυτική Μακεδονία"
        case .epirus: "Ήπειρος"
        case .thessaly: "Θεσσαλία"
        case .ionianIslands: "Ιόνια Νησιά"
        case .westernGreece: "Δυτική Ελλάδα"
        case .centralGreece: "Στερεά Ελλάδα"
        case .attica: "Αττική"
        case .peloponnese: "Πελοπόννησος"
        case .northAegean: "Βόρειο Αιγαίο"
        case .southAegean: "Νότιο Αιγαίο"
        case .crete: "Κρήτη"
        }
    }
}
