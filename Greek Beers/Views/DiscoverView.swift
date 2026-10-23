//
//  DiscoverView.swift
//  Zythos
//
//  Created by George Sidiropoulos on 11/7/23.
//

import SwiftUI
import MapKit

struct DiscoverView: View {

    @Environment(BreweriesViewModel.self) private var vm

    var body: some View {
        @Bindable var vm = vm

        GeometryReader { proxy in
            ZStack {
                mapLayer
                    // Keep pins clear of the sheet, which never covers more than half the map
                    .safeAreaPadding(.bottom, min(vm.sheetDetent, .medium).height(in: proxy.size.height))

                BottomSheet(detent: $vm.sheetDetent, availableHeight: proxy.size.height) {
                    if let brewery = vm.selectedBrewery {
                        BreweryDetailView.Header(brewery: brewery)
                    } else {
                        BreweriesListView.Header()
                    }
                } content: {
                    if let brewery = vm.selectedBrewery {
                        BreweryDetailView(brewery: brewery, beers: vm.catalog.beers(for: brewery))
                    } else {
                        BreweriesListView()
                    }
                }
            }
            .onChange(of: vm.filteredBreweries.map(\.id)) {
                vm.frameFilteredBreweries()
            }
        }
    }
}

#Preview {
    DiscoverView()
        .environment(BreweriesViewModel())
}

extension DiscoverView {

    // Roughly mainland Greece and the islands; the camera can't wander far outside it
    private static let greece = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 38.6, longitude: 24.2),
        span: MKCoordinateSpan(latitudeDelta: 8, longitudeDelta: 10))

    private var mapLayer: some View {
        @Bindable var vm = vm

        return Map(position: $vm.cameraPosition, bounds: MapCameraBounds(
            centerCoordinateBounds: Self.greece,
            minimumDistance: 2_000,
            maximumDistance: 6_000_000)) {
            ForEach(vm.filteredBreweries) { brewery in
                Annotation(brewery.name, coordinate: brewery.coordinates) {
                    Button {
                        vm.select(brewery)
                    } label: {
                        BreweryMapAnnotationView(brewery: brewery, isSelected: vm.selectedBrewery == brewery)
                    }
                    .buttonStyle(.plain)
                }
                .annotationTitles(.hidden)
            }
        }
        .mapStyle(.standard(elevation: .flat, emphasis: .muted, pointsOfInterest: .excludingAll))
        .mapControls {
            MapCompass()
        }
    }
}
