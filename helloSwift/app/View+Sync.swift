//
//  View+Sync.swift
//  helloSwift
//
//  Created by Corkine on 2022/10/19.
//

import Foundation
import SwiftUI

extension View {
  func sync(_ published: Binding<Bool>, with binding: Binding<Bool>) -> some View {
    self
      .onChange(of: published.wrappedValue) { newValue in
        binding.wrappedValue = newValue
      }
      .onChange(of: binding.wrappedValue) { newValue in
        published.wrappedValue = newValue
      }
  }
}
