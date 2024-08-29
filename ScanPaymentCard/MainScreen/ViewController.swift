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
    var placeholder: String?
    var placeholderYYYY: String?
    var responseValue: String?
    var monthValue: String?
    var yearValue: String?
}

class ViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var paymentModel : [PaymentModel] = [
        
        PaymentModel(title: "Number", placeholder: "Required",responseValue: ""),
        PaymentModel(title: "Expires", placeholder: "MM",placeholderYYYY: "YYYY",monthValue: "", yearValue: ""),
        PaymentModel(title: "CVV", placeholder: "Security code",responseValue: ""),
        
    ]
    
    var cardResponseData : CardScannerResponse?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @objc func openScanCard(_ sender: UIButton) {
        let scannerVC = SharkCardScanVC(viewModel: CardScanVM(noPermissionAction: { [weak self] in
            self?.showNoPermissionAlert()
        }, successHandler: { (response) in
            self.cardResponseData = response
            self.updatePaymentModelWithCardData()
        }))
        self.present(scannerVC, animated: true, completion: nil)
    }
    
    private func updatePaymentModelWithCardData() {
        guard let expireDate = cardResponseData?.expireDate else { return }
        let yearSuffix = expireDate.suffix(2)
        let monthPrefix = expireDate.prefix(2)
        
        print("Expire 💣: \(cardResponseData?.expireDate ?? "")")
        print("Card Number 💳: \(cardResponseData?.number ?? "")")
        print("Holder name 🕺: \(cardResponseData?.holder ?? "")")
        
        paymentModel[0].responseValue = cardResponseData?.number ?? ""
        paymentModel[1].monthValue = String(monthPrefix)
        paymentModel[1].yearValue = String(yearSuffix)
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func showNoPermissionAlert() {
        showAlert(style: .alert, title: "Oopps, No access", message: "Check settings and ensure the app has permission to use the camera.", actions: [UIAlertAction(title: "OK", style: .default, handler: { (_) in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })])
    }
    
    func showAlert(style: UIAlertController.Style, title: String?, message: String?, actions: [UIAlertAction]) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        alertController.view.tintColor = UIColor.black
        actions.forEach {
            alertController.addAction($0)
        }
        if style == .actionSheet && actions.contains(where: { $0.style == .cancel }) == false {
            alertController.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        }
        self.present(alertController, animated: true, completion: nil)
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
        cell.configCell(data: paymentModel[indexPath.row],indexPath: indexPath,cardResponse: paymentModel[indexPath.row])
        
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
    
    
    func configCell(data: PaymentModel, indexPath: IndexPath,cardResponse: PaymentModel?) {
        titleLabel.text = data.title
        monthTF.placeholder = data.placeholder
        if let cardResponse = cardResponse {
            yearTF.text = cardResponse.yearValue ?? ""
            monthTF.text = cardResponse.monthValue ?? ""
            if indexPath.row == 0 {
                monthTF.text = cardResponse.responseValue ?? ""
            }
        }
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
