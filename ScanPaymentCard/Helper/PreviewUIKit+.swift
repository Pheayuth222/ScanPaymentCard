//
//  PreivewUIKit+.swift
//  ScanPaymentCard
//
//  Created by YuthFight's MacBook Pro  on 26/8/24.
//

import SwiftUI
import UIKit

struct PreviewContainer<T: UIViewController>: UIViewControllerRepresentable {
    
    let viewControllerBuider : T
    
    init(_ viewControllerBuilder: @escaping () -> T) {
        
        self.viewControllerBuider = viewControllerBuilder()
    }
    
    // MARK: - UIViewControllerRepresentable
    func makeUIViewController(context: Context) -> T {
        return viewControllerBuider
    }
    
    func updateUIViewController(_ uiViewController: T, context: Context) {
        
    }
    
}
