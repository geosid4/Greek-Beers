//
//  Catalog.swift
//  Zythos
//
//  Created by George Sidiropoulos on 11/7/23.
//

import Foundation
import OSLog

// The curated breweries and beers, bundled as breweries.json and beers.json
struct Catalog {

    let breweries: [Brewery]
    let beers: [Beer]

    static let empty = Catalog(breweries: [], beers: [])

    // Loaded once. A broken bundled file is a bug, so it stops debug builds and
    // falls back to an empty catalog in release rather than crashing users
    static let bundled: Catalog = {
        do {
            return try load(from: .main)
        } catch {
            Logger().error("Could not load the bundled catalog: \(error)")
            assertionFailure("Could not load the bundled catalog: \(error)")
            return .empty
        }
    }()

    static func load(from bundle: Bundle) throws -> Catalog {
        let catalog = Catalog(
            breweries: try decode([Brewery].self, resource: "breweries", from: bundle),
            beers: try decode([Beer].self, resource: "beers", from: bundle))
        try catalog.validate()
        return catalog
    }

    func beers(for brewery: Brewery) -> [Beer] {
        beers.filter { $0.breweryId == brewery.id }
    }

    // Catches hand-editing mistakes: duplicate ids and beers pointing at a missing brewery
    private func validate() throws {
        let breweryIds = breweries.map(\.id)
        let beerIds = beers.map(\.id)
        if let duplicate = firstDuplicate(in: breweryIds + beerIds) {
            throw CatalogError.duplicateId(duplicate)
        }
        let known = Set(breweryIds)
        if let orphan = beers.first(where: { !known.contains($0.breweryId) }) {
            throw CatalogError.unknownBrewery(beer: orphan.id, brewery: orphan.breweryId)
        }
    }

    private func firstDuplicate(in ids: [String]) -> String? {
        var seen = Set<String>()
        return ids.first { !seen.insert($0).inserted }
    }

    private static func decode<T: Decodable>(_ type: T.Type, resource: String, from bundle: Bundle) throws -> T {
        guard let url = bundle.url(forResource: resource, withExtension: "json") else {
            throw CatalogError.missingFile("\(resource).json")
        }
        return try decoder.decode(type, from: Data(contentsOf: url))
    }

    // Dates in the JSON are plain days, e.g. "2026-10-23"
    private static let decoder: JSONDecoder = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd"

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(formatter)
        return decoder
    }()
}

enum CatalogError: Error {
    case missingFile(String)
    case duplicateId(String)
    case unknownBrewery(beer: String, brewery: String)
}
