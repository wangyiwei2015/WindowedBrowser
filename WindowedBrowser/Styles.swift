//
//  Styles.swift
//  WindowedBrowser
//
//  Created by leo on 2024-07-01.
//

import SwiftUI

struct TopbarBtnStyle: ButtonStyle {
    var tint: Color
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            configuration.isPressed ? tint : Color(UIColor.systemBackground)
            configuration.label
        }
    }
}

struct HomeBtnStyle: ButtonStyle {
    var highlighted: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(
                    configuration.isPressed
                    ? Color.gray6
                    : (highlighted ? Color("WBColor") : Color.sysBackground)
                )
                .stroke(.black.opacity(0.5), lineWidth: 0.2)
                .shadow(
                    radius: configuration.isPressed ? 0.5 : 1,
                    y: configuration.isPressed ? 0.5 : 2
                )
            configuration.label
        }
    }
}

extension Color {
    static let sysBackground = Color(UIColor.systemBackground)
    static let gray2 = Color(UIColor.systemGray2)
    static let gray3 = Color(UIColor.systemGray3)
    static let gray4 = Color(UIColor.systemGray4)
    static let gray5 = Color(UIColor.systemGray5)
    static let gray6 = Color(UIColor.systemGray6)
}
