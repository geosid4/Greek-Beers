//
//  BeerDetailView.swift
//  Zythos
//

import SwiftData
import SwiftUI

struct BeerDetailView: View {

    @Environment(BeersViewModel.self) private var vm
    @Environment(BreweriesViewModel.self) private var breweriesVM
    @Environment(AppRouter.self) private var router
    @Environment(\.modelContext) private var modelContext
    @Query private var logs: [BeerLog]

    let beer: Beer

    @State private var notesDraft = ""

    private var log: BeerLog? {
        logs.first { $0.beerId == beer.id }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                journal
                if let brewery = vm.brewery(for: beer) {
                    breweryCard(brewery)
                }
                facts
                if let description = beer.displayDescription {
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
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                FavoriteButton(isFavorite: log?.isFavorite == true) {
                    modelContext.updateLog(for: beer) { $0.isFavorite.toggle() }
                }
            }
        }
        .onAppear {
            notesDraft = log?.notes ?? ""
        }
    }
}

#Preview {
    NavigationStack {
        BeerDetailView(beer: Catalog.bundled.beers[4])
    }
    .environment(BeersViewModel())
    .environment(BreweriesViewModel())
    .environment(AppRouter())
    .modelContainer(for: [BeerLog.self, BreweryLog.self], inMemory: true)
}

extension BeerDetailView {

    private var header: some View {
        HStack(spacing: 16) {
            BeerGlassView(beer: beer, height: 96)

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

    // The user's own record: tried, stars and notes
    private var journal: some View {
        VStack(alignment: .leading, spacing: 14) {
            Button {
                modelContext.updateLog(for: beer) { log in
                    if log.isTried {
                        // Stars only make sense for a beer you've tried
                        log.triedAt = nil
                        log.rating = nil
                    } else {
                        log.triedAt = .now
                    }
                }
            } label: {
                Label(triedTitle, systemImage: log?.isTried == true ? "checkmark.circle.fill" : "circle")
                    .font(.headline)
                    .foregroundStyle(log?.isTried == true ? Color.green : Color.primary)
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.plain)

            StarRating(rating: log?.rating) { rating in
                modelContext.updateLog(for: beer) { log in
                    log.rating = rating
                    if rating != nil && log.triedAt == nil {
                        log.triedAt = .now
                    }
                }
            }

            TextField("Οι σημειώσεις σου", text: $notesDraft, axis: .vertical)
                .lineLimit(2...6)
                .padding(10)
                .background(.background, in: .rect(cornerRadius: 10))
                .onChange(of: notesDraft) {
                    guard notesDraft != (log?.notes ?? "") else { return }
                    modelContext.updateLog(for: beer) { $0.notes = notesDraft }
                }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.quaternary.opacity(0.5), in: .rect(cornerRadius: 14))
    }

    private var triedTitle: String {
        guard let triedAt = log?.triedAt else { return "Το δοκίμασα" }
        return "Δοκιμάστηκε \(triedAt.formatted(date: .abbreviated, time: .omitted))"
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
