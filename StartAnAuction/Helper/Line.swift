//
//  Line.swift
//  CashManagementApp
//
//  Created by Arkadijs Makarenko on 18/08/2023.
//

import SwiftUI

struct Line: View {
    
    static let defaultColor = Color.gray
    
    private let axis: Axis
    private let size: CGFloat
    private let color: Color
    
    init(_ axis: Axis = .horizontal, color: Color? = nil, size: CGFloat = 1) {
        self.axis = axis
        self.size = size
        self.color = color ?? Line.defaultColor
    }
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: axis == .vertical ? size : nil, height: axis == .horizontal ? size : nil)
    }
    
}


struct DottedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}
