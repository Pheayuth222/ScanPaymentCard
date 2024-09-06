//
//  LayoutContentView.swift
//  ScanPaymentCard
//
//  Created by Yuth Fight on 29/8/24.
//

import UIKit

final class LayoutContentView<Layer: CALayer>: UIView {
    
    let contentLayer: Layer
    init(frame: CGRect = .zero, contenLayer: Layer) {
        self.contentLayer = contenLayer
        super.init(frame: frame)
        contenLayer.frame = frame
        layer.addSublayer(contenLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard contentLayer.frame != bounds else {
            return
        }
        contentLayer.frame = bounds
    }
}
