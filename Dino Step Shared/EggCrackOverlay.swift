//
//  EggCrackOverlay.swift
//  Dino Step Shared
//

import SwiftUI

struct EggCrackOverlay: View {
    let crackLevel: Int
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        if crackLevel > 0 {
            Canvas { context, size in
                let color = Color.black.opacity(0.5 + Double(crackLevel) * 0.08)
                let stroke = StrokeStyle(lineWidth: 2.5, lineCap: .round)
                let center = CGPoint(x: size.width / 2, y: size.height / 2)

                func crack(from: CGPoint, to: CGPoint) {
                    var path = Path()
                    path.move(to: from)
                    path.addLine(to: to)
                    context.stroke(path, with: .color(color), style: stroke)
                }

                if crackLevel >= 1 {
                    crack(
                        from: CGPoint(x: center.x - size.width * 0.08, y: center.y - size.height * 0.18),
                        to: CGPoint(x: center.x + size.width * 0.12, y: center.y + size.height * 0.1)
                    )
                }
                if crackLevel >= 2 {
                    crack(
                        from: CGPoint(x: center.x + size.width * 0.1, y: center.y - size.height * 0.2),
                        to: CGPoint(x: center.x - size.width * 0.06, y: center.y + size.height * 0.16)
                    )
                    crack(
                        from: CGPoint(x: center.x - size.width * 0.18, y: center.y + size.height * 0.04),
                        to: CGPoint(x: center.x + size.width * 0.04, y: center.y + size.height * 0.22)
                    )
                }
                if crackLevel >= 3 {
                    crack(
                        from: CGPoint(x: center.x, y: center.y - size.height * 0.28),
                        to: CGPoint(x: center.x - size.width * 0.14, y: center.y + size.height * 0.08)
                    )
                    crack(
                        from: CGPoint(x: center.x + size.width * 0.16, y: center.y - size.height * 0.06),
                        to: CGPoint(x: center.x + size.width * 0.02, y: center.y + size.height * 0.28)
                    )
                }
            }
            .frame(width: width, height: height)
            .allowsHitTesting(false)
        }
    }
}
