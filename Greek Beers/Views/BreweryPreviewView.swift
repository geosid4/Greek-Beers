//
//  BreweryPreviewView.swift
//  Zythos
//
//  Created by George Sidiropoulos on 12/7/23.
//

import SwiftUI

struct BreweryPreviewView: View {

    @Environment(BreweriesViewModel.self) private var vm

    let brewery: Brewery

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
        BreweryPreviewView(brewery: Catalog.bundled.breweries[0])
            .padding()
    }
    .environment(BreweriesViewModel())
}

extension BreweryPreviewView {

    private var imageSection: some View {
        ZStack {
            if let imageName = brewery.imageNames.first {
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
            Text(brewery.name)
                .font(.title2)
                .fontWeight(.bold)

            Text(brewery.city)
                .font(.subheadline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var learnMoreButton: some View {
        Button {
            vm.sheetBrewery = brewery
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
