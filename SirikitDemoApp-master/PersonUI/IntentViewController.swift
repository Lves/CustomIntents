//
//  IntentViewController.swift
//  PersonUI
//
//  Created by xingle.li on 17/8/19.
//  Copyright © 2019 Lecoding. All rights reserved.
//

import IntentsUI

// As an example, this extension's Info.plist has been configured to handle interactions for INSendMessageIntent.
// You will want to replace this or add other intents as appropriate.
// The intents whose interactions you wish to handle must be declared in the extension's Info.plist.

// You can test this example integration by saying things to Siri like:
// "Send a message using <myApp>"

class IntentViewController: UIViewController, INUIHostedViewControlling, INUIHostedViewSiriProviding{
    // comfirm view
    @IBOutlet var confirmView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var payeeLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!
    
    // succcess view
    @IBOutlet var sucessView: UIView!
    @IBOutlet weak var successTitleLabel: UILabel!
    @IBOutlet weak var successSubTitleLabel: UILabel!
    @IBOutlet weak var sucessNoteLabel: UILabel!
    
    var displaysPaymentTransaction: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
        
    // MARK: - INUIHostedViewControlling
    
    // Prepare your view controller for the interaction to handle.
    func configureView(for parameters: Set<INParameter>, of interaction: INInteraction, interactiveBehavior: INUIInteractiveBehavior, context: INUIHostedViewContext, completion: @escaping (Bool, Set<INParameter>, CGSize) -> Void) {
        if let response = interaction.intentResponse as? AccountInfoIntentResponse {
//            for view in view.subviews {
//                view.removeFromSuperview()
//            }
            // Different UIs can be displayed depending if the intent is in the confirmation phase or the handle phase.
            var desiredSize = CGSize.zero
            switch interaction.intentHandlingStatus {
            case .ready:
                desiredSize = displayOverview(for: response)
            case .success:
                desiredSize = displaySucccessView(for: response)
            default:
                break
            }
            completion(true, parameters, desiredSize)
            return
        }
        completion(true, parameters, self.desiredSize)
    }
    
    var desiredSize: CGSize {
        return self.extensionContext!.hostedViewMaximumAllowedSize
    }
    
    /// - Returns: Desired size of the view
    private func displayOverview(for response: AccountInfoIntentResponse?) -> CGSize {
//        view.addSubview(confirmView)
        sucessView.isHidden = true
        confirmView.isHidden = false
        titleLabel.text = "Confirm"
        payeeLabel.text = "Send to \(response?.payee?.displayName ?? "")"
        amountLabel.text = "$\(response?.amount?.amount?.doubleValue ?? 0)"
        noteLabel.text = response?.note ?? ""
        
        let width = self.desiredSize.width
        let frame = CGRect(origin: .zero, size: CGSize(width: width, height: 189))
        confirmView.frame = frame
        return frame.size
    }
    
    private func displaySucccessView(for response: AccountInfoIntentResponse?) -> CGSize {
//        view.addSubview(sucessView)
        sucessView.isHidden = false
        confirmView.isHidden = true
        successTitleLabel.text = "Success"
        successSubTitleLabel.text = "Send \(response?.payee?.displayName ?? "") $\(response?.amount?.amount?.doubleValue ?? 0)"
        sucessNoteLabel.text = response?.note ?? ""
        let width = self.desiredSize.width
        let frame = CGRect(origin: .zero, size: CGSize(width: width, height: 145))
        sucessView.frame = frame
        return frame.size
    }

}
