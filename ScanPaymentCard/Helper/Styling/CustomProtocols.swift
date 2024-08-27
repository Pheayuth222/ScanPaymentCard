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
