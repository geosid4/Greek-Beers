//
//  LocationsView.swift
//  Greek Beers
//
//  Created by George Sidiropoulos on 11/7/23.
//

import SwiftUI
import MapKit


struct LocationsView: View {

    @Environment(LocationsViewModel.self) private var vm

    var body: some View {
        @Bindable var vm = vm

        ZStack {
            mapLayer
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                    .padding()

                Spacer()

                locationsPreviewStack
            }
        }
        .sheet(item: $vm.sheetLocation) { location in
            LocationDetailView(location: location)
        }
    }
}

#Preview {
    LocationsView()
        .environment(LocationsViewModel())
}

extension LocationsView {

    private var header: some View {
        VStack {
            Button(action: vm.toggleLocationsList) {
                Text(vm.mapLocation.map { "\($0.name), \($0.cityName)" } ?? "")
                    .font(.title2)
                    .fontWeight(.black)
                    .foregroundStyle(Color.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 44)
                    .animation(.none, value: vm.mapLocation)
                    .overlay(alignment: .leading) {
                        Image(systemName: "arrow.down")
                            .font(.headline)
                            .foregroundStyle(Color.primary)
                            .padding()
                            .rotationEffect(.degrees(vm.showLocationsList ? 180 : 0))
                    }
            }
            .accessibilityHint("Εμφάνιση λίστας ζυθοποιιών")

            if vm.showLocationsList {
                LocationsListView()
            }
        }
        .background(.thickMaterial)
        .clipShape(.rect(cornerRadius: 10))
        .shadow(color: .black.opacity(0.3), radius: 20)
    }

    private var mapLayer: some View {
        @Bindable var vm = vm

        return Map(position: $vm.cameraPosition) {
            ForEach(vm.locations) { location in
                Annotation(location.name, coordinate: location.coordinates) {
                    LocationMapAnnotationView()
                        .scaleEffect(vm.mapLocation == location ? 1 : 0.7)
                        .shadow(radius: 10)
                        .onTapGesture {
                            vm.showNextLocation(location: location)
                        }
                }
                .annotationTitles(.hidden)
            }
        }
    }

    private var locationsPreviewStack: some View {
        ZStack {
            if let location = vm.mapLocation {
                LocationPreviewView(location: location)
                    .shadow(color: .black.opacity(0.3), radius: 20)
                    .padding()
                    .id(location.id)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)))
            }
        }
    }
}
