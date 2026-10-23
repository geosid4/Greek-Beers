//
//  BreweryPickerView.swift
//  Zythos
//

import SwiftUI

// Every brewery, searchable and grouped by region; pushed from the filters to pick several
struct BreweryPickerView: View {

    @Environment(BeersViewModel.self) private var vm

    @State private var query = ""

    var body: some View {
        List {
            Group {
                if query.isEmpty {
                    Button {
                        withAnimation(.snappy) { vm.selectedBreweryIds = [] }
                    } label: {
                        HStack {
                            Text("Όλες οι ζυθοποιίες")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            if vm.selectedBreweryIds.isEmpty {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.accentColor)
                            }
                        }
                        .foregroundStyle(Color.primary)
                    }
                }

                ForEach(groups, id: \.region) { region, breweries in
                    Section(region.name) {
                        ForEach(breweries) { brewery in
                            Button {
                                withAnimation(.snappy) { vm.toggle(brewery) }
                            } label: {
                                row(brewery)
                            }
                        }
                    }
                }
            }
            .listRowBackground(Palette.surface)
        }
        .appListBackground()
        .overlay {
            if groups.isEmpty {
                ContentUnavailableView.search(text: query)
            }
        }
        .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Ζυθοποιία ή πόλη")
        .navigationTitle(vm.selectedBreweryIds.isEmpty
                         ? "Ζυθοποιίες"
                         : "Επιλεγμένες: \(vm.selectedBreweryIds.count)")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        BreweryPickerView()
    }
    .environment(BeersViewModel())
}

extension BreweryPickerView {

    // Breweries matching the query, grouped by region in the order regions are declared
    private var groups: [(region: Region, breweries: [Brewery])] {
        let matching = vm.breweriesByName.filter { brewery in
            query.isEmpty || [brewery.name, brewery.city, brewery.region.name]
                .contains { $0.localizedStandardContains(query) }
        }
        let grouped = Dictionary(grouping: matching, by: \.region)
        return Region.allCases.compactMap { region in
            grouped[region].map { (region, $0) }
        }
    }

    private func row(_ brewery: Brewery) -> some View {
        let count = vm.beerCount(for: brewery)
        let isSelected = vm.selectedBreweryIds.contains(brewery.id)

        return HStack(spacing: 12) {
            BreweryLogoView(brewery: brewery, size: 40)
            VStack(alignment: .leading, spacing: 2) {
                Text(brewery.name)
                    .font(.headline)
                Text("\(brewery.city) · \(count) \(count == 1 ? "μπύρα" : "μπύρες")")
                    .font(.subheadline)
                    .foregroundStyle(Palette.muted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundStyle(isSelected ? Color.accentColor : Palette.muted)
        }
        .foregroundStyle(Color.primary)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
