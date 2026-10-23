//
//  BeerGlassView.swift
//  Zythos
//

import SwiftUI

// A pint glass filled with the beer's colour. We have no product photos, so this is the
// beer's picture everywhere in the app
struct BeerGlassView: View {

    let color: Color
    let height: CGFloat

    var body: some View {
        let width = height * 0.72

        ZStack(alignment: .top) {
            Rectangle()
                .fill(color.gradient)

            // Foam
            Rectangle()
                .fill(Color(white: 0.97))
                .frame(height: height * 0.2)

            // Light catching the glass
            Capsule()
                .fill(.white.opacity(0.35))
                .frame(width: width * 0.08, height: height * 0.5)
                .offset(x: -width * 0.24, y: height * 0.3)
        }
        .frame(width: width, height: height)
        .clipShape(PintGlassShape())
        .overlay {
            PintGlassShape()
                .stroke(Color.primary.opacity(0.15), lineWidth: 1)
        }
        .accessibilityHidden(true)
    }
}

extension BeerGlassView {

    init(beer: Beer, height: CGFloat) {
        self.init(color: beer.displayColor, height: height)
    }
}

// Wide at the rim, narrower at a rounded base
struct PintGlassShape: Shape {

    func path(in rect: CGRect) -> Path {
        let taper = rect.width * 0.14
        let corner = rect.width * 0.12
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - taper, y: rect.maxY - corner))
        path.addQuadCurve(to: CGPoint(x: rect.maxX - taper - corner, y: rect.maxY),
                          control: CGPoint(x: rect.maxX - taper, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + taper + corner, y: rect.maxY))
        path.addQuadCurve(to: CGPoint(x: rect.minX + taper, y: rect.maxY - corner),
                          control: CGPoint(x: rect.minX + taper, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

extension Beer {

    var formattedABV: String? {
        abv.map { "\($0.formatted(.number.precision(.fractionLength(0...1))))% ABV" }
    }

    // Falls back to the style family's colour when the beer's own colour isn't known
    var displayColor: Color {
        switch color {
        case .pale: Color(red: 0.96, green: 0.80, blue: 0.35)
        case .amber: Color(red: 0.80, green: 0.45, blue: 0.15)
        case .dark: Color(red: 0.25, green: 0.13, blue: 0.08)
        case nil: styleFamily.displayColor
        }
    }

    // Descriptions marked PLACEHOLDER in the JSON are notes to the editor, not text for users
    var displayDescription: String? {
        guard let description, !description.hasPrefix("PLACEHOLDER") else { return nil }
        return description
    }
}

extension StyleFamily {

    var displayColor: Color {
        switch self {
        case .lager: Color(red: 0.96, green: 0.80, blue: 0.35)
        case .wheat: Color(red: 0.98, green: 0.87, blue: 0.58)
        case .paleAleIPA: Color(red: 0.86, green: 0.55, blue: 0.20)
        case .stoutPorter: Color(red: 0.22, green: 0.12, blue: 0.07)
        case .sour: Color(red: 0.84, green: 0.33, blue: 0.38)
        case .belgianStrong: Color(red: 0.70, green: 0.35, blue: 0.12)
        case .specialty: Color(red: 0.62, green: 0.68, blue: 0.32)
        }
    }
}

#Preview {
    HStack(alignment: .bottom, spacing: 16) {
        ForEach(StyleFamily.allCases) { family in
            BeerGlassView(color: family.displayColor, height: 70)
        }
    }
    .padding()
}
