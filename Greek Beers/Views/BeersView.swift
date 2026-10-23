//
//  BeersView.swift
//  Zythos
//

import SwiftData
import SwiftUI

// The Beers tab and the app's first screen: title, search and style chips stay put,
// then breweries to narrow by and every beer as a row
struct BeersView: View {

    @Environment(BeersViewModel.self) private var vm

    @State private var showsFilters = false

    var body: some View {
        @Bindable var vm = vm

        NavigationStack {
            VStack(spacing: 0) {
                header
                    .padding(.horizontal)
                    .padding(.top, 8)
                SearchField(prompt: "Μπύρα, στυλ ή ζυθοποιία", text: $vm.searchText)
                    .padding(.horizontal)
                    .padding(.top, 14)
                styleChips
                    .padding(.vertical, 12)

                ScrollView {
                    results
                }
                .scrollDismissesKeyboard(.immediately)
            }
            .background(Palette.background)
            .navigationTitle("Μπύρες")
            .toolbar(.hidden, for: .navigationBar)
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

    private var header: some View {
        HStack(alignment: .center, spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Μπύρες")
                    .font(.display(.largeTitle))
                    .accessibilityAddTraits(.isHeader)
                Text("\(vm.catalog.beers.count) μπύρες · \(vm.catalog.breweries.count) ζυθοποιίες")
                    .font(.footnote)
                    .foregroundStyle(Palette.muted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            SortMenu()

            Button {
                showsFilters = true
            } label: {
                Image(systemName: "line.3.horizontal.decrease")
                    .font(.body.weight(.semibold))
                    .frame(width: 44, height: 44)
                    .background(Palette.surface, in: .circle)
                    .overlay(alignment: .topTrailing) {
                        if vm.activeFilterCount > 0 {
                            Text("\(vm.activeFilterCount)")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(Palette.background)
                                .frame(minWidth: 18, minHeight: 18)
                                .background(Color.accentColor, in: .capsule)
                                .offset(x: 4, y: -2)
                        }
                    }
            }
            .buttonStyle(.plain)
            .accessibilityLabel(vm.activeFilterCount > 0 ? "Φίλτρα, \(vm.activeFilterCount) ενεργά" : "Φίλτρα")
        }
    }

    // "Όλες" and one chip per style family with its count; other active filters follow as
    // removable tokens so nothing filtering the list is hidden in the sheet
    private var styleChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Button {
                    withAnimation(.snappy) { vm.selectedFamilies = [] }
                } label: {
                    StyleChip(title: "Όλες", count: vm.catalog.beers.count, isSelected: vm.selectedFamilies.isEmpty)
                }
                .buttonStyle(.plain)

                ForEach(vm.families, id: \.family) { family, count in
                    Button {
                        withAnimation(.snappy) { vm.toggle(family) }
                    } label: {
                        StyleChip(title: family.name, count: count, isSelected: vm.selectedFamilies.contains(family))
                    }
                    .buttonStyle(.plain)
                }

                ForEach(vm.selectedBreweries) { brewery in
                    FilterToken(title: brewery.name) { vm.toggle(brewery) }
                }
                ForEach(BeerTag.allCases.filter(vm.selectedTags.contains)) { tag in
                    FilterToken(title: tag.name) { vm.toggle(tag) }
                }
                ForEach(Region.allCases.filter(vm.selectedRegions.contains)) { region in
                    FilterToken(title: region.name) { vm.toggle(region) }
                }
                if vm.localIngredientsOnly {
                    FilterToken(title: "Ελληνικά υλικά") { vm.localIngredientsOnly = false }
                }
            }
            .padding(.horizontal)
        }
    }

    @ViewBuilder
    private var results: some View {
        let beers = vm.filteredBeers
        let isNarrowed = vm.activeFilterCount > 0 || !vm.searchText.isEmpty

        VStack(alignment: .leading, spacing: 22) {
            if vm.searchText.isEmpty {
                breweries
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    SectionLabel(isNarrowed ? "\(beers.count) \(beers.count == 1 ? "μπύρα" : "μπύρες")" : "Όλες οι μπύρες")
                    Spacer()
                    if vm.activeFilterCount > 0 {
                        Button("Καθαρισμός") {
                            withAnimation(.snappy) { vm.clearFilters() }
                        }
                        .font(.subheadline)
                    }
                }

                if beers.isEmpty {
                    ContentUnavailableView {
                        Label("Καμία μπύρα", systemImage: "mug")
                    } description: {
                        Text("Δοκίμασε άλλη αναζήτηση ή λιγότερα φίλτρα.")
                    }
                    .padding(.top, 40)
                } else {
                    BeerList(beers: beers)
                }
            }
            .padding(.horizontal)
        }
        .padding(.top, 8)
        .padding(.bottom)
    }

    // Each brewery as a card that narrows the list to its beers; tapping again lets go
    private var breweries: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel("Ανά ζυθοποιία")
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(vm.breweriesByName) { brewery in
                        Button {
                            withAnimation(.snappy) { vm.toggle(brewery) }
                        } label: {
                            BreweryCard(brewery: brewery, count: vm.beerCount(for: brewery),
                                        isSelected: vm.selectedBreweryIds.contains(brewery.id))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// Small capitals above a section, as in the design
struct SectionLabel: View {

    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Text(title)
            .font(.label)
            .textCase(.uppercase)
            .tracking(1.5)
            .foregroundStyle(Palette.muted)
            .accessibilityAddTraits(.isHeader)
    }
}

private struct StyleChip: View {

    let title: String
    let count: Int
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 6) {
            Text(title)
                .lineLimit(1)
            Text("\(count)")
                .font(.caption.monospacedDigit())
                .foregroundStyle(isSelected ? Palette.background.opacity(0.75) : Palette.muted)
        }
        .font(.subheadline.weight(.semibold))
        .padding(.horizontal, 14)
        .frame(height: 36)
        .foregroundStyle(isSelected ? Palette.background : Color.primary)
        .background(isSelected ? Color.accentColor : Palette.surface, in: .capsule)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private struct BreweryCard: View {

    let brewery: Brewery
    let count: Int
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            BreweryLogoView(brewery: brewery, size: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(brewery.name)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                Text("\(brewery.city) · \(count)")
                    .font(.caption)
                    .foregroundStyle(Palette.muted)
                    .lineLimit(1)
            }
        }
        .frame(width: 112, alignment: .leading)
        .padding(12)
        .background(Palette.surface, in: .rect(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.accentColor, lineWidth: isSelected ? 2 : 0)
        }
        .accessibilityElement(children: .combine)
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
            Image(systemName: "arrow.up.arrow.down")
                .font(.body.weight(.semibold))
                .foregroundStyle(Color.primary)
                .frame(width: 44, height: 44)
                .background(Palette.surface, in: .circle)
        }
        .accessibilityLabel("Ταξινόμηση")
    }
}
