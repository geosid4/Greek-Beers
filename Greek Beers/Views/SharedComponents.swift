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

// Five tappable stars. Tapping the current rating again clears it
struct StarRating: View {

    let rating: Int?
    var size: Font = .title2
    let onChange: (Int?) -> Void

    var body: some View {
        HStack(spacing: 6) {
            ForEach(1...5, id: \.self) { star in
                Button {
                    onChange(rating == star ? nil : star)
                } label: {
                    Image(systemName: star <= (rating ?? 0) ? "star.fill" : "star")
                        .font(size)
                        .foregroundStyle(star <= (rating ?? 0) ? Color.yellow : Color.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(star) αστέρια")
                .accessibilityAddTraits(star == rating ? .isSelected : [])
            }
        }
    }
}

// Read-only stars for lists
struct StarsLabel: View {

    let rating: Int

    var body: some View {
        HStack(spacing: 1) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
            }
        }
        .font(.caption2)
        .foregroundStyle(.yellow)
        .accessibilityElement()
        .accessibilityLabel("\(rating) από 5 αστέρια")
    }
}

struct FavoriteButton: View {

    let isFavorite: Bool
    let toggle: () -> Void

    var body: some View {
        Button(action: toggle) {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .foregroundStyle(isFavorite ? Color.red : Color.secondary)
                .contentTransition(.symbolEffect(.replace))
        }
        .accessibilityLabel(isFavorite ? "Αφαίρεση από τα αγαπημένα" : "Προσθήκη στα αγαπημένα")
    }
}
