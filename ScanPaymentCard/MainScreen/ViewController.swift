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
  @IBOutlet weak var creditCardView: UIView!
  
  @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var tableView: UITableView!
  
  var paymentModel : [PaymentModel] = [
    
    PaymentModel(title: "Number", placeholder: "Required",responseValue: ""),
    PaymentModel(title: "Expires", placeholder: "MM",placeholderYYYY: "YYYY",monthValue: "", yearValue: ""),
    PaymentModel(title: "CVV", placeholder: "Security code",responseValue: ""),
    
  ]
  var cardTypeName = "visa1"
  var cardResponseData : CardScannerResponse?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    bottomConstraint.constant = 0
    print(detectCardType(cardNumber: "4893 8747 3474 9484"))
    creditCardView.backgroundColor = .purple
    numberTextFieldCard.keyboardType = .numberPad
    numberCardLabel.font = UIFont(name: "OCR-A BT", size: 30)
    
    numberCardLabel.dropShadowLabel()
    monthYearLabel.textColor = .white
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
    numberTextFieldCard.text = response?.number ?? ""
    numberTextFieldCard.font = UIFont(name: "OCR-A BT", size: 25)
    placeHolderTF.text = response?.holder ?? ""
    monthYearTF.text = response?.expireDate ?? ""
    paymentModel[0].responseValue = response?.number ?? ""
    paymentModel[1].monthValue = String(monthPrefix ?? "")
    paymentModel[1].yearValue = String(yearSuffix ?? "")
    bottomConstraint.constant = 0
    let checkImageType = checkCardTypes(cardNumbers: response?.number ?? "")
    cardImageType.image = UIImage(named: checkImageType)
    DispatchQueue.main.async {
      self.tableView.reloadData()
    }
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


class CustomBackgroundView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBackground()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupBackground()
    }
    
    private func setupBackground() {
        // Set up the purple shape
        let purpleLayer = CAShapeLayer()
        let purplePath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height), cornerRadius: 20)
        purpleLayer.path = purplePath.cgPath
        purpleLayer.fillColor = UIColor.systemPurple.cgColor
        
        // Set up the blue shape
        let blueLayer = CAShapeLayer()
        let bluePath = UIBezierPath(roundedRect: CGRect(x: self.frame.width / 2, y: self.frame.height / 2, width: self.frame.width / 2, height: self.frame.height / 2), cornerRadius: 20)
        blueLayer.path = bluePath.cgPath
        blueLayer.fillColor = UIColor.systemTeal.cgColor
        
        // Set up the peach shape
        let peachLayer = CAShapeLayer()
        let peachPath = UIBezierPath(roundedRect: CGRect(x: self.frame.width / 4, y: self.frame.height / 2, width: self.frame.width / 2, height: self.frame.height / 2), cornerRadius: 20)
        peachLayer.path = peachPath.cgPath
        peachLayer.fillColor = UIColor.systemPink.cgColor
        
        // Add layers to the view
        self.layer.addSublayer(purpleLayer)
        self.layer.addSublayer(blueLayer)
        self.layer.addSublayer(peachLayer)
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
    monthTF.font = UIFont(name: "OCR-A BT", size: 20)
    yearTF.font = UIFont(name: "OCR-A BT", size: 20)
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
