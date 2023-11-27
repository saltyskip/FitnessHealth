// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import SwiftUI

public struct PrimaryButton: View {
    var text: String
    var clicked: (() -> Void) /// use closure for callback
    
    public init(text: String, clicked: @escaping () -> Void) {
        self.text = text
        self.clicked = clicked
    }
    
    public var body: some View {
        Button(action: clicked) { /// call the closure here
            HStack {
                Text(text)
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity, minHeight: 48.0)
            .font(Font.headline)
            .background(Color.primaryColor)
            .cornerRadius(16)
        }
    }
}
