//
//  BodyMassView.swift
//  helloSwift
//
//  Created by Corkine on 2022/10/24.
//

import SwiftUI
import HealthKit

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

struct BodyMassView: View {
    @EnvironmentObject var service:CyberService
    
    @State var withFetch: Bool = true
    
    @State var weight = ""
    
    @State var showErrorMessage = false
    @State var errorMessage = ""
    
    var body: some View {
        VStack(alignment:.center) {
            // MARK: 旗标
            Text("🚩")
                .font(.system(size: 160))
                .padding(.bottom, 10)
                .padding(.leading, 30)
                .frame(minWidth: 1000)
                .background(Color.gray.opacity(0.1))
            // MARK: 走势
            HStack {
                VStack(alignment:.leading) {
                    Text("30 天走势")
                        .font(.system(size: 30, weight: .bold))
                    // 如果少于两个数据，则不显示
                    if service.bodyMass.count >= 2 {
                        BodyMassChartView(data: service.bodyMass,
                                          color: Color("weightDiff"))
                        .frame(height: 110)
                        .padding(.trailing, 7)
                    } else {
                        Text("没有数据，锻炼并记录一段时间后再来吧")
                            .padding(.top, 2)
                    }
                }
                .padding(.leading, 30)
                Spacer()
            }
            .padding(.top, 20)
            Spacer()
            // MARK: 体重秤
            ZStack(alignment:.top) {
                RoundedRectangle(cornerSize: CGSize(width: 20, height: 20))
                    .fill(Color.white.opacity(0.00001))
                    .frame(width: 200, height: 200)
                RoundedRectangle(cornerSize: CGSize(width: 20, height: 20))
                    .stroke(lineWidth: 5)
                    .foregroundColor(Color("weightNumber"))
                    .frame(width: 200, height: 200)
                HStack {
                    TextField("", text: $weight)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 80)
                        .foregroundColor(Color("weightNumber"))
                        .multilineTextAlignment(.center)
                        .font(.custom("American Typewriter", size: 20))
                    
                    Text("kg")
                        .foregroundColor(Color("weightNumber"))
                        .font(.custom("American Typewriter", size: 20))
                }
                .padding(.top, 30)
            }
            .onTapGesture {
                hideKeyboard()
            }
            Spacer()
            Button("记录体重") {
                if let w = Double(weight) {
                    print("记录体重值为 \(w)")
                    service.bodyMass.append(Float(w).roundTo(places: 2))
                    service.uploadBodyMass(value: w)
                    service.healthManager?.setBodyMass(w, callback: { result, err in
                        if !result {
                            errorMessage = "保存数据失败：\(String(describing: err?.localizedDescription))"
                            showErrorMessage = true
                        }
                    })
                }
            }
            .font(.system(size: 20))
            .frame(width: UIScreen.main.bounds.width - 40,
                   height: 45)
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(10)
            .padding(.bottom, 30)
        }
        .onAppear {
            if withFetch { service.refreshAndUploadHealthInfo() }
        }
        .onDisappear {
            Dashboard.updateWidget(inSeconds: 0)
        }
        .alert(isPresented: $showErrorMessage) {
            Alert(title: Text(""),
                  message: Text(errorMessage),
                  dismissButton: .default(Text("确定"), action: {
                errorMessage = ""
            }))
        }
    }
}

struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}


struct BodyMassChartView: View {
    
    var data: [Float]
    
    var color: Color = .orange
    
    func normalize(_ data: [Float], height:Float) -> [Float] {
        let min = data.min()!
        let max = data.max()!
        let each = height / Float(max - min)
        return data.map { i in Float((max - i)) * each }
    }
    
    func genText(i:Int,start:Float) -> String {
        let range = data[i] - start
        var text = ""
        if range > 0 {
            text = "+\(String(format: "%.1f", range))kg"
        } else {
            text = "\(String(format: "%.1f", range))kg"
        }
        return text
    }
    
    let lineStyle = StrokeStyle(lineWidth: 1, dash: [5])
    
    var body: some View {
        GeometryReader { proxy in
            let all: Int = data.count
            let circleWidth: CGFloat = proxy.size.width / 12
            let diffWidth: CGFloat = proxy.size.width - circleWidth
            let diffCount: Int = data.count - 1
            let circleSlot: CGFloat = diffWidth / CGFloat(diffCount)
            let dataN: [Float] = normalize(data,
                                           height: Float(proxy.size.height) - Float(circleWidth))
            let firestLineOffsetY = CGFloat(dataN[0]) + circleWidth / 2 - 1
            // MARK: 基准线
            Line()
                .stroke(style: lineStyle)
                .frame(width: proxy.size.width, height: 1)
                .foregroundColor(color.opacity(0.3))
                .offset(y: firestLineOffsetY)
                .animation(.spring(), value: data[0])
            // MARK: 体重点
            ForEach(0..<all, id:\.self) { i in
                if i == data.count - 1 {
                    // MARK: 最后一个点，显示数值
                    ZStack {
                        Circle()
                        Text(genText(i: i, start: data[0]))
                            .font(.system(size:25))
                            .fixedSize(horizontal: true, vertical: false)
                            .foregroundColor(Color.primary)
                            .offset(x:-55, y:-1)
                    }
                    .foregroundColor(color)
                    .frame(width: circleWidth, height: circleWidth)
                    .offset(x: circleSlot * CGFloat(i),
                            y: CGFloat(dataN[i]))
                    .animation(Animation.spring(dampingFraction: 0.5)
                        .speed(2)
                        .delay(0.03 * Double(i)))
                } else {
                    // MARK: 其他点
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
