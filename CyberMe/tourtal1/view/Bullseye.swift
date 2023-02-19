//
//  Bullseye.swift
//  helloSwift
//
//  Created by corkine on 2022/9/16.
//

import SwiftUI

struct InstructionText: View {
    var text:String
    var body: some View {
        Text(text)
            .font(.footnote)
            .kerning(2)
            .textCase(.uppercase)
            .foregroundColor(Color("labelColor"))
            .lineSpacing(4.0)
            .multilineTextAlignment(.center)
    }
}

struct BigNumberText: View {
    var text:String
    var body: some View {
        Text(text)
            .bold()
            .font(.title)
            .foregroundColor(Color("labelColor"))
    }
}

struct InstructionView: View {
    @Binding var game: Game
    var body: some View {
        VStack {
            InstructionText(text:
                "🌟🌟🌟\nPut the BullsEye Close as you can do")
                .padding(.bottom, 0.1)
            
            BigNumberText(text: String(game.target))
                .padding(.bottom, 10.0)
        }
    }
}

struct SliderView: View {
    @Binding var value: Double
    var body: some View {
        HStack {
            Text("1")
                .bold()
                .foregroundColor(Color("labelColor"))
                .frame(width:30.0)
            
            Slider(value: $value, in: 1.0...100.0)
            
            Text("100")
                .bold()
                .foregroundColor(Color("labelColor"))
                .frame(width:30.0)
        }
    }
}

struct RoundedImageView: View {
    var sysName:String
    var body: some View {
        ZStack {
            Circle()
                .fill(Color("buttonFilledBackground"))
            Image(systemName: sysName)
                .font(.title)
                .foregroundColor(Color("buttonFilledText"))
                .frame(width: 50.0, height: 50.0)
        }.frame(width: 56.0, height: 56.0)
    }
}

struct RoundedImageStockView: View {
    var sysName:String
    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(Color("buttonStockBackground"), lineWidth: 1)
            Image(systemName: sysName)
                .font(.title)
                .foregroundColor(Color("buttonStockText"))
                .frame(width: 50.0, height: 50.0)
        }.frame(width: 56.0, height: 56.0)
    }
}

struct NumberView: View {
    var title:String
    var text:String
    var body: some View {
        VStack {
            Text(title.uppercased())
                .kerning(2.0)
                .font(.footnote)
                .padding(.bottom, -6)
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(Color("buttonStockBackground"),
                                  lineWidth: 2.0)
                    .frame(width: 56.0, height: 46.0)
                Text(text)
            }
        }
    }
}

struct TopView: View {
    @Binding var game: Game
    @Binding var showLeadingBoard: Bool
    var body: some View {
        HStack {
            RoundedImageStockView(sysName: "arrow.counterclockwise")
                .onTapGesture {
                    game.reset()
                }
            Spacer()
            RoundedImageView(sysName: "list.dash")
                .onTapGesture {
                    showLeadingBoard = true
                }
        }
    }
}

struct BottomView: View {
    @Binding var game: Game
    @EnvironmentObject var service:CyberService
    var body: some View {
        HStack {
            NumberView(title: "Score", text: String(game.score))
            Spacer()
            Button("EXIT") {
                withAnimation {
                    service.app = .mainApp
                }
            }.accentColor(.white)
            Spacer()
            NumberView(title: "Round", text: String(game.round))
        }
    }
}

struct BackgroundView: View {
    @Binding var game: Game
    @Binding var showLeadingBoard: Bool
    var body: some View {
        ZStack {
            Color("grayBackground")
                .edgesIgnoringSafeArea(.all)
            BackgroundRing(baseWidth: 100.0, color: Color("ringColor"))
                //use backgrond better, for iOS14, limit frame like that
                .frame(width: 200, height: 200, alignment: .center)
            VStack {
                TopView(game: $game, showLeadingBoard: $showLeadingBoard)
                Spacer()
                BottomView(game: $game)
            }.edgesIgnoringSafeArea(.all)
            .padding()
        }
    }
}

struct HitMeButton: View {
    @Binding var showAlert: Bool
    @Binding var game: Game
    @Binding var value: Double
    var body: some View {
        ZStack {
            Text("Hit Me".uppercased())
                .bold()
                .font(.title3)
                .padding(18.0)
                .foregroundColor(.white)
                .background(Color("buttonColor"))
                .cornerRadius(21.0)
                .shadow(radius: 15.0)
                .transition(.scale)
            LinearGradient(colors:
                            [Color.white.opacity(0.4),
                             Color.clear], startPoint: .topTrailing, endPoint: .bottomLeading)
                .cornerRadius(21.0)
            RoundedRectangle(cornerRadius: 21.0)
                .strokeBorder(.white, lineWidth: 1.0)
        }
        .fixedSize(horizontal: true, vertical: true)
        .onTapGesture {
            showAlert = true
        }
    }
}

