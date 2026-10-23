//
//  Beer.swift
//  Zythos
//

import Foundation

struct Beer: Identifiable, Hashable, Decodable {

    // Stable identifier, "<brewery id>-<beer slug>". Never change it once published
    let id: String
    let breweryId: String
    // The brewery's product line, e.g. VOREIA from Siris. nil when the brewery sells under its own name
    let brandId: String?
    let name: String
    // The style as the brewery labels it, e.g. "Bohemian Pilsner"
    let style: String
    let styleFamily: StyleFamily
    let abv: Double?
    // Only when a reliable source states it. Some breweries give a range, e.g. 18-22
    let ibu: Int?
    let ibuMax: Int?
    let color: BeerColor?
    let filtered: Bool?
    // Greek or local ingredients worth highlighting, e.g. "μαστίχα"
    let localIngredients: [String]
    let description: String?
    let source: URL?
    let lastVerified: Date?
}

// One taxonomy for every brewery and brand, with families a casual drinker recognises instead of
// the 100+ BJCP styles. Each beer has exactly one family; its precise style stays in Beer.style
enum StyleFamily: String, Decodable, CaseIterable, Identifiable {
    // Helles, Vienna, Bohemian, Hoppy Lager
    case lager
    // German and Czech Pilsner
    case pilsner
    // Pale Ale, West and East Coast IPA, NEIPA, Session IPA
    case paleAleIPA = "pale-ale-ipa"
    // Witbier, Weissbier, Hefeweizen
    case wheat
    // Amber Ale, Irish Red Ale
    case amberRed = "amber-red"
    // Stout, Porter, Imperial Porter
    case dark
    // Saison, Tripel, Belgian Strong Ale
    case belgian
    // Berliner Weisse, Gose, Fruited Sour
    case sour
    // Barrel-aged, smoked, unusual ingredients, or a style the brewery doesn't name
    case specialty
    // Low-alcohol and alcohol-free, whatever the base style
    case lowNoAlcohol = "low-no-alcohol"

    var id: Self { self }

    var name: String {
        switch self {
        case .lager: "Lager"
        case .pilsner: "Pilsner"
        case .paleAleIPA: "Pale Ale & IPA"
        case .wheat: "Μπύρες σίτου"
        case .amberRed: "Amber & Red Ale"
        case .dark: "Stout & Porter"
        case .belgian: "Belgian"
        case .sour: "Sour"
        case .specialty: "Ιδιαίτερες"
        case .lowNoAlcohol: "Χαμηλό / χωρίς αλκοόλ"
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
