//
//  ViewController.swift
//  Siri-Demo
//
//  Created by xingle.li on 17/8/19.
//  Copyright © 2019 Lecoding. All rights reserved.
//

import UIKit
import Intents
import IntentsUI


class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        haveAddedShortcut { (have) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if !have {
                    self.addSiriButton(to: self.view)
                }
            }
        }
    }
    
    func haveAddedShortcut(completion: @escaping (Bool) -> Void) {
        INVoiceShortcutCenter.shared.getAllVoiceShortcuts { (shortcuts, error) in
            if let shortcuts = shortcuts, shortcuts.count > 0 {
                let count = shortcuts.filter({ $0.shortcut.intent is AccountInfoIntent }).count
                completion(count != 0)
            } else {
                completion(false)
            }
        }
    }
    
    
    func addSiriButton(to view: UIView) {
        if #available(iOS 12.0, *) {
            let intent = AccountInfoIntent()
            intent.suggestedInvocationPhrase = "Start ACH transfer"
            intent.amount = INCurrencyAmount(amount: 0, currencyCode: "USD")
            let shortcut = INShortcut(intent: intent)
            
            let button = INUIAddVoiceShortcutButton(style: .whiteOutline)
            button.shortcut = shortcut
            button.delegate = self
            button.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(button)
            view.centerXAnchor.constraint(equalTo: button.centerXAnchor).isActive = true
            view.centerYAnchor.constraint(equalTo: button.centerYAnchor).isActive = true
        }
        
    }
    

    func donateInteraction(){
        let intent = AccountInfoIntent()
        intent.suggestedInvocationPhrase = "Show my Accounts"
        let interaction = INInteraction(intent: intent, response: nil)

        interaction.donate { (error) in
            if error != nil {
                if let error = error as NSError? {
                    print("Interaction donation failed: \(error.description)")
                } else {
                    print("Successfully donated interaction")
                }
            }
        }
    }
}


extension ViewController: INUIEditVoiceShortcutViewControllerDelegate {
    public func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController,
                                         didUpdate voiceShortcut: INVoiceShortcut?,
                                         error: Error?) {
        if let error = error {
            print("error adding voice shortcut:\(error.localizedDescription)")
            return
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    public func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController,
                                         didDeleteVoiceShortcutWithIdentifier deletedVoiceShortcutIdentifier: UUID) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    public func editVoiceShortcutViewControllerDidCancel(_ controller: INUIEditVoiceShortcutViewController) {
        dismiss(animated: true, completion: nil)
    }
}

extension ViewController: INUIAddVoiceShortcutButtonDelegate {
    func present(_ addVoiceShortcutViewController: INUIAddVoiceShortcutViewController, for addVoiceShortcutButton: INUIAddVoiceShortcutButton) {
        
        addVoiceShortcutViewController.delegate = self
        addVoiceShortcutViewController.modalPresentationStyle = .formSheet
        present(addVoiceShortcutViewController, animated: true, completion: nil)
        
    }
    
    func present(_ editVoiceShortcutViewController: INUIEditVoiceShortcutViewController, for addVoiceShortcutButton: INUIAddVoiceShortcutButton) {
        
        editVoiceShortcutViewController.delegate = self
        editVoiceShortcutViewController.modalPresentationStyle = .formSheet
        present(editVoiceShortcutViewController, animated: true, completion: nil)
    }
}

extension ViewController: INUIAddVoiceShortcutViewControllerDelegate {
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
