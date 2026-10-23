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
                hero
                title
                stats
                if let description = beer.displayDescription {
                    Text(description)
                        .font(.body)
                        .foregroundStyle(Palette.muted)
                }
                journal
                facts
                if !sameBreweryBeers.isEmpty {
                    sameBrewery
                }
                dataNotice
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .navigationTitle(beer.name)
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
        .background(Palette.background)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: shareText) {
                    Image(systemName: "square.and.arrow.up")
                }
                .accessibilityLabel("Κοινοποίηση")
            }
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

    private var brewery: Brewery? { vm.brewery(for: beer) }

    // The glass large on its own panel, with the beer's Greek ingredients called out
    private var hero: some View {
        BeerGlassView(beer: beer, height: 170)
            .frame(maxWidth: .infinity)
            .frame(height: 240)
            .background(Palette.surface, in: .rect(cornerRadius: 28))
            .overlay(alignment: .bottomLeading) {
                if !beer.localIngredients.isEmpty {
                    Label("Τοπικό υλικό: \(beer.localIngredients.joined(separator: ", "))", systemImage: "leaf.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.green)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Palette.background, in: .capsule)
                        .padding(14)
                }
            }
    }

    private var title: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(beer.style)
                .font(.label)
                .textCase(.uppercase)
                .tracking(1.5)
                .foregroundStyle(Palette.muted)
            Text(beer.name)
                .font(.display(.largeTitle))
            if let brewery {
                Button {
                    router.showOnMap(brewery, using: breweriesVM)
                } label: {
                    Text("\([vm.brand(for: beer)?.name, brewery.name, brewery.city].compactMap { $0 }.joined(separator: " · ")) \(Image(systemName: "chevron.right"))")
                        .font(.subheadline.weight(.semibold))
                }
                .buttonStyle(.plain)
                .foregroundStyle(Color.accentColor)
                .accessibilityHint("Δες τη ζυθοποιία στον χάρτη")
            }
        }
    }

    // ABV, IBU and colour as tiles, leaving out whatever we don't know
    @ViewBuilder
    private var stats: some View {
        let abv = beer.abvPercent
        let ibu = beer.formattedIBU.map { $0.replacingOccurrences(of: " IBU", with: "") }

        if abv != nil || ibu != nil || beer.color != nil {
            HStack(spacing: 8) {
                if let abv {
                    statTile("Αλκοόλ") {
                        Text(abv)
                    }
                }
                if let ibu {
                    statTile("Πικράδα (IBU)") {
                        Text(ibu)
                    }
                }
                if let color = beer.color {
                    statTile("Χρώμα") {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(beer.displayColor)
                                .frame(width: 12, height: 12)
                            Text(color.name)
                                .font(.headline)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                    }
                }
            }
        }
    }

    private func statTile(_ label: String, @ViewBuilder value: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(Palette.muted)
            value()
                .font(.title3.monospacedDigit())
                .foregroundStyle(Color.accentColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Palette.surface, in: .rect(cornerRadius: 16))
        .accessibilityElement(children: .combine)
    }

    private var shareText: String {
        let from = brewery.map { " της \($0.name)" } ?? ""
        return "\(beer.name)\(from) (\(beer.style)) στο Zythos, τον οδηγό της ελληνικής μπύρας"
    }

    private var sameBreweryBeers: [Beer] {
        guard let brewery else { return [] }
        return vm.catalog.beers(for: brewery).filter { $0.id != beer.id }
    }

    private var sameBrewery: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Από την ίδια ζυθοποιία")
                .font(.label)
                .textCase(.uppercase)
                .tracking(1.5)
                .foregroundStyle(Palette.muted)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(sameBreweryBeers) { other in
                        NavigationLink(value: other) {
                            VStack(alignment: .leading, spacing: 6) {
                                BeerGlassView(beer: other, height: 34)
                                Text(other.name)
                                    .font(.subheadline.weight(.semibold))
                                    .lineLimit(2, reservesSpace: true)
                                    .multilineTextAlignment(.leading)
                                Text(other.abvPercent ?? other.style)
                                    .font(.footnote.monospacedDigit())
                                    .foregroundStyle(Color.accentColor)
                                    .lineLimit(1)
                            }
                            .frame(width: 140, alignment: .leading)
                            .padding(12)
                            .background(Palette.surface, in: .rect(cornerRadius: 16))
                            .foregroundStyle(Color.primary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .scrollClipDisabled()
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
                    .foregroundStyle(log?.isTried == true ? Color.accentColor : Color.primary)
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
                .background(Palette.background, in: .rect(cornerRadius: 10))
                .onChange(of: notesDraft) {
                    guard notesDraft != (log?.notes ?? "") else { return }
                    modelContext.updateLog(for: beer) { $0.notes = notesDraft }
                }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.surface, in: .rect(cornerRadius: 14))
    }

    private var triedTitle: String {
        guard let triedAt = log?.triedAt else { return "Το δοκίμασα" }
        return "Δοκιμάστηκε \(triedAt.formatted(date: .abbreviated, time: .omitted))"
    }

    // The rest of what we know, below the tiles; nothing is shown as "unknown"
    private var facts: some View {
        let rows: [(String, String)] = [
            ("Οικογένεια", beer.styleFamily.name),
            // Unfiltered has its own row, and low alcohol shows in the ABV tile
            ("Χαρακτηριστικά", beer.tags.isEmpty ? nil : beer.tags.map(\.name).joined(separator: ", ")),
            ("Φιλτράρισμα", beer.filtered.map { $0 ? "Φιλτραρισμένη" : "Αφιλτράριστη" })
        ].compactMap { label, value in value.map { (label, $0) } }

        return VStack(spacing: 0) {
            ForEach(rows, id: \.0) { label, value in
                HStack {
                    Text(label)
                        .foregroundStyle(Palette.muted)
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
            .foregroundStyle(Palette.muted)
        } else {
            Label("Τα στοιχεία δεν έχουν επιβεβαιωθεί ακόμα.", systemImage: "exclamationmark.circle")
                .font(.footnote)
                .foregroundStyle(Palette.muted)
        }
    }
}
