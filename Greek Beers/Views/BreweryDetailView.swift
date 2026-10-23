//
//  BreweryDetailView.swift
//  Zythos
//
//  Created by George Sidiropoulos on 13/7/23.
//

import SwiftData
import SwiftUI

// The sheet's brewery state: name and close button in the header, everything else scrolls
struct BreweryDetailView: View {

    @Environment(\.openURL) private var openURL
    @Environment(\.modelContext) private var modelContext
    @Query private var logs: [BeerLog]
    @Query private var breweryLogs: [BreweryLog]

    let brewery: Brewery
    let beers: [Beer]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                actions
                if brewery.canBeVisited {
                    visitCard
                }
                beersSection
                aboutSection
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
    }
}

#Preview {
    let catalog = Catalog.bundled
    let brewery = catalog.breweries[0]
    return VStack {
        BreweryDetailView.Header(brewery: brewery)
        BreweryDetailView(brewery: brewery, beers: catalog.beers(for: brewery))
    }
    .environment(BreweriesViewModel())
    .modelContainer(for: [BeerLog.self, BreweryLog.self], inMemory: true)
}

extension BreweryDetailView {

    private var actions: some View {
        HStack(spacing: 8) {
            Button {
                openURL(directionsURL)
            } label: {
                Label("Οδηγίες", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .foregroundStyle(Palette.background)

            if let website = brewery.website {
                Button {
                    openURL(website)
                } label: {
                    Label("Ιστοσελίδα", systemImage: "safari")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
        .controlSize(.large)
    }

    // Opens Apple Maps with directions to the brewery
    private var directionsURL: URL {
        var components = URLComponents(string: "https://maps.apple.com/")!
        components.queryItems = [
            URLQueryItem(name: "daddr", value: "\(brewery.latitude),\(brewery.longitude)"),
            URLQueryItem(name: "q", value: brewery.name)
        ]
        return components.url!
    }

    private var visitedAt: Date? {
        breweryLogs.first { $0.breweryId == brewery.id }?.visitedAt
    }

    // The brewery's stamp in the Passport: gray and dashed until the user has been there
    private var visitCard: some View {
        HStack(spacing: 14) {
            PassportStamp(brewery: brewery, isVisited: visitedAt != nil, size: 64)

            VStack(alignment: .leading, spacing: 6) {
                if let visitedAt {
                    Text("Σφραγίστηκε \(visitedAt.formatted(date: .abbreviated, time: .omitted))")
                        .font(.headline)
                    Text("Η επίσκεψη μετράει στο διαβατήριό σου, ξεχωριστά από τις μπύρες.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Η σφραγίδα της \(brewery.name)")
                        .font(.headline)
                    Text("Πέρασες από τη ζυθοποιία; Σφράγισε το διαβατήριό σου.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Button(visitedAt == nil ? "Σφράγισε επίσκεψη" : "Αναίρεση") {
                    withAnimation(.snappy) {
                        modelContext.updateLog(for: brewery) { log in
                            log.visitedAt = log.visitedAt == nil ? .now : nil
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .foregroundStyle(Palette.background)
                .controlSize(.small)
                .padding(.top, 2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .background(Palette.surface, in: .rect(cornerRadius: 18))
    }

    private var beersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text(beers.count == 1 ? "1 μπύρα" : "\(beers.count) μπύρες")
                    .font(.display(.title2))
                Spacer()
                if !beers.isEmpty {
                    Text("Δοκίμασες \(triedCount)/\(beers.count)")
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }

            if !beers.isEmpty {
                ProgressView(value: Double(triedCount), total: Double(beers.count))
            }

            if beers.isEmpty {
                Text("Δεν έχουμε καταχωρίσει ακόμα μπύρες γι' αυτή τη ζυθοποιία.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(beers) { beer in
                    let log = logs.first { $0.beerId == beer.id }
                    BeerRowView(beer: beer, isTried: log?.isTried == true, rating: log?.rating)
                    if beer != beers.last {
                        Divider()
                    }
                }
            }
        }
    }

    private var triedCount: Int {
        let tried = Set(logs.filter(\.isTried).map(\.beerId))
        return beers.filter { tried.contains($0.id) }.count
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Σχετικά")
                .font(.display(.title2))

            VStack(alignment: .leading, spacing: 6) {
                Label(brewery.region.name, systemImage: "map")
                if let founded = brewery.founded {
                    Label("Από το \(String(founded))", systemImage: "calendar")
                }
                if let visitable = brewery.visitable {
                    Label(visitable ? "Δέχεται επισκέψεις" : "Δεν δέχεται επισκέψεις",
                          systemImage: visitable ? "door.left.hand.open" : "door.left.hand.closed")
                }
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            Text(brewery.description)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }
}

extension BreweryDetailView {

    struct Header: View {

        @Environment(BreweriesViewModel.self) private var vm
        @Environment(\.modelContext) private var modelContext
        @Query private var logs: [BreweryLog]

        let brewery: Brewery

        private var isFavorite: Bool {
            logs.first { $0.breweryId == brewery.id }?.isFavorite == true
        }

        var body: some View {
            HStack(spacing: 12) {
                BreweryLogoView(brewery: brewery, size: 56)

                VStack(alignment: .leading, spacing: 2) {
                    Text(brewery.name)
                        .font(.display(.title))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text("\(brewery.city) · \(brewery.kind.name)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                FavoriteButton(isFavorite: isFavorite) {
                    modelContext.updateLog(for: brewery) { $0.isFavorite.toggle() }
                }
                .font(.title3)

                Button(action: vm.deselect) {
                    Image(systemName: "xmark")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 30, height: 30)
                        .background(.quaternary, in: .circle)
                }
                .accessibilityLabel("Κλείσιμο")
            }
            .padding(.horizontal)
            .padding(.bottom, 12)
        }
    }
}
