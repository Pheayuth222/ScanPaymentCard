//
//  ViewController.swift
//  ScanPaymentCard
//
//  Created by Yuth Fight on 8/7/24.
//

import UIKit
import SwiftUI

//enum SECTION_TYPE: String, CaseIterable {
//    case PaymentMethod
//    case CardInfo
//}
//
//struct Container<T> {
//    let value : T?
//    let sectionType: SECTION_TYPE
//}

struct PaymentModel {
    let title: String?
    let placeholder: String?
    var placeholderYYYY: String?
}

class ViewController: UIViewController {
  
    
    @IBOutlet weak var tableView: UITableView!
    
    var paymentModel : [PaymentModel] = [
    
        PaymentModel(title: "Number", placeholder: "Required"),
        PaymentModel(title: "Expires", placeholder: "MM",placeholderYYYY: "YYYY"),
        PaymentModel(title: "CVV", placeholder: "Security code"),
    
    ]
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  
    @objc func openScanCard(_ sender: UIButton) {
        print("Clicked!")
    }
    
   
}

extension ViewController : UITableViewDelegate , UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1 // Number of sections
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return paymentModel.count // Number of rows in each section
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      guard let cell = tableView.dequeueReusableCell(withIdentifier: "YourCustomTableCell", for: indexPath) as? YourCustomTableCell else { return UITableViewCell()}
      
      cell.cameraButton.addTarget(self, action: #selector(openScanCard), for: .touchUpInside)
      cell.configCell(data: paymentModel[indexPath.row],indexPath: indexPath)
      
    return cell
  }
  
  // MARK: - UITableViewDelegate
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "Section \(section)" // Optional: Set header title for each section
  }
  
//  func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
//    return "End of Section \(section)" // Optional: Set footer title for each section
//  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 56
  }
  
}

class YourCustomTableCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var monthTF: UITextField!
    @IBOutlet weak var yearTF: UITextField!
    
    @IBOutlet weak var slashLabel: UILabel!
    
    @IBOutlet weak var cameraButton: UIButton!
    
    
    func configCell(data: PaymentModel, indexPath: IndexPath) {
        titleLabel.text = data.title
        monthTF.placeholder = data.placeholder
        yearTF.placeholder = data.placeholderYYYY
        monthTF.keyboardType = .numberPad
        monthTF.returnKeyType = .next
        yearTF.keyboardType = .numberPad
        cameraButton.isHidden = indexPath.row != 0
        if indexPath.row != 1 {
            slashLabel.isHidden = true
            yearTF.isHidden = true
        } else {
            slashLabel.isHidden = false
            yearTF.isHidden = false
        }
    }
    
}


struct ViewController_Preview: PreviewProvider {
  static var previews: some View {
    PreviewContainer {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateInitialViewController() as? ViewController else {
            fatalError("Cannot load ViewController from Main storyboard.")
        }
      return vc
    }
  }
}
