//
//  BottomSheet.swift
//  Zythos
//

import SwiftUI

// Declared smallest to largest; Comparable follows this order
enum SheetDetent: CaseIterable, Comparable {
    case collapsed
    case medium
    case large

    func height(in available: CGFloat) -> CGFloat {
        switch self {
        case .collapsed: 128
        case .medium: available * 0.5
        case .large: available * 0.9
        }
    }
}

// A map-style sheet that stays on screen above the tab bar.
// The system .sheet would cover the tab bar and stay open across tabs.
// Only the header drags, so the content can scroll freely
struct BottomSheet<Header: View, Content: View>: View {

    @Binding var detent: SheetDetent
    // Height the sheet can grow into, from the parent's GeometryReader
    let availableHeight: CGFloat
    @ViewBuilder var header: Header
    @ViewBuilder var content: Content

    @GestureState private var dragTranslation: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                grabber
                header
            }
            .contentShape(.rect)
            .gesture(dragGesture)

            content
                .frame(maxHeight: .infinity, alignment: .top)
                .opacity(detent == .collapsed && dragTranslation == 0 ? 0 : 1)
        }
        .frame(maxWidth: .infinity)
        .frame(height: currentHeight, alignment: .top)
        // Filled shape rather than background(_:in:): the latter turns on vibrancy,
        // which made .secondary text inside the ScrollView render invisible
        .background {
            // Reaches under the tab bar, where the list scrolls on
            UnevenRoundedRectangle(topLeadingRadius: 20, topTrailingRadius: 20)
                .fill(.regularMaterial)
                .ignoresSafeArea(edges: .bottom)
        }
        .shadow(color: .black.opacity(0.15), radius: 12, y: -2)
        .frame(maxHeight: .infinity, alignment: .bottom)
    }

    private var grabber: some View {
        Button {
            withAnimation(.snappy) { detent = detent == .collapsed ? .medium : .collapsed }
        } label: {
            Capsule()
                .fill(.secondary.opacity(0.5))
                .frame(width: 36, height: 5)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(detent == .collapsed ? "Άνοιγμα λίστας" : "Κλείσιμο λίστας")
    }

    private var currentHeight: CGFloat {
        let minimum = SheetDetent.collapsed.height(in: availableHeight)
        let maximum = SheetDetent.large.height(in: availableHeight)
        return min(max(detent.height(in: availableHeight) - dragTranslation, minimum), maximum)
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 10)
            .updating($dragTranslation) { value, state, _ in
                state = value.translation.height
            }
            .onEnded { value in
                // Use the predicted end so a quick flick moves a whole detent
                let target = detent.height(in: availableHeight) - value.predictedEndTranslation.height
                let nearest = SheetDetent.allCases.min {
                    abs($0.height(in: availableHeight) - target) < abs($1.height(in: availableHeight) - target)
                }
                withAnimation(.snappy) { detent = nearest ?? detent }
            }
    }
}
