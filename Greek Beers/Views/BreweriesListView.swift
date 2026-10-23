//
//  BreweriesListView.swift
//  Zythos
//
//  Created by George Sidiropoulos on 12/7/23.
//


import SwiftUI

struct BreweriesListView: View {

    @Environment(BreweriesViewModel.self) private var vm

    var body: some View {
        VStack(spacing: 8) {
            searchField
            filterBar

            if vm.filteredBreweries.isEmpty {
                emptyState
            } else {
                list
            }
        }
        .padding(.top, 4)
    }
}

#Preview {
    BreweriesListView()
        .environment(BreweriesViewModel())
}

extension BreweriesListView {

    private var searchField: some View {
        @Bindable var vm = vm

        return HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("Ζυθοποιία, πόλη ή μπύρα", text: $vm.searchText)
                .autocorrectionDisabled()
                .submitLabel(.search)
            if !vm.searchText.isEmpty {
                Button {
                    vm.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .accessibilityLabel("Καθαρισμός αναζήτησης")
            }
        }
        .padding(10)
        .background(.quaternary, in: .rect(cornerRadius: 10))
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
                    filterChip(vm.regionFilter?.name ?? "Περιφέρεια",
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
                    filterChip(vm.kindFilter?.name ?? "Τύπος",
                               isActive: vm.kindFilter != nil,
                               showsMenuIndicator: true)
                }

                Button {
                    vm.visitableOnly.toggle()
                } label: {
                    filterChip("Επισκέψιμες", isActive: vm.visitableOnly, showsMenuIndicator: false)
                }

                if vm.isFiltering {
                    Button("Καθαρισμός", action: vm.clearFilters)
                        .font(.subheadline)
                }
            }
            .padding(.horizontal)
        }
    }

    private func filterChip(_ title: String, isActive: Bool, showsMenuIndicator: Bool) -> some View {
        HStack(spacing: 4) {
            Text(title)
            if showsMenuIndicator {
                Image(systemName: "chevron.down")
                    .font(.caption2)
            }
        }
        .font(.subheadline)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .foregroundStyle(isActive ? Color.white : Color.primary)
        .background(isActive ? Color.accentColor : Color.secondary.opacity(0.15), in: .capsule)
    }

    private var list: some View {
        List {
            ForEach(vm.breweriesByRegion, id: \.region) { group in
                Section(group.region.name) {
                    ForEach(group.breweries) { brewery in
                        Button {
                            vm.show(brewery)
                        } label: {
                            listRowView(brewery: brewery)
                        }
                        .padding(.vertical, 4)
                        .listRowBackground(Color.clear)
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .scrollDismissesKeyboard(.immediately)
        .frame(maxHeight: 400)
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

    private func listRowView(brewery: Brewery) -> some View {
        HStack {
            if let imageName = brewery.imageNames.first {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .padding(3)
                    .frame(width: 45, height: 45)
                    .background(Color.white, in: .rect(cornerRadius: 10))
            }
            VStack(alignment: .leading) {
                Text(brewery.name)
                    .font(.headline)
                Text("\(brewery.city) · \(brewery.kind.name)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .foregroundStyle(Color.primary)
    }
}
