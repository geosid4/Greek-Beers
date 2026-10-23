//
//  BreweryDetailView.swift
//  Zythos
//
//  Created by George Sidiropoulos on 13/7/23.
//

import SwiftUI

// The sheet's brewery state: name and close button in the header, everything else scrolls
struct BreweryDetailView: View {

    @Environment(\.openURL) private var openURL

    let brewery: Brewery
    let beers: [Beer]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                actions
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

    private var beersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Μπύρες")
                .font(.title3)
                .fontWeight(.semibold)

            if beers.isEmpty {
                Text("Δεν έχουμε καταχωρίσει ακόμα μπύρες γι' αυτή τη ζυθοποιία.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(beers) { beer in
                    BeerRowView(beer: beer)
                    if beer != beers.last {
                        Divider()
                    }
                }
            }
        }
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Σχετικά")
                .font(.title3)
                .fontWeight(.semibold)

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

        let brewery: Brewery

        var body: some View {
            HStack(spacing: 12) {
                BreweryLogoView(brewery: brewery, size: 56)

                VStack(alignment: .leading, spacing: 2) {
                    Text(brewery.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text("\(brewery.city) · \(brewery.kind.name)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

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
