//
//  BeerDetailView.swift
//  Zythos
//

import SwiftUI

struct BeerDetailView: View {

    @Environment(BeersViewModel.self) private var vm
    @Environment(BreweriesViewModel.self) private var breweriesVM
    @Environment(AppRouter.self) private var router

    let beer: Beer

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                if let brewery = vm.brewery(for: beer) {
                    breweryCard(brewery)
                }
                facts
                if let description = beer.description {
                    Text(description)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                dataNotice
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .navigationTitle(beer.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        BeerDetailView(beer: Catalog.bundled.beers[4])
    }
    .environment(BeersViewModel())
    .environment(BreweriesViewModel())
    .environment(AppRouter())
}

extension BeerDetailView {

    private var header: some View {
        HStack(spacing: 16) {
            BeerColorSwatch(beer: beer, size: 64)

            VStack(alignment: .leading, spacing: 4) {
                Text(beer.name)
                    .font(.title)
                    .fontWeight(.bold)
                Text(beer.style)
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func breweryCard(_ brewery: Brewery) -> some View {
        Button {
            router.showOnMap(brewery, using: breweriesVM)
        } label: {
            HStack(spacing: 12) {
                BreweryLogoView(brewery: brewery, size: 44)
                VStack(alignment: .leading, spacing: 2) {
                    Text(brewery.name)
                        .font(.headline)
                    Text("\(brewery.city) · Δες στον χάρτη")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "map")
                    .foregroundStyle(Color.accentColor)
            }
            .padding(12)
            .background(.quaternary.opacity(0.5), in: .rect(cornerRadius: 14))
            .foregroundStyle(Color.primary)
        }
        .buttonStyle(.plain)
    }

    // Only the facts we know; nothing is shown as "unknown"
    private var facts: some View {
        let rows: [(String, String)] = [
            ("Οικογένεια", beer.styleFamily.name),
            ("Αλκοόλ", beer.formattedABV),
            ("Πικράδα", beer.ibu.map { "\($0) IBU" }),
            ("Χρώμα", beer.color?.name),
            ("Φιλτράρισμα", beer.filtered.map { $0 ? "Φιλτραρισμένη" : "Αφιλτράριστη" }),
            ("Τοπικά υλικά", beer.localIngredients.isEmpty ? nil : beer.localIngredients.joined(separator: ", "))
        ].compactMap { label, value in value.map { (label, $0) } }

        return VStack(spacing: 0) {
            ForEach(rows, id: \.0) { label, value in
                HStack {
                    Text(label)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(value)
                        .multilineTextAlignment(.trailing)
                }
                .font(.subheadline)
                .padding(.vertical, 10)
                if label != rows.last?.0 {
                    Divider()
                }
            }
        }
    }

    // Data quality is the point of the catalog, so say when a beer hasn't been checked
    @ViewBuilder
    private var dataNotice: some View {
        if let lastVerified = beer.lastVerified {
            HStack(spacing: 4) {
                Text("Ελέγχθηκε \(lastVerified.formatted(date: .abbreviated, time: .omitted))")
                if let source = beer.source {
                    Text("·")
                    Link("Πηγή", destination: source)
                }
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        } else {
            Label("Τα στοιχεία δεν έχουν επιβεβαιωθεί ακόμα.", systemImage: "exclamationmark.circle")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}
