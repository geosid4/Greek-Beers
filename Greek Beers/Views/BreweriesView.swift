//
//  BreweriesView.swift
//  Zythos
//
//  Created by George Sidiropoulos on 11/7/23.
//

import SwiftUI
import MapKit


struct BreweriesView: View {

    @Environment(BreweriesViewModel.self) private var vm

    var body: some View {
        @Bindable var vm = vm

        ZStack {
            mapLayer
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                    .padding()

                Spacer()

                previewStack
            }
        }
        .sheet(item: $vm.sheetBrewery) { brewery in
            BreweryDetailView(brewery: brewery, beers: vm.catalog.beers(for: brewery))
        }
    }
}

#Preview {
    BreweriesView()
        .environment(BreweriesViewModel())
}

extension BreweriesView {

    private var header: some View {
        VStack {
            Button(action: vm.toggleBreweryList) {
                Text(vm.selectedBrewery.map { "\($0.name), \($0.city)" } ?? "")
                    .font(.title2)
                    .fontWeight(.black)
                    .foregroundStyle(Color.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 44)
                    .animation(.none, value: vm.selectedBrewery)
                    .overlay(alignment: .leading) {
                        Image(systemName: "arrow.down")
                            .font(.headline)
                            .foregroundStyle(Color.primary)
                            .padding()
                            .rotationEffect(.degrees(vm.showBreweryList ? 180 : 0))
                    }
            }
            .accessibilityHint("Εμφάνιση λίστας ζυθοποιιών")

            if vm.showBreweryList {
                BreweriesListView()
            }
        }
        .background(.thickMaterial)
        .clipShape(.rect(cornerRadius: 10))
        .shadow(color: .black.opacity(0.3), radius: 20)
    }

    private var mapLayer: some View {
        @Bindable var vm = vm

        return Map(position: $vm.cameraPosition) {
            ForEach(vm.filteredBreweries) { brewery in
                Annotation(brewery.name, coordinate: brewery.coordinates) {
                    BreweryMapAnnotationView()
                        .scaleEffect(vm.selectedBrewery == brewery ? 1 : 0.7)
                        .shadow(radius: 10)
                        .onTapGesture {
                            vm.show(brewery)
                        }
                }
                .annotationTitles(.hidden)
            }
        }
    }

    private var previewStack: some View {
        ZStack {
            if let brewery = vm.selectedBrewery {
                BreweryPreviewView(brewery: brewery)
                    .shadow(color: .black.opacity(0.3), radius: 20)
                    .padding()
                    .id(brewery.id)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)))
            }
        }
    }
}
