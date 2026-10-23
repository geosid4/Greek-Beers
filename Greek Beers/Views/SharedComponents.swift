//
//  SharedComponents.swift
//  Zythos
//

import SwiftUI

// The design's colours. The app is dark-only, so each has a single value;
// the background is also the launch screen's, so launch hands over seamlessly
enum Palette {
    static let background = Color("AppBackground")
    static let surface = Color("Surface")
}

extension View {
    // Lists draw their own grey grouped background; swap it for the app's
    func appListBackground() -> some View {
        scrollContentBackground(.hidden)
            .background(Palette.background)
    }
}

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
        .background(Palette.surface, in: .rect(cornerRadius: 12))
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
        .foregroundStyle(isActive ? Palette.background : Color.primary)
        .background(isActive ? Color.accentColor : Palette.surface, in: .capsule)
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

// A brewery's stamp in the Passport: the logo in a ring, solid amber once visited
struct PassportStamp: View {

    let brewery: Brewery
    let isVisited: Bool
    var size: CGFloat = 60

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            BreweryLogoView(brewery: brewery, size: size * 0.58)
                .opacity(isVisited ? 1 : 0.45)
                .frame(width: size, height: size)
                .overlay {
                    Circle()
                        .strokeBorder(isVisited ? Color.accentColor : Color.secondary,
                                      style: StrokeStyle(lineWidth: isVisited ? 3 : 1.5, dash: isVisited ? [] : [4, 5]))
                }

            if isVisited {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: size * 0.28))
                    .foregroundStyle(Color.accentColor, Palette.background)
            }
        }
        .accessibilityElement()
        .accessibilityLabel(isVisited ? "\(brewery.name), επισκέφθηκες" : "\(brewery.name), χωρίς επίσκεψη")
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
                        .foregroundStyle(star <= (rating ?? 0) ? Color.accentColor : Color.secondary)
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
        .foregroundStyle(Color.accentColor)
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
