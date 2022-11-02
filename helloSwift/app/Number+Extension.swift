//
//  Number+Extension.swift
//  helloSwift
//
//  Created by Corkine on 2022/11/2.
//

import Foundation

extension Float {
    func roundTo(places: Int) -> Float {
        let divisor = pow(10.0, Float(places))
        return (self * divisor).rounded() / divisor
    }
}
