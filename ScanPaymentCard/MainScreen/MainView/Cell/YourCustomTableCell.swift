//
//  YourCustomTableCell.swift
//  ScanPaymentCard
//
//  Created by Yuth Fight on 6/9/24.
//

import UIKit

class YourCustomTableCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var monthTF: UITextField!
    @IBOutlet weak var yearTF: UITextField!
    
    @IBOutlet weak var slashLabel: UILabel!
    
    @IBOutlet weak var cameraButton: UIButton!
    
    
    func configCell(data: PaymentModel, indexPath: IndexPath,cardResponse: PaymentModel?) {
        
        titleLabel.text     = data.title
        monthTF.placeholder = data.placeholder
        
        yearTF.placeholder      = data.placeholderYYYY
        monthTF.keyboardType    = .numberPad
        monthTF.returnKeyType   = .next
        yearTF.keyboardType     = .numberPad
        cameraButton.isHidden   = indexPath.row != 0
        
        monthTF.font    = UIFont(name: "OCR-A BT", size: 20)
        yearTF.font     = UIFont(name: "OCR-A BT", size: 20)
        
        if let cardResponse = cardResponse {
            yearTF.text     = cardResponse.yearValue ?? ""
            monthTF.text    = cardResponse.monthValue ?? ""
            if indexPath.row == 0 {
                monthTF.text = cardResponse.responseValue ?? ""
            }
        }
        if indexPath.row != 1 {
            slashLabel.isHidden = true
            yearTF.isHidden     = true
        } else {
            slashLabel.isHidden = false
            yearTF.isHidden     = false
        }
    }
    
}
