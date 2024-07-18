//
//  EmailHelper.swift
//  iOS ChatGPT
//
//  Created by Otamurod Safarov on 17/07/24.
//

import MessageUI
import UIKit

class EmailHelper: NSObject, MFMailComposeViewControllerDelegate {
    public static let shared = EmailHelper()
    override private init() {}
    
    func sendEmail(subject: String, body: String, to: String) {
        guard MFMailComposeViewController.canSendMail() else {
            print("Mail services are not available")
            return
        }
        
        let picker = MFMailComposeViewController()
        picker.setSubject(subject)
        picker.setMessageBody(body, isHTML: true)
        picker.setToRecipients([to])
        picker.mailComposeDelegate = self
        
        if let topViewController = EmailHelper.getTopViewController() {
            topViewController.present(picker, animated: true, completion: nil)
        } else {
            print("Could not find the top view controller")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    static func getTopViewController() -> UIViewController? {
        var topViewController: UIViewController? = UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.rootViewController
        while let presentedViewController = topViewController?.presentedViewController {
            topViewController = presentedViewController
        }
        return topViewController
    }
}
