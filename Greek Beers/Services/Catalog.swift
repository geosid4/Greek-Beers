//
//  Catalog.swift
//  Zythos
//
//  Created by George Sidiropoulos on 11/7/23.
//

import Foundation
import OSLog

// The curated breweries and beers, bundled as one Catalog/<brewery id>.json file per brewery
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
        guard let urls = bundle.urls(forResourcesWithExtension: "json", subdirectory: "Catalog"),
              !urls.isEmpty else {
            throw CatalogError.missingFile("Catalog/*.json")
        }
        var breweries: [Brewery] = []
        var beers: [Beer] = []
        // Sorted so the catalog order doesn't depend on the file system
        for url in urls.sorted(by: { $0.lastPathComponent < $1.lastPathComponent }) {
            let (brewery, breweryBeers) = try decodeFile(at: url)
            breweries.append(brewery)
            beers += breweryBeers
        }
        let catalog = Catalog(breweries: breweries, beers: beers)
        try catalog.validate()
        return catalog
    }

    func beers(for brewery: Brewery) -> [Beer] {
        beers.filter { $0.breweryId == brewery.id }
    }

    func brewery(for beer: Beer) -> Brewery? {
        breweries.first { $0.id == beer.breweryId }
    }

    func brand(for beer: Beer) -> Brand? {
        brewery(for: beer)?.brand(id: beer.brandId)
    }

    // Catches hand-editing mistakes: duplicate ids, beers pointing at a missing brewery,
    // and beers naming a brand their brewery doesn't have
    private func validate() throws {
        let breweryIds = breweries.map(\.id)
        let brandIds = breweries.flatMap(\.brands).map(\.id)
        let beerIds = beers.map(\.id)
        if let duplicate = firstDuplicate(in: breweryIds + brandIds + beerIds) {
            throw CatalogError.duplicateId(duplicate)
        }
        let known = Set(breweryIds)
        if let orphan = beers.first(where: { !known.contains($0.breweryId) }) {
            throw CatalogError.unknownBrewery(beer: orphan.id, brewery: orphan.breweryId)
        }
        if let stray = beers.first(where: { $0.brandId != nil && brand(for: $0) == nil }) {
            throw CatalogError.unknownBrand(beer: stray.id, brand: stray.brandId ?? "")
        }
    }

    private func firstDuplicate(in ids: [String]) -> String? {
        var seen = Set<String>()
        return ids.first { !seen.insert($0).inserted }
    }

    // A brewery file holds the brewery with its beers nested under "beers". To keep the files short,
    // a beer leaves out its brewery id, and its source and lastVerified when they match the brewery's;
    // nulls and empty lists may be left out too. They are filled in here before decoding
    private static func decodeFile(at url: URL) throws -> (Brewery, [Beer]) {
        let data = try Data(contentsOf: url)
        guard var object = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let breweryId = object["id"] as? String else {
            throw CatalogError.malformedFile(url.lastPathComponent)
        }
        guard url.deletingPathExtension().lastPathComponent == breweryId else {
            throw CatalogError.fileNameMismatch(file: url.lastPathComponent, id: breweryId)
        }
        let beerObjects = object.removeValue(forKey: "beers") as? [[String: Any]] ?? []
        object["brands"] = object["brands"] ?? [Any]()
        object["imageNames"] = object["imageNames"] ?? [Any]()

        let filledBeers = beerObjects.map { beer in
            var beer = beer
            beer["breweryId"] = breweryId
            beer["source"] = beer["source"] ?? object["source"]
            beer["lastVerified"] = beer["lastVerified"] ?? object["lastVerified"]
            beer["localIngredients"] = beer["localIngredients"] ?? [Any]()
            beer["tags"] = beer["tags"] ?? [Any]()
            return beer
        }

        let brewery = try decoder.decode(Brewery.self, from: JSONSerialization.data(withJSONObject: object))
        let beers = try decoder.decode([Beer].self, from: JSONSerialization.data(withJSONObject: filledBeers))
        return (brewery, beers)
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
    case malformedFile(String)
    case fileNameMismatch(file: String, id: String)
    case duplicateId(String)
    case unknownBrewery(beer: String, brewery: String)
    case unknownBrand(beer: String, brand: String)
}
