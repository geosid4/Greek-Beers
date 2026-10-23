//
//  JourneyView.swift
//  Zythos
//

import SwiftData
import SwiftUI

// The Passport tab: what the user has tried and where they have been, with stamps,
// achievements and the beers and breweries they saved
struct JourneyView: View {

    @Environment(BeersViewModel.self) private var beersVM
    @Environment(BreweriesViewModel.self) private var breweriesVM
    @Environment(AppRouter.self) private var router
    @Query private var beerLogs: [BeerLog]
    @Query private var breweryLogs: [BreweryLog]

    var body: some View {
        NavigationStack {
            List {
                Group {
                    Section {
                        summary
                    }

                    Section {
                        stamps
                    } header: {
                        Text("Σφραγίδες")
                    } footer: {
                        Text("Σφράγισε μια επίσκεψη από τη σελίδα της ζυθοποιίας στον χάρτη.")
                    }

                    Section("Επιτεύγματα") {
                        ForEach(achievements) { achievement in
                            AchievementRow(achievement: achievement)
                        }
                    }

                    if !favoriteBeers.isEmpty {
                        Section("Αγαπημένες μπύρες") {
                            ForEach(favoriteBeers) { beer in
                                NavigationLink(value: beer) {
                                    beerRow(beer)
                                }
                            }
                        }
                    }

                    if !favoriteBreweries.isEmpty {
                        Section("Αγαπημένες ζυθοποιίες") {
                            ForEach(favoriteBreweries) { brewery in
                                Button {
                                    router.showOnMap(brewery, using: breweriesVM)
                                } label: {
                                    HStack(spacing: 12) {
                                        BreweryLogoView(brewery: brewery, size: 40)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(brewery.name)
                                                .font(.headline)
                                            Text(brewery.city)
                                                .font(.subheadline)
                                                .foregroundStyle(Palette.muted)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        Image(systemName: "map")
                                            .foregroundStyle(Color.accentColor)
                                    }
                                    .foregroundStyle(Color.primary)
                                }
                            }
                        }
                    }

                    Section("Δοκίμασες") {
                        if tried.isEmpty {
                            firstBeerHint
                        } else {
                            ForEach(tried, id: \.beer.id) { beer, _ in
                                NavigationLink(value: beer) {
                                    beerRow(beer)
                                }
                            }
                        }
                    }
                }
                .listRowBackground(Palette.surface)
            }
            .listStyle(.insetGrouped)
            .appListBackground()
            .navigationTitle("Διαβατήριο")
            .navigationDestination(for: Beer.self) { beer in
                BeerDetailView(beer: beer)
            }
        }
    }
}

#Preview {
    JourneyView()
        .environment(BeersViewModel())
        .environment(BreweriesViewModel())
        .environment(AppRouter())
        .modelContainer(for: [BeerLog.self, BreweryLog.self], inMemory: true)
}

extension JourneyView {

    private var catalog: Catalog { beersVM.catalog }

    // Logs are joined to the catalog by id; logs for beers no longer in the catalog are skipped
    private var tried: [(beer: Beer, log: BeerLog)] {
        beerLogs
            .filter(\.isTried)
            .compactMap { log in catalog.beers.first { $0.id == log.beerId }.map { ($0, log) } }
            .sorted { ($0.log.triedAt ?? .distantPast) > ($1.log.triedAt ?? .distantPast) }
    }

    private var visitedIds: Set<String> {
        Set(breweryLogs.filter(\.isVisited).map(\.breweryId))
    }

    private var visitableBreweries: [Brewery] {
        catalog.breweries.filter(\.canBeVisited)
    }

    private var favoriteBeers: [Beer] {
        let ids = Set(beerLogs.filter(\.isFavorite).map(\.beerId))
        return catalog.beers.filter { ids.contains($0.id) }
    }

    private var favoriteBreweries: [Brewery] {
        let ids = Set(breweryLogs.filter(\.isFavorite).map(\.breweryId))
        return catalog.breweries.filter { ids.contains($0.id) }
    }

    private func beerRow(_ beer: Beer) -> some View {
        let log = beerLogs.first { $0.beerId == beer.id }
        return BeerRowView(beer: beer, breweryName: beersVM.brewery(for: beer)?.name,
                           isTried: log?.isTried == true, rating: log?.rating)
    }

