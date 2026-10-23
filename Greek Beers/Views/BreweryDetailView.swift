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
                about
                beersSection
                dataNotice
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
                        .foregroundStyle(Palette.muted)
                } else {
                    Text("Η σφραγίδα της \(brewery.name)")
                        .font(.headline)
                    Text("Πέρασες από τη ζυθοποιία; Σφράγισε το διαβατήριό σου.")
                        .font(.subheadline)
                        .foregroundStyle(Palette.muted)
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
                    Text("Δοκίμασες \(Text("\(triedCount)/\(beers.count)").foregroundStyle(Color.accentColor))")
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(Palette.muted)
                }
            }

            if !beers.isEmpty {
                ProgressView(value: Double(triedCount), total: Double(beers.count))
            }

            if beers.isEmpty {
                Text("Δεν έχουμε καταχωρίσει ακόμα μπύρες γι' αυτή τη ζυθοποιία.")
                    .font(.subheadline)
                    .foregroundStyle(Palette.muted)
            } else if brewery.brands.isEmpty {
                beerRows(beers)
            } else {
                // Breweries with product lines list each line on its own, e.g. VOREIA then Happy Brewers
                ForEach(brandGroups, id: \.title) { group in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .firstTextBaseline) {
                            Text(group.title)
                                .font(.headline)
                            Spacer()
                            if let website = group.website {
                                Link(destination: website) {
                                    Image(systemName: "arrow.up.right.square")
                                }
                                .accessibilityLabel("Ιστοσελίδα \(group.title)")
                            }
                        }
                        beerRows(group.beers)
                    }
                    .padding(.top, 6)
                }
            }
        }
    }

    private func beerRows(_ beers: [Beer]) -> some View {
        ForEach(beers) { beer in
            let log = logs.first { $0.beerId == beer.id }
            BeerRowView(beer: beer, isTried: log?.isTried == true, rating: log?.rating)
                .padding(.vertical, 6)
            if beer != beers.last {
                Divider()
            }
        }
    }

    // The brewery's brands in its own order, then any beer sold under the brewery's name
    private var brandGroups: [(title: String, website: URL?, beers: [Beer])] {
        var groups: [(title: String, website: URL?, beers: [Beer])] = brewery.brands.compactMap { brand in
            let branded = beers.filter { $0.brandId == brand.id }
            return branded.isEmpty ? nil : (brand.name, brand.website, branded)
        }
        let unbranded = beers.filter { $0.brandId == nil }
        if !unbranded.isEmpty {
            groups.append((brewery.name, nil, unbranded))
        }
        return groups
    }

    private var triedCount: Int {
        let tried = Set(logs.filter(\.isTried).map(\.beerId))
        return beers.filter { tried.contains($0.id) }.count
    }

    // What the brewery says about itself, then whether it takes visitors when we know
    private var about: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(brewery.description)
                .font(.body)
                .foregroundStyle(Palette.muted)

            if let visitable = brewery.visitable {
                Label(visitable ? "Δέχεται επισκέψεις" : "Δεν δέχεται επισκέψεις",
                      systemImage: visitable ? "door.left.hand.open" : "door.left.hand.closed")
                    .font(.subheadline)
                    .foregroundStyle(Palette.muted)
            }
        }
    }

    // Data quality is the point of the catalog, so say where this came from and when
    @ViewBuilder
    private var dataNotice: some View {
        if let lastVerified = brewery.lastVerified {
            HStack(spacing: 4) {
                Text("Ελέγχθηκε \(lastVerified.formatted(date: .abbreviated, time: .omitted))")
                if let source = brewery.source {
                    Text("·")
                    Link("Πηγή", destination: source)
                }
            }
            .font(.footnote)
            .foregroundStyle(Palette.muted)
        } else if let source = brewery.source {
            Link("Πηγή: \(source.host() ?? source.absoluteString)", destination: source)
                .font(.footnote)
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

        // "Μικροζυθοποιία · από το 2009"
        private var eyebrow: String {
            [brewery.kind.name, brewery.founded.map { "από το \(String($0))" }]
                .compactMap { $0 }
                .joined(separator: " · ")
        }

        var body: some View {
            HStack(spacing: 12) {
                BreweryLogoView(brewery: brewery, size: 56)

                VStack(alignment: .leading, spacing: 2) {
                    SectionLabel(eyebrow)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text(brewery.name)
                        .font(.display(.title))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text("\(brewery.city) · \(brewery.region.name)")
                        .font(.subheadline)
                        .foregroundStyle(Palette.muted)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                FavoriteButton(isFavorite: isFavorite) {
                    modelContext.updateLog(for: brewery) { $0.isFavorite.toggle() }
                }
                .font(.title3)

                Button(action: vm.deselect) {
                    Image(systemName: "xmark")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Palette.muted)
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
