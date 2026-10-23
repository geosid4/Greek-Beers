//
//  FiltersView.swift
//  Zythos
//

import SwiftUI

// Every filter for the Beers tab in one place. Choices apply as they are made
struct FiltersView: View {

    @Environment(BeersViewModel.self) private var vm
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        @Bindable var vm = vm

        NavigationStack {
            List {
                Group {
                    Section {
                        NavigationLink {
                            BreweryPickerView()
                        } label: {
                            LabeledContent("Ζυθοποιίες", value: brewerySummary)
                        }
                    }

                    Section("Στυλ") {
                        ForEach(vm.families, id: \.family) { family, count in
                            checkRow(family.name, count: count, isOn: vm.selectedFamilies.contains(family)) {
                                BeerGlassView(color: family.displayColor, height: 26)
                            } toggle: {
                                vm.toggle(family)
                            }
                        }
                    }

                    Section("Περιφέρεια") {
                        ForEach(vm.regions, id: \.region) { region, count in
                            checkRow(region.name, count: count, isOn: vm.selectedRegions.contains(region)) {
                                Image(systemName: "mappin.and.ellipse")
                                    .foregroundStyle(Color.accentColor)
                            } toggle: {
                                vm.toggle(region)
                            }
                        }
                    }

                    Section {
                        Toggle(isOn: $vm.localIngredientsOnly) {
                            Label("Μόνο με ελληνικά υλικά", systemImage: "leaf.fill")
                        }
                    } footer: {
                        Text("Μαστίχα Χίου, βύνη Θράκης, ελληνικό κριθάρι και ό,τι άλλο δηλώνει η ζυθοποιία.")
                    }
                }
                .listRowBackground(Palette.surface)
            }
            .appListBackground()
            .navigationTitle("Φίλτρα")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Καθαρισμός") {
                        withAnimation(.snappy) { vm.clearFilters() }
                    }
                    .disabled(vm.activeFilterCount == 0)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Τέλος") { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button {
                    dismiss()
                } label: {
                    Text(showResultsTitle)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .foregroundStyle(Palette.background)
                .controlSize(.large)
                .padding()
                .background(Palette.background)
            }
        }
    }
}

#Preview {
    FiltersView()
        .environment(BeersViewModel())
}

extension FiltersView {

    private var brewerySummary: String {
        let selected = vm.selectedBreweries
        switch selected.count {
        case 0: return "Όλες"
        case 1: return selected[0].name
        default: return "\(selected.count) επιλεγμένες"
        }
    }

    private var showResultsTitle: String {
        let count = vm.filteredBeers.count
        return "Εμφάνιση \(count) \(count == 1 ? "μπύρας" : "μπυρών")"
    }

    private func checkRow(_ title: String, count: Int, isOn: Bool,
                          @ViewBuilder icon: () -> some View,
                          toggle: @escaping () -> Void) -> some View {
        Button {
            withAnimation(.snappy) { toggle() }
        } label: {
            HStack(spacing: 12) {
                icon()
                    .frame(width: 28)
                Text(title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("\(count)")
                    .foregroundStyle(Palette.muted)
                Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isOn ? Color.accentColor : Palette.muted)
            }
            .foregroundStyle(Color.primary)
            .contentShape(.rect)
        }
        .accessibilityAddTraits(isOn ? .isSelected : [])
    }
}
