//
//  BeersView.swift
//  Zythos
//

import SwiftUI

// The Beers tab: every beer in the catalog, grouped by style family
struct BeersView: View {

    @Environment(BeersViewModel.self) private var vm

    var body: some View {
        @Bindable var vm = vm

        NavigationStack {
            // Search and chips sit above the list rather than in it, so they stay put while it scrolls
            VStack(spacing: 0) {
                VStack(spacing: 4) {
                    SearchField(prompt: "Μπύρα, στυλ ή ζυθοποιία", text: $vm.searchText)
                        .padding(.horizontal)
                    filterBar
                }
                .padding(.top, 8)

                Divider()

                if vm.beersByFamily.isEmpty {
                    emptyState
                        .frame(maxHeight: .infinity)
                } else {
                    list
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Μπύρες")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    sortMenu
                }
            }
            .navigationDestination(for: Beer.self) { beer in
                BeerDetailView(beer: beer)
            }
        }
    }
}

#Preview {
    BeersView()
        .environment(BeersViewModel())
        .environment(BreweriesViewModel())
        .environment(AppRouter())
}

extension BeersView {

    private var list: some View {
        List {
            ForEach(vm.beersByFamily, id: \.family) { group in
                Section(group.family.name) {
                    ForEach(group.beers) { beer in
                        NavigationLink(value: beer) {
                            BeerRowView(beer: beer, breweryName: vm.brewery(for: beer)?.name)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollDismissesKeyboard(.immediately)
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("Καμία μπύρα", systemImage: "mug")
        } description: {
            Text("Δοκίμασε άλλη αναζήτηση ή λιγότερα φίλτρα.")
        } actions: {
            Button("Καθαρισμός φίλτρων", action: vm.clearFilters)
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(vm.availableFamilies) { family in
                    Button {
                        withAnimation(.snappy) {
                            vm.familyFilter = vm.familyFilter == family ? nil : family
                        }
                    } label: {
                        FilterChip(title: family.name, isActive: vm.familyFilter == family, showsMenuIndicator: false)
                    }
                }

                Button {
                    withAnimation(.snappy) { vm.localIngredientsOnly.toggle() }
                } label: {
                    FilterChip(title: "Ελληνικά υλικά", isActive: vm.localIngredientsOnly, showsMenuIndicator: false)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }

    private var sortMenu: some View {
        @Bindable var vm = vm

        return Menu {
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