    // How much of the catalog the user has covered: a ring for the beers, then visits and styles
    private var summary: some View {
        let triedBeers = tried.map(\.beer)
        let families = Set(triedBeers.map(\.styleFamily))
        let progress = catalog.beers.isEmpty ? 0 : Double(triedBeers.count) / Double(catalog.beers.count)

        return HStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Palette.background, lineWidth: 10)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                VStack(spacing: 0) {
                    Text("\(triedBeers.count)")
                        .font(.title.monospacedDigit())
                        .fontWeight(.bold)
                    Text("από \(catalog.beers.count)")
                        .font(.caption)
                        .foregroundStyle(Palette.muted)
                }
            }
            .frame(width: 104, height: 104)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Δοκίμασες \(triedBeers.count) από \(catalog.beers.count) μπύρες")

            VStack(alignment: .leading, spacing: 10) {
                stat(triedBeers.count == 1 ? "1 μπύρα" : "\(triedBeers.count) μπύρες",
                     label: triedBeers.count == 1 ? "δοκιμασμένη" : "δοκιμασμένες")
                stat("\(visitedIds.count) / \(visitableBreweries.count)", label: "ζυθοποιίες επισκέφθηκες")
                stat("\(families.count) / \(StyleFamily.allCases.count)", label: "οικογένειες στυλ")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 8)
    }

    private func stat(_ value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(value)
                .font(.headline.monospacedDigit())
                .foregroundStyle(Color.accentColor)
            Text(label)
                .font(.caption)
                .foregroundStyle(Palette.muted)
        }
        .accessibilityElement(children: .combine)
    }

    // One stamp per brewery that can be visited, with how many of its beers the user has tried
    private var stamps: some View {
        let triedIds = Set(tried.map(\.beer.id))

        return LazyVGrid(columns: [GridItem(.adaptive(minimum: 76), spacing: 8)], spacing: 16) {
            ForEach(visitableBreweries) { brewery in
                let beers = catalog.beers(for: brewery)
                Button {
                    router.showOnMap(brewery, using: breweriesVM)
                } label: {
                    VStack(spacing: 6) {
                        PassportStamp(brewery: brewery, isVisited: visitedIds.contains(brewery.id), size: 60)
                        Text(brewery.name)
                            .font(.caption.weight(.semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        Text("\(beers.filter { triedIds.contains($0.id) }.count)/\(beers.count)")
                            .font(.caption2.monospacedDigit())
                            .foregroundStyle(Palette.muted)
                    }
                    .foregroundStyle(Color.primary)
                }
                .buttonStyle(.borderless)
            }
        }
        .padding(.vertical, 8)
    }

    private var achievements: [Achievement] {
        let triedBeers = tried.map(\.beer)
        let breweriesTasted = Set(triedBeers.map(\.breweryId))
        return [
            Achievement(id: "first-sip", title: "Πρώτη γουλιά", detail: "Δοκίμασε την πρώτη σου μπύρα",
                        symbol: "mug.fill", current: triedBeers.count, goal: 1),
            Achievement(id: "local-taste", title: "Τοπική γεύση", detail: "Μπύρα με ελληνικά υλικά",
                        symbol: "leaf.fill", current: triedBeers.filter { !$0.localIngredients.isEmpty }.count, goal: 1),
            Achievement(id: "dark-side", title: "Σκοτεινή πλευρά", detail: "3 stout ή porter",
                        symbol: "moon.fill", current: triedBeers.filter { $0.styleFamily == .dark }.count, goal: 3),
            Achievement(id: "end-to-end", title: "Από άκρη σε άκρη", detail: "Μπύρα από κάθε ζυθοποιία",
                        symbol: "map.fill", current: breweriesTasted.count, goal: catalog.breweries.count),
            Achievement(id: "traveller", title: "Ταξιδευτής", detail: "Επισκέψου 3 ζυθοποιίες",
                        symbol: "figure.walk", current: visitedIds.count, goal: min(3, visitableBreweries.count))
        ]
    }

    private var firstBeerHint: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Άνοιξε μια μπύρα και πάτα «Το δοκίμασα»: θα εμφανιστεί εδώ και θα μετρήσει στα επιτεύγματα.")
                .font(.subheadline)
                .foregroundStyle(Palette.muted)
            Button("Δες τις μπύρες") {
                router.tab = .beers
            }
            .buttonStyle(.borderedProminent)
            .foregroundStyle(Palette.background)
        }
        .padding(.vertical, 4)
    }
}

// A goal in the Passport, worked out from the user's logs each time; nothing about it is stored
struct Achievement: Identifiable {
    let id: String
    let title: String
    let detail: String
    let symbol: String
    let current: Int
    let goal: Int

    var isUnlocked: Bool { current >= goal }
}

private struct AchievementRow: View {

    let achievement: Achievement

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: achievement.symbol)
                .font(.title3)
                .foregroundStyle(achievement.isUnlocked ? Palette.background : Palette.muted)
                .frame(width: 44, height: 44)
                .background(achievement.isUnlocked ? Color.accentColor : Palette.background,
                            in: .rect(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(achievement.title)
                        .font(.headline)
                    Spacer()
                    Text("\(min(achievement.current, achievement.goal))/\(achievement.goal)")
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(Color.accentColor)
                }
                Text(achievement.detail)
                    .font(.subheadline)
                    .foregroundStyle(Palette.muted)
                ProgressView(value: Double(min(achievement.current, achievement.goal)), total: Double(max(achievement.goal, 1)))
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}