struct Bullseye: View {
    @EnvironmentObject var service:CyberService
    @State var value = Double.random(in: 1.0...100.0)
    @State var showAlert = false
    @State var game = Game()
    @State var showLeadingBoard = false
    var body: some View {
        ZStack {
            BackgroundView(game: $game, showLeadingBoard: $showLeadingBoard)
                .padding(.all, -20)
            VStack {
                InstructionView(game:$game).padding(.bottom, 60)
                    .opacity(showAlert ? 0 : 1)
                    .animation(.spring().speed(3.0), value: !showAlert)
                HitMeButton(showAlert: $showAlert,
                            game: $game, value: $value)
                    .scaleEffect(showAlert ? 0.9 : 1.0, anchor: .center)
                    .opacity(showAlert ? 0 : 1)
                    .animation(.spring().speed(3.0), value: !showAlert)
            }
            SliderView(value: $value)
                .opacity(showAlert ? 0 : 1)
                .animation(.spring().speed(3.0), value: !showAlert)
            ResultView(game: $game, showAlert: $showAlert,
                       sliderValue: value)
                .opacity(showAlert ? 1 : 0)
                .fixedSize(horizontal: !showAlert, vertical: !showAlert)
                .animation(.spring().speed(2.0), value: showAlert)
        }
        .padding()
        .sheet(isPresented: $showLeadingBoard, content: {
            LeaderBoard(logs: game.logs)
        })
    }
}

extension ForEach where Data == ClosedRange<Int>, ID == Int, Content: View {
    public init(abc data: ClosedRange<Int>, @ViewBuilder content: @escaping (Int) -> Content) {
        self.init(data, id: \.self, content: content)
    }
}

struct BackgroundRing: View {
    @Environment(\.colorScheme) var colorScheme
    var baseWidth: Double
    var color: Color = .red
    var lineWidth = 15.0
    var body: some View {
        ZStack {
            ForEach(abc: 1...5) { index in
                Circle()
                    .stroke(lineWidth: lineWidth)
                    .fill(RadialGradient(colors: [color.opacity(0.3 * 0.8),
                                                  color.opacity(0)],
                                         center: .center, startRadius: 5, endRadius: 500))
                    
                    .frame(width: baseWidth * Double(index) ,height: baseWidth * Double(index), alignment: .center)
            }.opacity(colorScheme == .light ? 0.6 : 0.8)
        }
    }
}

struct ResultView: View {
    @Binding var game: Game
    @Binding var showAlert: Bool
    var sliderValue: Double = 10.0
    var body: some View {
        VStack {
            InstructionText(text: "The Sliders value is")
                .font(.footnote)
            BigNumberText(text: "\(Int(sliderValue))")
                .padding(.vertical, 2.0)
            Text("You scored \(game.points(sliderValue)) Points\n🎉🎉🎉")
                .font(.footnote)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .lineSpacing(6.0)
            ZStack {
                Color.accentColor
                    .cornerRadius(8.0)
                Button{
                    showAlert = false
                    game.startNewRound(points: game.points(sliderValue))
                } label: {
                    Text("Start New Rounded")
                        .font(.footnote)
                        .bold()
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 7)
            }.fixedSize()
        }
        .padding()
        .frame(maxWidth: 250, maxHeight: 200)
        .background(Color("dialogBackground").opacity(1))
        .cornerRadius(21.0)
        .shadow(color: .gray.opacity(0.2), radius: 20, x: 5, y: 5)
    }
}

struct BackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        //BackgroundView(game: .constant(Game()))
        //ResultView()
        //PointView()
        Bullseye()
        //.preferredColorScheme(.dark)
        //BackgroundRing(baseWidth: 100.0, color: Color("grayBackgroundDarker"))
    }
}

//struct Bullseye_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            Bullseye()
//                .preferredColorScheme(.light)
//            //.previewLayout(.fixed(width: 500, height: 300))
//
//        }
//    }
//}
//
//struct Image_Previews: PreviewProvider {
//    static var previews: some View {
//        VStack {
//            RoundedImageView(sysName: "arrow.counterclockwise")
//            RoundedImageView(sysName: "list.dash")
//        }
//            .previewLayout(.fixed(width: 200.0, height: 200.0))
//            .preferredColorScheme(.dark)
//        VStack {
//            RoundedImageView(sysName: "arrow.counterclockwise")
//            RoundedImageView(sysName: "list.dash")
//        }
//            .previewLayout(.fixed(width: 200.0, height: 200.0))
//            .preferredColorScheme(.light)
//    }
//}
