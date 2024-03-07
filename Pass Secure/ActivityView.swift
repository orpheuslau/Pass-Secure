//
//  ActivityView.swift
//  Pass Secure
//
//  Created by Omon 3 on 6/3/2024.
//

import Foundation
import SwiftUI

struct ActivityView: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    func makeUIViewController(context: Context) -> some UIViewController {
        
        let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
       // activityController.setValue("This is a preview of my activity view controller", forKey: "previewText")
        return activityController
    }
        
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
}
