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
        .frame(maxHeight: 400)
    }
}

#Preview {
    BreweriesListView()
        .environment(BreweriesViewModel())
}

extension BreweriesListView {

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
                Text(brewery.city)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .foregroundStyle(Color.primary)
    }
}
