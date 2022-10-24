//
//  BodyMassView.swift
//  helloSwift
//
//  Created by Corkine on 2022/10/24.
//

import SwiftUI

struct BodyMassView: View {
    @State var weight = "10"
    init() {
        UITextView.appearance().backgroundColor = .clear
    }
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .sheet(isPresented: .constant(true)) {
                VStack(alignment:.center) {
                    // MARK: 旗标
                    Text("🚩")
                        .font(.system(size: 170))
                        .padding(.bottom, 10)
                        .frame(minWidth: 1000)
                        .background(Color.gray.opacity(0.1))
                    // MARK: 走势
                    HStack {
                        VStack(alignment:.leading) {
                            Text("本月走势")
                                .font(.system(size: 30, weight: .bold))
                            BodyMassChartView(data: [101,102,103,117,99,103],
                                              color: Color("weightDiff"))
                                .frame(height: 110)
                                .padding(.trailing, 7)
                        }
                        .padding(.leading, 30)
                        Spacer()
                    }
                    .padding(.top, 20)
                    Spacer()
                    // MARK: 体重秤
                    ZStack(alignment:.top) {
                        RoundedRectangle(cornerSize: CGSize(width: 20, height: 20))
                            .stroke(lineWidth: 5)
                            .foregroundColor(Color("weightNumber"))
                            .frame(width: 200, height: 200)
                        HStack {
                            TextField("", text: $weight)
                                .textContentType(.telephoneNumber)
                                .keyboardType(.numberPad)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 60)
                                .foregroundColor(Color("weightNumber"))
                                .multilineTextAlignment(.trailing)
                                .font(.custom("American Typewriter", size: 24))
                                
                            Text("kg")
                                .foregroundColor(Color("weightNumber"))
                                .font(.custom("American Typewriter", size: 24))
                        }
                        .padding(.top, 30)
                    }
                    Spacer()
                    Button("记录体重") {
                        print("记录体重值为 \(weight)")
                    }
                    .font(.system(size: 20))
                    .padding(.horizontal, 100)
                    .padding(.vertical, 13)
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding(.bottom, 30)
                }
            }
    }
}

//extension View {
//    func textEditorBackground<V>(@ViewBuilder _ content: () -> V) -> some View where V : View {
//        self
//            .onAppear {
//                UITextView.appearance().backgroundColor = .clear
//            }
//            .background(content())
//    }
//}

struct BodyMassChartView: View {
    
    var data: [Int]
    
    var color: Color = .orange
    
    func normalize(_ data: [Int], height:Float) -> [Float] {
        let min = data.min()!
        let max = data.max()!
        let each = height / Float(max - min)
        return data.map { i in Float((max - i)) * each }
    }
    
    func genText(i:Int,start:Int) -> String {
        let range = data[i] - start
        var text = ""
        if range > 0 {
            text = "+\(range)kg"
        } else {
            text = "-\(-range)kg"
        }
        return text
    }
    
    var body: some View {
        GeometryReader { proxy in
            let all: Int = data.count
            let circleWidth: CGFloat = proxy.size.width / 12
            let diffWidth: CGFloat = proxy.size.width - circleWidth
            let diffCount: Int = data.count - 1
            let circleSlot: CGFloat = diffWidth / CGFloat(diffCount)
            let dataN: [Float] = normalize(data,
                        height: Float(proxy.size.height) - Float(circleWidth))
            Rectangle()
                .foregroundColor(color.opacity(0.3))
                .frame(width: proxy.size.width, height: 2)
                .offset(y:CGFloat(dataN[0]) + circleWidth / 2 - 1)
                .animation(.spring(), value: data[0])
            Rectangle()
                .foregroundColor(color.opacity(0.3))
                .frame(width: 2, height: proxy.size.height)
                .offset(x: circleSlot * CGFloat(all - 1) + circleWidth / 2)
                .animation(.spring(), value: data.last!)
            ForEach(0..<all, id:\.self) { i in
                if i == data.count - 1 {
                    ZStack {
                        Circle()
                        Text(genText(i: i, start: data[0]))
                            .font(.system(size:20))
                            .foregroundColor(.black)
                            .frame(width:60)
                            .offset(x:-45)
                    }
                    .foregroundColor(color)
                    .frame(width: circleWidth, height: circleWidth)
                    .offset(x: circleSlot * CGFloat(i),
                            y: CGFloat(dataN[i]))
                    .animation(Animation.spring(dampingFraction: 0.5)
                        .speed(2)
                        .delay(0.03 * Double(i)))
                } else {
                    Circle()
                        .foregroundColor(i == 0 ? color : Color.gray.opacity(0.3))
                        .frame(width: circleWidth, height: circleWidth)
                        .offset(x: circleSlot * CGFloat(i),
                                y: CGFloat(dataN[i]))
                        .animation(Animation.spring(dampingFraction: 0.5)
                            .speed(2)
                            .delay(0.03 * Double(i)))
                }
            }
        }
    }
}

struct BodyMassView_Previews: PreviewProvider {
    static var previews: some View {
        BodyMassView()
//        BodyMassChartView(data: [101,102,103,110,107,100])
//            .previewLayout(.fixed(width: 500, height: 200))
//        BodyMassChartView(data: [106,102])
//            .previewLayout(.fixed(width: 500, height: 200))
    }
}
