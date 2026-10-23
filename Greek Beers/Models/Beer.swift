//
//  Beer.swift
//  Zythos
//

import Foundation

struct Beer: Identifiable, Hashable, Decodable {

    // Stable identifier, "<brewery id>-<beer slug>". Never change it once published
    let id: String
    let breweryId: String
    let name: String
    // The style as the brewery labels it, e.g. "Bohemian Pilsner"
    let style: String
    let styleFamily: StyleFamily
    let abv: Double?
    // Only when a reliable source states it
    let ibu: Int?
    let color: BeerColor?
    let filtered: Bool?
    // Greek or local ingredients worth highlighting, e.g. "μαστίχα"
    let localIngredients: [String]
    let description: String?
    let source: URL?
    let lastVerified: Date?
}

// A handful of families a casual drinker recognises, instead of the 100+ BJCP styles
enum StyleFamily: String, Decodable, CaseIterable, Identifiable {
    case lager
    case wheat
    case paleAleIPA = "pale-ale-ipa"
    case stoutPorter = "stout-porter"
    case sour
    case belgianStrong = "belgian-strong"
    // Anything that doesn't fit the families above
    case specialty

    var id: Self { self }

    var name: String {
        switch self {
        case .lager: "Lager & Pilsner"
        case .wheat: "Weiss & Σίτου"
        case .paleAleIPA: "Pale Ale & IPA"
        case .stoutPorter: "Stout & Porter"
        case .sour: "Sour"
        case .belgianStrong: "Belgian & Strong"
        case .specialty: "Ιδιαίτερες"
        }
    }
}

enum BeerColor: String, Decodable, CaseIterable, Identifiable {
    case pale
    case amber
    case dark

    var id: Self { self }

    var name: String {
        switch self {
        case .pale: "Ξανθιά"
        case .amber: "Κεχριμπαρένια"
        case .dark: "Σκούρα"
        }
    }
}
