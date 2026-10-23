//
//  BreweriesListView.swift
//  Zythos
//
//  Created by George Sidiropoulos on 12/7/23.
//


import SwiftUI

// The sheet's list state: search and filters in the header, breweries grouped by region below
struct BreweriesListView: View {

    @Environment(BreweriesViewModel.self) private var vm

    var body: some View {
        if vm.filteredBreweries.isEmpty {
            emptyState
        } else {
            list
        }
    }
}

#Preview {
    VStack {
        BreweriesListView.Header()
        BreweriesListView()
    }
    .environment(BreweriesViewModel())
}

extension BreweriesListView {

    private var list: some View {
        List {
            ForEach(vm.breweriesByRegion, id: \.region) { group in
                Section(group.region.name) {
                    ForEach(group.breweries) { brewery in
                        Button {
                            vm.select(brewery)
                        } label: {
                            row(brewery: brewery)
                        }
                        .listRowBackground(Color.clear)
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .scrollDismissesKeyboard(.immediately)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Text("Καμία ζυθοποιία")
                .font(.headline)
            Text("Δοκίμασε άλλη αναζήτηση ή λιγότερα φίλτρα.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button("Καθαρισμός φίλτρων", action: vm.clearFilters)
                .font(.subheadline)
        }
        .multilineTextAlignment(.center)
        .padding()
        .frame(maxWidth: .infinity)
    }

    private func row(brewery: Brewery) -> some View {
        let beerCount = vm.catalog.beers(for: brewery).count

        return HStack(spacing: 12) {
            BreweryLogoView(brewery: brewery, size: 44)
            VStack(alignment: .leading, spacing: 2) {
                Text(brewery.name)
                    .font(.headline)
                Text("\(brewery.city) · \(beerCount) \(beerCount == 1 ? "μπύρα" : "μπύρες")")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Image(systemName: "chevron.right")
                .font(.footnote)
                .foregroundStyle(.tertiary)
        }
        .foregroundStyle(Color.primary)
        .contentShape(.rect)
    }
}

extension BreweriesListView {

    // Stays visible when the sheet is collapsed, so search is always one tap away
    struct Header: View {

        @Environment(BreweriesViewModel.self) private var vm
        @FocusState private var searchFocused: Bool

        var body: some View {
            VStack(spacing: 10) {
                searchField
                filterBar
            }
            .padding(.bottom, 10)
            .onChange(of: searchFocused) { _, focused in
                if focused {
                    withAnimation(.snappy) { vm.sheetDetent = .large }
                }
            }
        }

        private var searchField: some View {
            @Bindable var vm = vm

            return SearchField(prompt: "Ζυθοποιία, πόλη ή μπύρα", text: $vm.searchText)
                .focused($searchFocused)
                .padding(.horizontal)
        }

        private var filterBar: some View {
            @Bindable var vm = vm

            return ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    Menu {
                        Picker("Περιφέρεια", selection: $vm.regionFilter) {
                            Text("Όλες οι περιφέρειες").tag(Region?.none)
                            ForEach(vm.availableRegions) { region in
                                Text(region.name).tag(Region?.some(region))
                            }
                        }
                    } label: {
                        FilterChip(title: vm.regionFilter?.name ?? "Περιφέρεια",
                                   isActive: vm.regionFilter != nil,
                                   showsMenuIndicator: true)
                    }

                    Menu {
                        Picker("Τύπος", selection: $vm.kindFilter) {
                            Text("Όλοι οι τύποι").tag(Brewery.Kind?.none)
                            ForEach(vm.availableKinds) { kind in
                                Text(kind.name).tag(Brewery.Kind?.some(kind))
                            }
                        }
                    } label: {
                        FilterChip(title: vm.kindFilter?.name ?? "Τύπος",
                                   isActive: vm.kindFilter != nil,
                                   showsMenuIndicator: true)
                    }

                    Button {
                        vm.visitableOnly.toggle()
                    } label: {
                        FilterChip(title: "Επισκέψιμες", isActive: vm.visitableOnly, showsMenuIndicator: false)
                    }

                    if vm.isFiltering {
                        Button("Καθαρισμός", action: vm.clearFilters)
                            .font(.subheadline)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
