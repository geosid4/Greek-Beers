//
//  UserData.swift
//  Zythos
//

import Foundation
import SwiftData

// What the user has recorded about one beer. Stored with SwiftData, while the beer itself
// lives in the bundled catalog: the two are joined only by the beer's stable id, so
// catalog updates never touch the user's ratings
@Model
final class BeerLog {

    @Attribute(.unique) var beerId: String
    // nil until the user marks the beer as tried
    var triedAt: Date?
    // 1 to 5 stars
    var rating: Int?
    var notes: String
    var isFavorite: Bool

    init(beerId: String) {
        self.beerId = beerId
        self.notes = ""
        self.isFavorite = false
    }

    var isTried: Bool { triedAt != nil }

    // A log with nothing in it is deleted rather than kept around
    var isEmpty: Bool {
        triedAt == nil && rating == nil && notes.isEmpty && !isFavorite
    }
}

// What the user has recorded about one brewery
@Model
final class BreweryLog {

    @Attribute(.unique) var breweryId: String
    var isFavorite: Bool

    init(breweryId: String) {
        self.breweryId = breweryId
        self.isFavorite = false
    }

    var isEmpty: Bool { !isFavorite }
}

extension ModelContext {

    // Applies a change to the beer's log, creating it if needed and deleting it if it ends up empty
    func updateLog(for beer: Beer, _ change: (BeerLog) -> Void) {
        let id = beer.id
        let existing = try? fetch(FetchDescriptor<BeerLog>(predicate: #Predicate { $0.beerId == id })).first
        let log = existing ?? BeerLog(beerId: id)
        if existing == nil { insert(log) }
        change(log)
        if log.isEmpty { delete(log) }
    }

    func updateLog(for brewery: Brewery, _ change: (BreweryLog) -> Void) {
        let id = brewery.id
        let existing = try? fetch(FetchDescriptor<BreweryLog>(predicate: #Predicate { $0.breweryId == id })).first
        let log = existing ?? BreweryLog(breweryId: id)
        if existing == nil { insert(log) }
        change(log)
        if log.isEmpty { delete(log) }
    }
}
