//
//  SendPaymentIntentHandler.swift
//  Person
//
//  Created by LvesLi on 2021/5/31.
//  Copyright © 2021 Centelon. All rights reserved.
//

import Foundation
import Intents
import LocalAuthentication

class VLSendPaymentIntentHandlering: NSObject, INSendPaymentIntentHandling {
    class Manager {
        static var haveLogedin: Bool = false
    }
    func handle(intent: INSendPaymentIntent, completion: @escaping (INSendPaymentIntentResponse) -> Void) {
        // Perform the expected action. Report back to Siri
        // This is the place to call your service, update database, or whatever you need to do.
        let ac = NSUserActivity(activityType: "INSendPaymentIntent")
        ac.userInfo = ["hello":"123"]
        let needOTP = false
        if needOTP {
            completion(INSendPaymentIntentResponse.init(code: .failureRequiringAppLaunch, userActivity: ac))
        } else {
            completion(INSendPaymentIntentResponse.init(code: .success, userActivity: nil))
        }
    }
    
    func confirm(intent: INSendPaymentIntent,completion: @escaping (INSendPaymentIntentResponse) -> Void) {
        // Tell Siri how it went. Validate with user the information is correct before sending
        let response = INSendPaymentIntentResponse(code: .ready, userActivity: nil)
        response.paymentRecord = INPaymentRecord(
            payee: intent.payee,
            payer: nil,
            currencyAmount: intent.currencyAmount,
            paymentMethod: nil,
            note: intent.note,
            status: .pending
        )
        completion(response)
    }
    
    func resolveCurrencyAmount(for intent: INSendPaymentIntent, with completion: @escaping (INSendPaymentCurrencyAmountResolutionResult) -> Void) {
        // Validate & clarify currency parameter
        let amount = intent.currencyAmount?.amount ?? 0
        completion(
          INSendPaymentCurrencyAmountResolutionResult.success(with: INCurrencyAmount(amount: amount, currencyCode: "USD" ))
        )
    }
    
    func resolveNote(for intent: INSendPaymentIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        // Validate & clarify note parameter
        guard let note = intent.note else {
            completion(INStringResolutionResult.needsValue())
            return
        }
        completion(INStringResolutionResult.success(with: note))
    }
    
    func resolvePayee(for intent: INSendPaymentIntent, with completion: @escaping (INPersonResolutionResult) -> Void) {
        if Manager.haveLogedin == false {
            login { (success) in
                if success {
                    Manager.haveLogedin = true
                    self.selectPayee(for: intent, with: completion)
                } else {
                    completion(INPersonResolutionResult.unsupported())
                }
            }
        } else {
            selectPayee(for: intent, with: completion)
        }
    }
    
    //MARK: - private
    
    private func selectPayee(for intent: INSendPaymentIntent, with completion: @escaping (INPersonResolutionResult) -> Void) {
        let persons = [INPerson(personHandle: INPersonHandle(value: "+86 15210951027", type: .phoneNumber, label: nil), nameComponents: nil, displayName: "Tom", image: nil, contactIdentifier: "contactId", customIdentifier: "CusId"),
                       INPerson(personHandle: INPersonHandle(value: "+1 28810951023", type: .phoneNumber, label: nil), nameComponents: nil, displayName: "David", image: nil, contactIdentifier: "contactId", customIdentifier: "CusId")]
        
        guard let payee = intent.payee else {
            completion(INPersonResolutionResult.disambiguation(with: persons))
            return
        }
        if payee.personHandle == nil {
            completion(INPersonResolutionResult.disambiguation(with: persons))
            return
        }
        completion(INPersonResolutionResult.success(with: payee))
    }
    
    
    func login(completion: @escaping (Bool) -> Void)  {
        let context = LAContext()
        context.localizedFallbackTitle = ""
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "loginReason") { success, evaluateError in
            completion(success)
        }
    }

}
