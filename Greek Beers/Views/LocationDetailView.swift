//
//  LocationDetailView.swift
//  Greek Beers
//
//  Created by George Sidiropoulos on 13/7/23.
//

import SwiftUI

struct LocationDetailView: View {

    @Environment(\.dismiss) private var dismiss

    let location: Location

    var body: some View {
        ScrollView {
            VStack {
                imageSection
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)

                VStack(alignment: .leading, spacing: 16) {
                    titleSection
                    Divider()
                    descriptionSection
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
        }
        .ignoresSafeArea(edges: .top)
        .overlay(alignment: .topLeading) {
            backButton
        }
    }
}

#Preview {
    LocationDetailView(location: LocationDataService.locations[0])
}

extension LocationDetailView {

    private var backButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.headline)
                .padding(16)
                .foregroundStyle(Color.primary)
                .background(.thickMaterial, in: .rect(cornerRadius: 10))
                .shadow(radius: 4)
                .padding()
        }
        .accessibilityLabel("Κλείσιμο")
    }

    // Logos have white backgrounds, so they sit on white and are fitted rather than cropped
    private var imageSection: some View {
        TabView {
            ForEach(location.imageNames, id: \.self) { imageName in
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .padding(40)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(height: 400)
        .background(Color.white)
        .tabViewStyle(.page(indexDisplayMode: location.imageNames.count > 1 ? .automatic : .never))
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(location.name)
                .font(.largeTitle)
                .fontWeight(.semibold)
            Text(location.cityName)
                .font(.title3)
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                Label(location.region.rawValue, systemImage: "map")
                if let founded = location.founded {
                    Label(String(founded), systemImage: "calendar")
                }
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(location.description)
                .font(.body)
                .foregroundStyle(.secondary)

            if let url = location.link {
                Link("Ιστοσελίδα ζυθοποιίας", destination: url)
                    .font(.headline)
            }
        }
    }
}
