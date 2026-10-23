//
//  BeersView.swift
//  Zythos
//

import SwiftData
import SwiftUI

// The Beers tab and the app's first screen: browse by style, local ingredients and region,
// or search everything
struct BeersView: View {

    @Environment(BeersViewModel.self) private var vm

    var body: some View {
        @Bindable var vm = vm

        NavigationStack {
            // The search box sits above the scroll view, so it stays put while the page scrolls
            VStack(spacing: 0) {
                SearchField(prompt: "Μπύρα, στυλ ή ζυθοποιία", text: $vm.searchText)
                    .padding(.horizontal)
                    .padding(.vertical, 8)

                ScrollView {
                    if vm.isSearching {
                        searchResults
                    } else {
                        browse
                    }
                }
                .scrollDismissesKeyboard(.immediately)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Μπύρες")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    SortMenu()
                }
            }
            .navigationDestination(for: Beer.self) { beer in
                BeerDetailView(beer: beer)
            }
            .navigationDestination(for: BeerCollection.self) { collection in
                BeerCollectionView(collection: collection)
            }
        }
    }
}

#Preview {
    BeersView()
        .environment(BeersViewModel())
        .environment(BreweriesViewModel())
        .environment(AppRouter())
        .modelContainer(for: [BeerLog.self, BreweryLog.self], inMemory: true)
}

extension BeersView {

    private var browse: some View {
        LazyVStack(alignment: .leading, spacing: 28) {
            section("Στυλ") {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                          spacing: 12) {
                    ForEach(vm.families, id: \.family) { family, count in
                        NavigationLink(value: BeerCollection.family(family)) {
                            StyleTile(family: family, count: count)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }

            if !vm.beersWithLocalIngredients.isEmpty {
                section("Με ελληνικά υλικά", seeAll: .localIngredients) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(vm.beersWithLocalIngredients) { beer in
                                NavigationLink(value: beer) {
                                    LocalBeerCardView(beer: beer, brewery: vm.brewery(for: beer))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }

            section("Ανά περιφέρεια") {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(vm.regions, id: \.region) { region, count in
                            NavigationLink(value: BeerCollection.region(region)) {
                                RegionChip(region: region, count: count)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
            }

            section("Όλες οι μπύρες") {
                BeerCardList(beers: vm.allBeers)
            }
        }
        .padding(.vertical)
    }

    @ViewBuilder
    private var searchResults: some View {
        let results = vm.searchResults
        if results.isEmpty {
            ContentUnavailableView.search(text: vm.searchText)
                .padding(.top, 60)
        } else {
            BeerCardList(beers: results)
                .padding(.vertical)
        }
    }

    private func section(_ title: String, seeAll collection: BeerCollection? = nil,
                         @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                if let collection {
                    NavigationLink("Όλες", value: collection)
                        .font(.subheadline)
                }
            }
            .padding(.horizontal)

            content()
        }
    }
}

// A style family as a coloured tile with its glass
private struct StyleTile: View {

    let family: StyleFamily
    let count: Int

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 4) {
                Text(family.name)
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2, reservesSpace: true)
                Text("\(count) \(count == 1 ? "μπύρα" : "μπύρες")")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            BeerGlassView(color: family.displayColor, height: 52)
        }
        .padding(14)
        .background(family.displayColor.opacity(0.18), in: .rect(cornerRadius: 18))
        .contentShape(.rect(cornerRadius: 18))
        .accessibilityElement(children: .combine)
    }
}

private struct RegionChip: View {

    let region: Region
    let count: Int

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "mappin.and.ellipse")
                .foregroundStyle(Color.accentColor)
            Text(region.name)
            Text("\(count)")
                .foregroundStyle(.secondary)
        }
        .font(.subheadline)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color(.secondarySystemGroupedBackground), in: .capsule)
    }
}

struct SortMenu: View {

    @Environment(BeersViewModel.self) private var vm

    var body: some View {
        @Bindable var vm = vm

        Menu {
            Picker("Ταξινόμηση", selection: $vm.sortOrder) {
                ForEach(BeersViewModel.SortOrder.allCases) { order in
                    Text(order.rawValue).tag(order)
                }
            }
        } label: {
            Label("Ταξινόμηση", systemImage: "arrow.up.arrow.down")
        }
    }
}
