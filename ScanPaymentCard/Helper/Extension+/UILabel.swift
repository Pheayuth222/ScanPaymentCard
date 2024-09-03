//
//  UILabel.swift
//  ScanPaymentCard
//
//  Created by Yuth Fight on 3/9/24.
//

import UIKit

extension UILabel {
    func applyGradientToCharacters(colors: [UIColor]) {
        guard let text = self.text else { return }
        let attributedString = NSMutableAttributedString(string: text)
        
        for i in 0..<text.count {
            let range = NSRange(location: i, length: 1)
            let character = (text as NSString).substring(with: range)
            
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = colors.map { $0.cgColor }
            
            // Set the gradient direction to topTrailing
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0) // Bottom-left
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1) // Top-right
            //            gradientLayer.type = .axial
            
            let textSize = (character as NSString).size(withAttributes: [NSAttributedString.Key.font: self.font!])
            gradientLayer.frame = CGRect(origin: .zero, size: textSize)
            
            UIGraphicsBeginImageContextWithOptions(textSize, false, 0)
            gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
            let gradientImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            
            let textColor = UIColor(patternImage: gradientImage)
            attributedString.addAttribute(.foregroundColor, value: textColor, range: range)
        }
        
        self.attributedText = attributedString
    }
}
