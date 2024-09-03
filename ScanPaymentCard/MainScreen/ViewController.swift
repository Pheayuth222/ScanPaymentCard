//
//  ViewController.swift
//  ScanPaymentCard
//
//  Created by Yuth Fight on 8/7/24.
//

import UIKit
import SwiftUI

class ViewController: UIViewController {
    
    @IBOutlet weak var numberCardLabel: UILabel!
    @IBOutlet weak var placeHolderTF: UITextField!
    
    @IBOutlet weak var monthYearLabel: UILabel!
    @IBOutlet weak var monthYearTF: UITextField!
    @IBOutlet weak var numberTextFieldCard: UITextField!
    @IBOutlet weak var cardImageType: UIImageView!
    @IBOutlet weak var creditCardView: CustomBackgroundView!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!
    
    var paymentModel : [PaymentModel] = [
        
        PaymentModel(title: "Number", placeholder: "Required",responseValue: ""),
        PaymentModel(title: "Expires", placeholder: "MM",placeholderYYYY: "YYYY",monthValue: "", yearValue: ""),
        PaymentModel(title: "CVV", placeholder: "Security code",responseValue: ""),
        
    ]
    
    var cardTypeName = "visa1"
    var cardResponseData : CardScannerResponse?
    var imageRandomBackground : [String] = ["card1","card2","card3","card4","card5","card6","card7"]
    var numberColors : [UIColor] = [
        UIColor(white: 0.9, alpha: 1.0),  // Bright streak
        UIColor(white: 0.9, alpha: 1.0),  // Medium gray
        UIColor(white: 0.7, alpha: 1.0),  // Darker gray
        UIColor(white: 0.9, alpha: 1.0),  // Medium gray
        UIColor(white: 0.9, alpha: 1.0)   // Bright streak
    ]
    private var imageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numberCardLabel.font = UIFont(name: "OCR-A BT", size: 30)
        
        monthYearTF.text = "07 / 26"
        placeHolderTF.text = "PLACEHOLDER NAME"
        
        addImageAsBg()
        numberCardLabel.dropShadowLabel()
        monthYearLabel.textColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        numberCardLabel.applyGradientToCharacters(colors: numberColors)
    }
    
    private func addImageAsBg() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.setCornerRadius(15, corners: .all)
        
        creditCardView.backgroundColor = .clear
        creditCardView.insertSubview(imageView, at: 0)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: creditCardView.leadingAnchor,constant: 0),
            imageView.trailingAnchor.constraint(equalTo: creditCardView.trailingAnchor,constant: 0),
            imageView.topAnchor.constraint(equalTo: creditCardView.topAnchor,constant: 0),
            imageView.bottomAnchor.constraint(equalTo: creditCardView.bottomAnchor,constant: 0),
        ])
        let imageName = self.randomImageView()
        if let image = UIImage(named: imageName) {
            imageView.image = image
        } else {
            print("Image named \(imageName) not found.")
        }
        
        imageView.setCornerRadius(15, corners: .all)
    }
    
    @objc func openScanCard(_ sender: UIButton) {
        let scannerVC = SharkCardScanVC(viewModel: CardScanVM(noPermissionAction: { [weak self] in
            self?.showNoPermissionAlert()
        }, successHandler: { (response) in
            self.cardResponseData = response
            self.updatePaymentModelWithCardData(response: response)
        }))
        self.present(scannerVC, animated: true, completion: nil)
    }
    
    private func updatePaymentModelWithCardData(response: CardScannerResponse?) {
        guard let expireDate = response else { return }
        let yearSuffix = expireDate.expireDate?.suffix(2)
        let monthPrefix = expireDate.expireDate?.prefix(2)
        print("Expire 💣: \(response?.expireDate ?? "")")
        print("Card Number 💳: \(response?.number ?? "")")
        print("Holder name 🕺: \(response?.holder ?? "")")
        self.addImageAsBg()
        numberTextFieldCard.text = response?.number ?? ""
        numberTextFieldCard.font = UIFont(name: "OCR-A BT", size: 25)
        placeHolderTF.text = response?.holder ?? ""
        monthYearTF.text = response?.expireDate ?? ""
        numberCardLabel.text = maskCreditCardNumber(response?.number ?? "")
        paymentModel[0].responseValue = response?.number ?? ""
        paymentModel[1].monthValue = String(monthPrefix ?? "")
        paymentModel[1].yearValue = String(yearSuffix ?? "")
        let checkImageType = checkCardTypes(cardNumbers: response?.number ?? "")
        cardImageType.image = UIImage(named: checkImageType)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func randomImageView() -> String {
        let randomIndex = Int(arc4random_uniform(UInt32(imageRandomBackground.count)))
        return imageRandomBackground[randomIndex]
    }
    
    private func checkCardTypes(cardNumbers: String) -> String {
        switch detectCardType(cardNumber: cardNumbers) {
        case .visa:       return "visa1"
        case .masterCard: return "mastercard"
        case .maestro:    return "maestro"
        case .jcb:        return "JCB"
        case .unionPay:   return "unionPay"
        case .americanExpress:  return "americanExpress"
        case .dinersClub: return "dinnersClub"
        case .discover:   return "discover"
        case .unknown:    return "Unknown Card"
        }
    }
    
    // MARK: This function make Card Number to be "1234 **** **** 9832"
    private func maskCreditCardNumber(_ cardNumber: String) -> String {
        let components = cardNumber.split(separator: " ")
        guard components.count == 4 else { return cardNumber }
        let maskedMiddle = "**** ****"
        print("cardNumber \(components[0]) \(maskedMiddle) \(components[3])")
        return "\(components[0]) \(maskedMiddle) \(components[3])"
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
        cell.monthTF.delegate = self
        cell.yearTF.delegate = self
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return "Section \(section)" // Optional: Set header title for each section
//    }
    
    //  func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    //    return "End of Section \(section)" // Optional: Set footer title for each section
    //  }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
}

extension ViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print(textField.text ?? "")
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("Begin Editing")
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
        
        yearTF.placeholder = data.placeholderYYYY
        monthTF.keyboardType = .numberPad
        monthTF.returnKeyType = .next
        yearTF.keyboardType = .numberPad
        cameraButton.isHidden = indexPath.row != 0
        
        monthTF.font = UIFont(name: "OCR-A BT", size: 20)
        yearTF.font = UIFont(name: "OCR-A BT", size: 20)
        
        if let cardResponse = cardResponse {
            yearTF.text = cardResponse.yearValue ?? ""
            monthTF.text = cardResponse.monthValue ?? ""
            if indexPath.row == 0 {
                monthTF.text = cardResponse.responseValue ?? ""
            }
        }
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
