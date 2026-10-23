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
    // How the beer departs from its base style: smoked, barrel-aged, brewed with honey…
    let tags: [BeerTag]
    let description: String?
    let source: URL?
    let lastVerified: Date?

    // Everything to filter on: the tags from the catalog plus what follows from the facts,
    // so low alcohol and unfiltered never need to be typed in by hand
    var characteristics: [BeerTag] {
        var all = Set(tags)
        if let abv, abv <= BeerTag.lowAlcoholLimit { all.insert(.lowAlcohol) }
        if filtered == false { all.insert(.unfiltered) }
        return BeerTag.allCases.filter(all.contains)
    }
}

// Qualities that cut across styles. A smoked amber ale is an amber ale first
enum BeerTag: String, Decodable, CaseIterable, Identifiable {
    case smoked
    case barrelAged = "barrel-aged"
    case honey
    case fruit
    case spiced
    case unfiltered
    case lowAlcohol = "low-alcohol"

    // Up to 1.2% ABV, the usual line for "alcohol-free" and "low alcohol" labels
    static let lowAlcoholLimit = 1.2

    var id: Self { self }

    var name: String {
        switch self {
        case .smoked: "Καπνιστή"
        case .barrelAged: "Σε βαρέλι"
        case .honey: "Με μέλι"
        case .fruit: "Με φρούτα"
        case .spiced: "Με μπαχαρικά"
        case .unfiltered: "Αφιλτράριστη"
        case .lowAlcohol: "Χαμηλό αλκοόλ"
        }
    }

    var symbol: String {
        switch self {
        case .smoked: "smoke"
        case .barrelAged: "cylinder.split.1x2"
        case .honey: "hexagon"
        case .fruit: "tree"
        case .spiced: "sparkles"
        case .unfiltered: "drop.halffull"
        case .lowAlcohol: "gauge.with.dots.needle.0percent"
        }
    }
}

// One taxonomy for every brewery and brand, with families a casual drinker recognises instead of
// the 100+ BJCP styles. Each beer has exactly one family, its base style; the precise style stays
// in Beer.style and anything cross-cutting (smoked, barrel-aged, low alcohol) is a BeerTag
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
    // Barley Wine, Old Ale, Scotch Ale
    case strongAle = "strong-ale"
    // Berliner Weisse, Gose, Fruited Sour
    case sour
    // Only for beers whose base style the brewery doesn't name
    case specialty

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
        case .strongAle: "Strong Ale"
        case .sour: "Sour"
        case .specialty: "Άλλα στυλ"
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
