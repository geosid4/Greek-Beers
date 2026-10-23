//
//  LocationPreviewView.swift
//  Greek Beers
//
//  Created by George Sidiropoulos on 12/7/23.
//

import SwiftUI

struct LocationPreviewView: View {

    @Environment(LocationsViewModel.self) private var vm

    let location: Location

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                imageSection
                titleSection
            }

            VStack(spacing: 8) {
                learnMoreButton
                nextButton
            }
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThinMaterial)
                .offset(y: 65)
        )
        .clipShape(.rect(cornerRadius: 10))
    }
}

#Preview {
    ZStack {
        Color.green.ignoresSafeArea()
        LocationPreviewView(location: LocationDataService.locations[0])
            .padding()
    }
    .environment(LocationsViewModel())
}

extension LocationPreviewView {

    private var imageSection: some View {
        ZStack {
            if let imageName = location.imageNames.first {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
            }
        }
        .padding(6)
        .background(Color.white, in: .rect(cornerRadius: 10))
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(location.name)
                .font(.title2)
                .fontWeight(.bold)

            Text(location.cityName)
                .font(.subheadline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var learnMoreButton: some View {
        Button {
            vm.sheetLocation = location
        } label: {
            Text("Περισσότερα")
                .font(.headline)
                .frame(width: 125, height: 35)
        }
        .buttonStyle(.borderedProminent)
    }

    private var nextButton: some View {
        Button {
            vm.nextButtonPressed()
        } label: {
            Text("Επόμενο")
                .font(.headline)
                .frame(width: 125, height: 35)
        }
        .buttonStyle(.bordered)
    }
}
