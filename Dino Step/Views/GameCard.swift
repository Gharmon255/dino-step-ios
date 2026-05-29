//
//  GameCard.swift
//  Dino Step
//

import SwiftUI

struct GameCard<Content: View>: View {
    var accentColor: Color?
    let content: Content

    init(accentColor: Color? = nil, @ViewBuilder content: () -> Content) {
        self.accentColor = accentColor
        self.content = content()
    }

    var body: some View {
        content
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        accentColor?.opacity(0.55) ?? Color.white.opacity(0.08),
                        lineWidth: accentColor != nil ? 2 : 1
                    )
            )
    }
}

struct StepButtonStyle: ButtonStyle {
    var color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(configuration.isPressed ? 0.75 : 1.0))
            )
    }
}

struct DebugButtonStyle: ButtonStyle {
    var color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(configuration.isPressed ? 0.75 : 1.0))
            )
    }
}
