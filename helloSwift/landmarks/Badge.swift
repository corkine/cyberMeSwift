//
//  Badge.swift
//  helloSwift
//
//  Created by corkine on 2022/9/14.
//

import SwiftUI
import CoreGraphics

struct HexagonParameters {
    struct Segment {
        let line:CGPoint
        let curve:CGPoint
        let control:CGPoint
    }
    static let adjustment:CGFloat = 0.085
    static let segments = [
            Segment(
                line:    CGPoint(x: 0.60, y: 0.05),
                curve:   CGPoint(x: 0.40, y: 0.05),
                control: CGPoint(x: 0.50, y: 0.00)
            ),
            Segment(
                line:    CGPoint(x: 0.05, y: 0.20 + adjustment),
                curve:   CGPoint(x: 0.00, y: 0.30 + adjustment),
                control: CGPoint(x: 0.00, y: 0.25 + adjustment)
            ),
            Segment(
                line:    CGPoint(x: 0.00, y: 0.70 - adjustment),
                curve:   CGPoint(x: 0.05, y: 0.80 - adjustment),
                control: CGPoint(x: 0.00, y: 0.75 - adjustment)
            ),
            Segment(
                line:    CGPoint(x: 0.40, y: 0.95),
                curve:   CGPoint(x: 0.60, y: 0.95),
                control: CGPoint(x: 0.50, y: 1.00)
            ),
            Segment(
                line:    CGPoint(x: 0.95, y: 0.80 - adjustment),
                curve:   CGPoint(x: 1.00, y: 0.70 - adjustment),
                control: CGPoint(x: 1.00, y: 0.75 - adjustment)
            ),
            Segment(
                line:    CGPoint(x: 1.00, y: 0.30 + adjustment),
                curve:   CGPoint(x: 0.95, y: 0.20 + adjustment),
                control: CGPoint(x: 1.00, y: 0.25 + adjustment)
            )
        ]
}

struct BadgeBackground:View {
    var body: some View {
        GeometryReader { geo in
            Path { path in
                var width = min(geo.size.width, geo.size.height)
                let height = width
                let xScale:CGFloat = 0.832
                let xOffset = (width * (1.0 - xScale)) / 2.0
                width *= xScale
                path.move(to: CGPoint(x:width*0.95+xOffset,
                                      y:height*(0.20+HexagonParameters.adjustment)))
                HexagonParameters.segments.forEach { seg in
                    path.addLine(to: CGPoint(x:width*seg.line.x+xOffset,
                                             y:height*seg.line.y))
                    path.addQuadCurve(to: CGPoint(x:width*seg.curve.x+xOffset,
                                                  y:height*seg.curve.y),
                                      control: CGPoint(x:width*seg.control.x+xOffset,
                                                       y:height*seg.control.y))
                }
            }.fill(.linearGradient(Gradient(colors: [Self.gradientStart,Self.gradientEnd]),
                                   startPoint: UnitPoint(x: 0.5, y: 0),
                                   endPoint: UnitPoint(x: 0.5, y: 0.6)))
        }.aspectRatio(1, contentMode: .fit)
    }
    static let gradientStart = Color(red:239.5/255,green:120.0/255,blue:221.0/255)
    static let gradientEnd = Color(red:239.0/255,green: 172.0/255,blue: 120.0/255)
}

struct BadgeSymbol:View {
    static let symbolColor = Color(red:79.0/255,green:79.0/255,blue: 191.0/255)
    var body: some View {
        GeometryReader { geo in
            Path { path in
                let width = min(geo.size.width, geo.size.height)
                                let height = width * 0.75
                                let spacing = width * 0.030
                                let middle = width * 0.5
                                let topWidth = width * 0.226
                                let topHeight = height * 0.488
                                path.addLines([
                                    CGPoint(x: middle, y: spacing),
                                    CGPoint(x: middle - topWidth, y: topHeight - spacing),
                                    CGPoint(x: middle, y: topHeight / 2 + spacing),
                                    CGPoint(x: middle + topWidth, y: topHeight - spacing),
                                    CGPoint(x: middle, y: spacing)
                                ])
                                path.move(to: CGPoint(x: middle, y: topHeight / 2 + spacing * 3))
                                path.addLines([
                                    CGPoint(x: middle - topWidth, y: topHeight + spacing),
                                    CGPoint(x: spacing, y: height - spacing),
                                    CGPoint(x: width - spacing, y: height - spacing),
                                    CGPoint(x: middle + topWidth, y: topHeight + spacing),
                                    CGPoint(x: middle, y: topHeight / 2 + spacing * 3)
                                ])

            }.fill(Self.symbolColor)
        }
    }
}

struct RotatedBadgeSymbol: View {
    let angle: Angle
    var body: some View {
        BadgeSymbol()
            .padding(-60)
            .rotationEffect(angle,
                        anchor: .bottom)
    }
}

struct Badge: View {
    var badgeSymbols: some View {
        ForEach(0..<8) { index in
            RotatedBadgeSymbol(angle: .degrees(Double(index)/Double(8))*360.0)
        }.opacity(0.5)
    }
    var body: some View {
        ZStack {
            BadgeBackground()
            GeometryReader{geo in
                badgeSymbols.scaleEffect(1.0/4.0,anchor: .top)
                    .position(x: geo.size.width/2.0,
                              y: (3.0/4.0)*geo.size.height)
            }.scaledToFit()
        }
    }
}

struct HikeBadge: View {
    var name: String

    var body: some View {
        VStack(alignment: .center) {
            Badge()
                .frame(width: 300, height: 300)
                .scaleEffect(1.0 / 3.0)
                .frame(width: 100, height: 100)
            Text(name)
                .font(.caption)
                .accessibilityLabel("Badge for \(name).")
        }
    }
}

struct Badge_Previews: PreviewProvider {
    static var previews: some View {
        Badge()
    }
}
