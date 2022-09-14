//
//  Hike.swift
//  helloSwift
//
//  Created by corkine on 2022/9/14.
//

import SwiftUI

extension AnyTransition {
    static var moveAndFade: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .scale.combined(with: .opacity)
        )
    }
}

struct HikeView: View {
    var hike: Hike
    @State private var showDetail = false
    var body: some View {
        VStack {
            HStack {
                HikeGraph(withAnimation:false,hike: hike, path: \.elevation)
                    .frame(width: 50, height: 30)
                VStack(alignment: .leading) {
                    Text(hike.name)
                        .font(.headline)
                    Text(hike.distanceText)
                }.onTapGesture {
                    showDetail.toggle()
                }
                Spacer()
                Button {
                    showDetail.toggle()
                } label: {
                    Label("Graph", systemImage: "chevron.right.circle")
                        .labelStyle(.iconOnly)
                        .imageScale(.large)
                        .rotationEffect(.degrees(showDetail ? 90 : 0))
                        .scaleEffect(showDetail ? 1.5 : 1)
                        .padding()
                        .animation(.spring(), value: showDetail)
                }
            }
            if showDetail {
                HikeDetail(hike: hike)
                    .transition(.moveAndFade)
                    .padding(.top, 10.0)
            }
        }.padding(.all, 10)
    }
}

struct Hike_Previews: PreviewProvider {
    static var previews: some View {
        HikeView(hike: ModelData().hikes[0])
    }
}

struct HikeDetail: View {
    let hike: Hike
    @State var dataToShow = \Hike.Observation.elevation
    var buttons = [
        ("Elevation", \Hike.Observation.elevation),
        ("Heart Rate", \Hike.Observation.heartRate),
        ("Pace", \Hike.Observation.pace)
    ]
    var body: some View {
        VStack {
            HikeGraph(withAnimation:true,hike: hike, path: dataToShow)
                .frame(height: 200)
            HStack(spacing: 25) {
                ForEach(buttons, id: \.0) { value in
                    Button {
                        dataToShow = value.1
                    } label: {
                        Text(value.0)
                            .font(.system(size: 15))
                            .foregroundColor(value.1 == dataToShow
                                ? .gray
                                : .accentColor)
                            .animation(nil)
                    }
                }
            }
        }
    }
}

extension Animation {
    static func ripple(index: Int) -> Animation {
        Animation.spring(dampingFraction: 0.5)
            .speed(2)
            .delay(0.03 * Double(index))
    }
}

struct HikeGraph: View {
    var withAnimation: Bool
    var hike: Hike
    var path: KeyPath<Hike.Observation, Range<Double>>
    var color: Color {
        switch path {
        case \.elevation: return .gray
        case \.heartRate: return Color(hue: 0, saturation: 0.5, brightness: 0.7)
        case \.pace: return Color(hue: 0.7, saturation: 0.4, brightness: 0.7)
        default: return .black
        }
    }
    var body: some View {
        let data = hike.observations
        let overallRange = rangeOfRanges(data.lazy.map { $0[keyPath: path] })
        let maxMagnitude = data.map {
                      magnitude(of: $0[keyPath: path]) }.max()!
        let heightRatio = 1 - CGFloat(maxMagnitude /
                      magnitude(of: overallRange))
        return GeometryReader { proxy in
            HStack(alignment: .bottom, spacing: proxy.size.width / 120) {
                ForEach(Array(data.enumerated()), id: \.offset) {
                                     index, observation in
                    GraphCapsule(
                        index: index,
                        color: color,
                        height: proxy.size.height,
                        range: observation[keyPath: path],
                        overallRange: overallRange
                    ).animation(withAnimation ? .ripple(index: index) : nil)
                }
                .offset(x: 0, y: proxy.size.height * heightRatio)
            }
        }
    }
}

//struct Hike_Previews: PreviewProvider {
//    static var previews: some View {
//        HikeGraph(hike:ModelData().hikes[0],path:\.heartRate)
//    }
//}

func rangeOfRanges<C: Collection>(_ ranges: C) -> Range<Double>
    where C.Element == Range<Double> {
    guard !ranges.isEmpty else { return 0..<0 }
    let low = ranges.lazy.map { $0.lowerBound }.min()!
    let high = ranges.lazy.map { $0.upperBound }.max()!
    return low..<high
}

func magnitude(of range: Range<Double>) -> Double {
    range.upperBound - range.lowerBound
}

struct GraphCapsule: View, Equatable {
    var index: Int
    var color: Color
    var height: CGFloat
    var range: Range<Double>
    var overallRange: Range<Double>
    var heightRatio: CGFloat {
        max(CGFloat(magnitude(of: range) / magnitude(of: overallRange)), 0.15)
    }
    var offsetRatio: CGFloat {
        CGFloat((range.lowerBound - overallRange.lowerBound) /
                                magnitude(of: overallRange))
    }
    var body: some View {
        Capsule()
            .fill(color)
            .frame(height: height * heightRatio)
            .offset(x: 0, y: height * -offsetRatio)
    }
}
//
//struct GraphCapsule_Previews: PreviewProvider {
//    static var previews: some View {
//        GraphCapsule(
//            index: 0,
//            color: .blue,
//            height: 150,
//            range: 10..<50,
//            overallRange: 0..<100)
//            .previewLayout(.fixed(width: 200, height: 80))
//    }
//}
