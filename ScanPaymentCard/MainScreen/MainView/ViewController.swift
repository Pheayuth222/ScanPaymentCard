//
//  ViewController.swift
//  ScanPaymentCard
//
//  Created by Yuth Fight on 8/7/24.
//
// Reference : https://github.com/gymshark/ios-card-scan.git

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
    
    var paymentViewModel = PaymentViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        paymentViewModel.initData()
        self.initializeHideKeyboard()
        
        numberCardLabel.font = UIFont(name: "OCR-A BT", size: 30)
        
        addRandomeImageAsBg()
        numberCardLabel.dropShadowLabel()
        monthYearLabel.textColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        numberCardLabel.applyGradientToCharacters(colors: paymentViewModel.numberColors)
    }
    
    private func addRandomeImageAsBg() {
        paymentViewModel.imageView.translatesAutoresizingMaskIntoConstraints = false
        paymentViewModel.imageView.clipsToBounds = true
        paymentViewModel.imageView.setCornerRadius(15, corners: .all)
        
        creditCardView.backgroundColor = .clear
        creditCardView.insertSubview(paymentViewModel.imageView, at: 0)
        NSLayoutConstraint.activate([
            paymentViewModel.imageView.leadingAnchor.constraint(equalTo: creditCardView.leadingAnchor,constant: 0),
            paymentViewModel.imageView.trailingAnchor.constraint(equalTo: creditCardView.trailingAnchor,constant: 0),
            paymentViewModel.imageView.topAnchor.constraint(equalTo: creditCardView.topAnchor,constant: 0),
            paymentViewModel.imageView.bottomAnchor.constraint(equalTo: creditCardView.bottomAnchor,constant: 0),
        ])
        
        let imageName = self.paymentViewModel.randomImageView()
        if let image = UIImage(named: imageName) {
            paymentViewModel.imageView.image = image
        } else {
            print("Image named \(imageName) not found.")
        }
        paymentViewModel.imageView.setCornerRadius(15, corners: .all)
    }
    
    //MARK: ** IMPORTANT
    // Show Camera
    @objc func openScanCard(_ sender: UIButton) {
        let scannerVC = SharkCardScanVC(viewModel: CardScanVM(noPermissionAction: { [weak self] in
            self?.showNoPermissionAlert()
        }, successHandler: { (response) in
            self.paymentViewModel.cardResponseData = response
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
        
        self.addRandomeImageAsBg()
        
        numberTextFieldCard.text = response?.number ?? ""
        numberTextFieldCard.font = UIFont(name: "OCR-A BT", size: 25)
        placeHolderTF.text = response?.holder ?? ""
        monthYearTF.text = response?.expireDate ?? ""
        numberCardLabel.text = paymentViewModel.maskCreditCardNumber(response?.number ?? "")
        paymentViewModel.paymentModel[0].responseValue = response?.number ?? ""
        paymentViewModel.paymentModel[1].monthValue = String(monthPrefix ?? "")
        paymentViewModel.paymentModel[1].yearValue = String(yearSuffix ?? "")
        let checkImageType = paymentViewModel.checkCardTypes(cardNumbers: response?.number ?? "")
        cardImageType.image = UIImage(named: checkImageType)
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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paymentViewModel.paymentModel.count // Number of rows in each section
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "YourCustomTableCell", for: indexPath) as? YourCustomTableCell else { return UITableViewCell()}
        
        cell.cameraButton.addTarget(self, action: #selector(openScanCard), for: .touchUpInside)
        cell.configCell(data: paymentViewModel.paymentModel[indexPath.row],indexPath: indexPath,cardResponse: paymentViewModel.paymentModel[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
}

//MARK: Init func for Dismiss Keyboard
extension ViewController {
    
    func initializeHideKeyboard() {
        let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
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
