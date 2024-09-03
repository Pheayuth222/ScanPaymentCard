//
//  CustomProtocols.swift
//  ScanPaymentCard
//
//  Created by Yuth Fight on 27/8/24.
//

import UIKit

typealias LabelStyling = (font: UIFont, color: UIColor)

protocol CardScanStyling {
    
    var instructionLabelStyling: LabelStyling { get set}
    
    var cardNumberLabelStyling: LabelStyling { get set }
    
    var expiryLabelStyling: LabelStyling { get set }
    
    var holderLabelStyling: LabelStyling { get set }
    
    var backgroundColor: UIColor { get set }
}

struct DefaultStyling: CardScanStyling {
    
    public var instructionLabelStyling: LabelStyling = (font: UIFont.boldSystemFont(ofSize: 14), color: .black)
    public var cardNumberLabelStyling: LabelStyling = (font: UIFont.systemFont(ofSize: 28), color: .white)
    public var expiryLabelStyling: LabelStyling = (font: UIFont.systemFont(ofSize: 14), color: .white)
    public var holderLabelStyling: LabelStyling = (font: UIFont.systemFont(ofSize: 14), color: .white)
    public var backgroundColor: UIColor = .white
    
    public init () { }
}
