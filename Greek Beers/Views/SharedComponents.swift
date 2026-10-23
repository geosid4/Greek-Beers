//
//  SharedComponents.swift
//  Zythos
//

import SwiftUI

// Search box used at the top of both the Discover sheet and the Beers tab
struct SearchField: View {

    let prompt: String
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField(prompt, text: $text)
                .autocorrectionDisabled()
                .submitLabel(.search)
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .accessibilityLabel("Καθαρισμός αναζήτησης")
            }
        }
        .padding(10)
        .background(.quaternary, in: .rect(cornerRadius: 12))
    }
}

struct FilterChip: View {

    let title: String
    let isActive: Bool
    let showsMenuIndicator: Bool

    var body: some View {
        HStack(spacing: 4) {
            Text(title)
            if showsMenuIndicator {
                Image(systemName: "chevron.down")
                    .font(.caption2)
            }
        }
        .font(.subheadline)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .foregroundStyle(isActive ? Color.white : Color.primary)
        .background(isActive ? Color.accentColor : Color.secondary.opacity(0.15), in: .capsule)
    }
}

// Logos have white backgrounds, so they always sit on white, even in dark mode
struct BreweryLogoView: View {

    let brewery: Brewery
    let size: CGFloat

    var body: some View {
        Group {
            if let imageName = brewery.imageNames.first {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "mug.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(Color.accentColor)
                    .padding(size * 0.15)
            }
        }
        .padding(size * 0.08)
        .frame(width: size, height: size)
        .background(.white, in: .rect(cornerRadius: size * 0.25))
        .accessibilityHidden(true)
    }
}
