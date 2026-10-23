//
//  BeerCardView.swift
//  Zythos
//

import SwiftData
import SwiftUI

// A beer as a card: glass, name, brewery and ABV, with the user's stars when there are some
struct BeerCardView: View {

    let beer: Beer
    let brewery: Brewery?
    var brand: Brand? = nil
    var isTried = false
    var rating: Int? = nil

    var body: some View {
        HStack(spacing: 14) {
            BeerGlassView(beer: beer, height: 64)
                .padding(.leading, 4)

            VStack(alignment: .leading, spacing: 6) {
                Text(beer.name)
                    .font(.headline)
                    .lineLimit(2)

                if let brewery {
                    HStack(spacing: 6) {
                        BreweryLogoView(brewery: brewery, size: 20)
                        // "VOREIA · Siris Craft Brewery" when the beer belongs to a brand
                        Text([brand?.name, brewery.name].compactMap { $0 }.joined(separator: " · "))
                            .lineLimit(1)
                    }
                    .font(.subheadline)
                    .foregroundStyle(Palette.muted)
                }

                HStack(spacing: 6) {
                    Badge(text: beer.style)
                    if let abv = beer.formattedABV {
                        Badge(text: abv)
                    }
                    if !beer.localIngredients.isEmpty {
                        Image(systemName: "leaf.fill")
                            .font(.caption)
                            .foregroundStyle(.green)
                            .accessibilityLabel("Ελληνικά υλικά")
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if let rating {
                StarsLabel(rating: rating)
            } else if isTried {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.accentColor)
                    .accessibilityLabel("Δοκιμασμένη")
            }
        }
        .padding(12)
        .background(Palette.surface, in: .rect(cornerRadius: 18))
        .contentShape(.rect(cornerRadius: 18))
        .accessibilityElement(children: .combine)
    }
}

// Beers as tappable cards, marked with what the user has tried
struct BeerCardList: View {

    @Environment(BeersViewModel.self) private var vm
    @Query private var logs: [BeerLog]

    let beers: [Beer]

    var body: some View {
        LazyVStack(spacing: 10) {
            ForEach(beers) { beer in
                let log = logs.first { $0.beerId == beer.id }
                NavigationLink(value: beer) {
                    BeerCardView(beer: beer, brewery: vm.brewery(for: beer), brand: vm.brand(for: beer),
                                 isTried: log?.isTried == true, rating: log?.rating)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
    }
}

struct Badge: View {

    let text: String

    var body: some View {
        Text(text)
            .font(.caption)
            .lineLimit(1)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Color.secondary.opacity(0.12), in: .capsule)
    }
}

#Preview {
    let catalog = Catalog.bundled
    return ScrollView {
        VStack(spacing: 10) {
            ForEach(catalog.beers) { beer in
                BeerCardView(beer: beer, brewery: catalog.breweries.first { $0.id == beer.breweryId },
                             isTried: true, rating: 4)
            }
        }
        .padding()
    }
    .background(Palette.background)
}
