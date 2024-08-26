//
//  ViewController.swift
//  ScanPaymentCard
//
//  Created by Yuth Fight on 8/7/24.
//

import UIKit
import SwiftUI

class ViewController: UIViewController {
  
  lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    tableView.delegate = self
    tableView.dataSource = self
    return tableView
  }()
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setUpConstraint()
    setUpTableView()
    
  }
  
  private func setUpTableView() {
    
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.register(YourCustomTableCell.self, forCellReuseIdentifier: YourCustomTableCell.identifier)
    // Default Cell of UITableView
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
  }
  
  private func setUpConstraint() {
    view.addSubview(tableView)
    
    NSLayoutConstraint.activate([
    
      tableView.topAnchor.constraint(equalTo: view.topAnchor),
      tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
      tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    
    ])
  }
  
   
}

extension ViewController : UITableViewDelegate , UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1 // Number of sections
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 3 // Number of rows in each section
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: YourCustomTableCell.identifier, for: indexPath) as! YourCustomTableCell
//    cell.textLabel?.text = "Section \(indexPath.section), Row \(indexPath.row)"
    if indexPath.row != 0 {
      cell.cameraButton.isHidden = true
    }
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
  
  static let identifier  = "YourCustomTableCell"
  
  // Create the camera icon button
  let cameraButton = UIButton(type: .system)
  
  let leftTitleLabel    = UILabel()
  
  let inputTextField = UITextField()
  
  let stackViewCover = UIStackView()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupUI() {
    
    leftTitleLabel.translatesAutoresizingMaskIntoConstraints = false
    inputTextField.translatesAutoresizingMaskIntoConstraints = false
    cameraButton.translatesAutoresizingMaskIntoConstraints = false
    
    leftTitleLabel.text = "Number"
//    leftTitleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    
    inputTextField.placeholder = "Required"
    inputTextField.textAlignment = .left
    
  
    cameraButton.setImage(UIImage(systemName: "camera.fill"), for: .normal)
    cameraButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    
    // Create the stack view
    let stackView = UIStackView(arrangedSubviews: [leftTitleLabel, inputTextField, cameraButton])
    stackView.axis = .horizontal
    stackView.alignment = .center
    stackView.spacing = 8
    stackView.translatesAutoresizingMaskIntoConstraints = false
    
    contentView.addSubview(stackView)
      
    NSLayoutConstraint.activate([
      
      inputTextField.leadingAnchor.constraint(equalTo: leftTitleLabel.trailingAnchor, constant:10),
      
      stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
      stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
      stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
    ])
  }
  
}


struct ViewController_Preview: PreviewProvider {
  static var previews: some View {
    PreviewContainer {
      ViewController()
    }
  }
}
