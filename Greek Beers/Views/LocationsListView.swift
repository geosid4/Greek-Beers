//
//  LocationsListView.swift
//  Greek Beers
//
//  Created by George Sidiropoulos on 12/7/23.
//


import SwiftUI

struct LocationsListView: View {

    @Environment(LocationsViewModel.self) private var vm

    var body: some View {
        List {
            ForEach(vm.locationsByRegion, id: \.region) { group in
                Section(group.region.rawValue) {
                    ForEach(group.locations) { location in
                        Button {
                            vm.showNextLocation(location: location)
                        } label: {
                            listRowView(location: location)
                        }
                        .padding(.vertical, 4)
                        .listRowBackground(Color.clear)
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .frame(maxHeight: 400)
    }
}

#Preview {
    LocationsListView()
        .environment(LocationsViewModel())
}

extension LocationsListView {

    private func listRowView(location: Location) -> some View {
        HStack {
            if let imageName = location.imageNames.first {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .padding(3)
                    .frame(width: 45, height: 45)
                    .background(Color.white, in: .rect(cornerRadius: 10))
            }
            VStack(alignment: .leading) {
                Text(location.name)
                    .font(.headline)
                Text(location.cityName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .foregroundStyle(Color.primary)
    }
}
