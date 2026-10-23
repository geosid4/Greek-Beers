//
//  BeersView.swift
//  Zythos
//

import SwiftData
import SwiftUI

// The Beers tab and the app's first screen: only beers, narrowed by search and filters
struct BeersView: View {

    @Environment(BeersViewModel.self) private var vm

    @State private var showsFilters = false

    var body: some View {
        @Bindable var vm = vm

        NavigationStack {
            // Search and the filter row sit above the scroll view, so they stay put while the list scrolls
            VStack(spacing: 0) {
                SearchField(prompt: "Μπύρα, στυλ ή ζυθοποιία", text: $vm.searchText)
                    .padding(.horizontal)
                    .padding(.top, 8)
                filterBar
                    .padding(.vertical, 8)

                ScrollView {
                    results
                }
                .scrollDismissesKeyboard(.immediately)
            }
            .background(Palette.background)
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
            .sheet(isPresented: $showsFilters) {
                FiltersView()
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

    // The filters button, the active style, region and ingredient filters as removable chips,
    // then every brewery as a toggle chip
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Button {
                    showsFilters = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "line.3.horizontal.decrease")
                        Text("Φίλτρα")
                        if vm.activeFilterCount > 0 {
                            Text("\(vm.activeFilterCount)")
                                .font(.caption.weight(.bold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 1)
                                .background(Palette.background, in: .capsule)
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 14)
                    .frame(height: 36)
                    .foregroundStyle(vm.activeFilterCount > 0 ? Palette.background : Color.primary)
                    .background(vm.activeFilterCount > 0 ? Color.accentColor : Palette.surface,
                                in: .capsule)
                }
                .buttonStyle(.plain)

                ForEach(StyleFamily.allCases.filter(vm.selectedFamilies.contains)) { family in
                    FilterToken(title: family.name) { vm.toggle(family) }
                }
                ForEach(Region.allCases.filter(vm.selectedRegions.contains)) { region in
                    FilterToken(title: region.name) { vm.toggle(region) }
                }
                if vm.localIngredientsOnly {
                    FilterToken(title: "Ελληνικά υλικά") { vm.localIngredientsOnly = false }
                }

                // Fixed alphabetical order, so chips don't move under the finger while picking several
                ForEach(vm.breweriesByName) { brewery in
                    Button {
                        withAnimation(.snappy) { vm.toggle(brewery) }
                    } label: {
                        BreweryChip(brewery: brewery, isSelected: vm.selectedBreweryIds.contains(brewery.id))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .animation(.snappy, value: vm.activeFilterCount)
        }
    }

    @ViewBuilder
    private var results: some View {
        let beers = vm.filteredBeers

        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("\(beers.count) \(beers.count == 1 ? "μπύρα" : "μπύρες")")
                    .font(.subheadline)
                    .foregroundStyle(Palette.muted)
                Spacer()
                if vm.activeFilterCount > 0 {
                    Button("Καθαρισμός φίλτρων") {
                        withAnimation(.snappy) { vm.clearFilters() }
                    }
                    .font(.subheadline)
                }
            }
            .padding(.horizontal)

            if beers.isEmpty {
                ContentUnavailableView {
                    Label("Καμία μπύρα", systemImage: "mug")
                } description: {
                    Text("Δοκίμασε άλλη αναζήτηση ή λιγότερα φίλτρα.")
                }
                .padding(.top, 40)
            } else {
                BeerCardList(beers: beers)
            }
        }
        .padding(.vertical)
    }
}

private struct BreweryChip: View {

    let brewery: Brewery
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 6) {
            BreweryLogoView(brewery: brewery, size: 24)
            Text(brewery.name)
                .lineLimit(1)
        }
        .font(.subheadline)
        .padding(.leading, 6)
        .padding(.trailing, 14)
        .frame(height: 36)
        .foregroundStyle(isSelected ? Palette.background : Color.primary)
        .background(isSelected ? Color.accentColor : Palette.surface, in: .capsule)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// An active filter, removed by tapping it
private struct FilterToken: View {

    let title: String
    let remove: () -> Void

    var body: some View {
        Button {
            withAnimation(.snappy) { remove() }
        } label: {
            HStack(spacing: 4) {
                Text(title)
                    .lineLimit(1)
                Image(systemName: "xmark")
                    .font(.caption2.weight(.bold))
            }
            .font(.subheadline)
            .padding(.horizontal, 12)
            .frame(height: 36)
            .foregroundStyle(Color.accentColor)
            .background(Color.accentColor.opacity(0.12), in: .capsule)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Αφαίρεση φίλτρου \(title)")
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
