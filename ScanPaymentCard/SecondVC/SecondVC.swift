//
//  SecondVC.swift
//  ScanPaymentCard
//
//  Created by YuthFight's MacBook Pro  on 23/7/24.
//

import UIKit
import SwiftUI

class SecondVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let tableView = UITableView(frame: .zero, style: .grouped)
    
    let profileSection = [
        ("Troy Smith", "Product Designer", "Profile", "Edit")
    ]
    
    let sections = [
        ("", [
            ("Credit Cards", "3 Cards linked", "creditcard.fill"),
            ("Addresses", "Add or remove an address", "map.fill")
        ]),
        ("Rewards", [
            ("Rewards", "You've Earned 8,876 Points", "trophy.fill"),
            ("Refer & Earn", "Get $5.00 for every friend you refer", "dollarsign.circle.fill")
        ])
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ProfileCell.self, forCellReuseIdentifier: "ProfileCell")
        tableView.register(DetailCell.self, forCellReuseIdentifier: "DetailCell")
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 + sections.count // Profile section + other sections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return profileSection.count
        } else {
            return sections[section - 1].1.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section > 0 else { return nil }
        
        let headerView = UIView()
        headerView.backgroundColor = .clear
        
        let headerLabel = UILabel()
        headerLabel.text = sections[section - 1].0
        headerLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(headerLabel)
        
        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            headerLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            headerLabel.topAnchor.constraint(equalTo: headerView.topAnchor),
            headerLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor)
        ])
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! ProfileCell
            let profile = profileSection[indexPath.row]
            cell.configure(name: profile.0, jobTitle: profile.1, imageName: profile.2, editText: profile.3)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath) as! DetailCell
            let detail = sections[indexPath.section - 1].1[indexPath.row]
            cell.configure(title: detail.0, subtitle: detail.1, imageName: detail.2)
            return cell
        }
    }
}

class ProfileCell: UITableViewCell {
    let profileImageView = UIImageView()
    let nameLabel = UILabel()
    let jobTitleLabel = UILabel()
    let editButton = UIButton(type: .system)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        profileImageView.layer.cornerRadius = 30
        profileImageView.clipsToBounds = true
        
        nameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        jobTitleLabel.font = UIFont.systemFont(ofSize: 14)
        jobTitleLabel.textColor = .gray
        
        let textStackView = UIStackView(arrangedSubviews: [nameLabel, jobTitleLabel])
        textStackView.axis = .vertical
        textStackView.spacing = 5
        
        let mainStackView = UIStackView(arrangedSubviews: [profileImageView, textStackView, editButton])
        mainStackView.axis = .horizontal
        mainStackView.spacing = 10
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: 60),
            profileImageView.heightAnchor.constraint(equalToConstant: 60),
            
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    func configure(name: String, jobTitle: String, imageName: String, editText: String) {
        profileImageView.image = UIImage(named: imageName) // Replace with actual image
        nameLabel.text = name
        jobTitleLabel.text = jobTitle
        editButton.setTitle(editText, for: .normal)
    }
}

class DetailCell: UITableViewCell {
    let iconImageView = UIImageView()
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textColor = .gray
        
        let textStackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStackView.axis = .vertical
        textStackView.spacing = 5
        
        let mainStackView = UIStackView(arrangedSubviews: [iconImageView, textStackView])
        mainStackView.axis = .horizontal
        mainStackView.spacing = 10
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    func configure(title: String, subtitle: String, imageName: String) {
        iconImageView.image = UIImage(systemName: imageName) // Use system icons
        iconImageView.tintColor = .blue
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
}








struct ViewControllerPreview: UIViewControllerRepresentable {
  
  var viewControllerBuilder: () -> SecondVC
  
  init(_ viewControllerBuilder: @escaping () -> SecondVC) {
    self.viewControllerBuilder = viewControllerBuilder
  }
  
  func makeUIViewController(context: Context) -> some UIViewController {
    viewControllerBuilder()
  }
  
  func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
   // Nothing to do here
  }
 
}

struct ProductViewController_Previews: PreviewProvider {
  static var previews: some View {
      ViewControllerPreview {
          SecondVC()
    }
  }
}
