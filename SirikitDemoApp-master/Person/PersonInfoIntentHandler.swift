//
//  PersonIntentHandler.swift
//  Person
//
//  Created by xingle.li on 21/9/19.
//  Copyright © 2019 Lecoding. All rights reserved.
//

import Foundation
import LocalAuthentication
import Intents

enum TransferType {
    case ach
    case wire
}


@available(iOS 13.0, macOS 10.16, watchOS 6.0, *)
class AccountInfoIntentHandler : NSObject, AccountInfoIntentHandling {
    
    class Manager {
        static var haveLogedin: Bool = false
        static var haveError: Bool = false
        static var transferType: TransferType = .ach
    }
    
    func handle(intent: AccountInfoIntent, completion: @escaping (AccountInfoIntentResponse) -> Void) {
        // get account
        let response = AccountInfoIntentResponse(code: .success, userActivity: nil)
        response.amount = intent.amount
        response.payee = intent.payee
        response.note = intent.note
        completion(response)
    }
    
    func confirm(intent: AccountInfoIntent, completion: @escaping (AccountInfoIntentResponse) -> Void) {
        if Manager.haveError {
            let activity = NSUserActivity(activityType: "AccountInfoIntent")
            activity.userInfo = ["hello":"123"]
            completion(AccountInfoIntentResponse(code: .continueInApp, userActivity: activity))
        } else {
            let response = AccountInfoIntentResponse(code: .ready, userActivity: nil)
            response.amount = intent.amount
            response.payee = intent.payee
            response.note = intent.note
            completion(response)
        }
    }
    func resolveNote(for intent: AccountInfoIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
//        completion(INStringResolutionResult.disambiguation(with: ["Transfer","Send"]))
//        completion(INStringResolutionResult.confirmationRequired(with: "Transfer"))
        guard !Manager.haveError else {
            completion(INStringResolutionResult.notRequired())
            return
        }
        guard let note = intent.note else {
            completion(INStringResolutionResult.needsValue())
            return
        }
        completion(INStringResolutionResult.success(with: note))
    }
    func resolvePaymentMethod(for intent: AccountInfoIntent, with completion: @escaping (INPaymentMethodResolutionResult) -> Void) {
        
        if Manager.haveLogedin == false {
            login { (success) in
                if success {
                    Manager.haveLogedin = true
                    if let paymentMethod = intent.paymentMethod {
                        completion(INPaymentMethodResolutionResult.success(with: paymentMethod))
                    } else {
                        completion(INPaymentMethodResolutionResult.needsValue())
                    }
                } else {
                    completion(INPaymentMethodResolutionResult.unsupported())
                }
            }
        } else {
            if let paymentMethod = intent.paymentMethod {
                completion(INPaymentMethodResolutionResult.success(with: paymentMethod))
            } else {
                completion(INPaymentMethodResolutionResult.needsValue())
            }
        }
    }
    
    @available(iOSApplicationExtension 14.0, *)
    func providePaymentMethodOptionsCollection(for intent: AccountInfoIntent, with completion: @escaping (INObjectCollection<INPaymentMethod>?, Error?) -> Void) {
        let methods = [INPaymentMethod(type: INPaymentMethodType.checking, name: "Checking(001)", identificationHint: "001", icon: nil),
                       INPaymentMethod(type: INPaymentMethodType.savings, name: "Savings(002)", identificationHint: "002", icon: nil),
                       INPaymentMethod(type: INPaymentMethodType.credit, name: "Credit(021)", identificationHint: "003", icon: nil)]
        
        let collection = INObjectCollection(items: methods)
        completion(collection, nil)
    }
    
    func resolveOtp(for intent: AccountInfoIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        guard !Manager.haveError else {
            completion(INStringResolutionResult.notRequired())
            return
        }
        //TODO: send otp
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            // check otp
            if intent.otp == nil {
                completion(INStringResolutionResult.needsValue())
            } else {
                completion(INStringResolutionResult.success(with: intent.otp ?? ""))
            }
        }
    }
    
    func resolveAmount(for intent: AccountInfoIntent, with completion: @escaping (AccountInfoAmountResolutionResult) -> Void) {
//        completion(AccountInfoAmountResolutionResult.unsupported(forReason: AccountInfoAmountUnsupportedReason.negativeNumbersNotSupported))
        
//        completion(AccountInfoAmountResolutionResult.success(with: INCurrencyAmount(amount: 99, currencyCode: "USD")))
//        completion(AccountInfoAmountResolutionResult.disambiguation(with:
//                                                                        [INCurrencyAmount(amount: 999, currencyCode: "USD"),
//                                                                         INCurrencyAmount(amount: 99, currencyCode: "USD"),
//                                                                         INCurrencyAmount(amount: 9, currencyCode: "USD")]))
        
//        Manager.haveError = true
//        completion(AccountInfoAmountResolutionResult.notRequired())

        if intent.amount == nil || intent.amount?.amount?.doubleValue ?? 0 == 0 {
            completion(AccountInfoAmountResolutionResult.needsValue())
        } else if let amount = intent.amount {
            completion(AccountInfoAmountResolutionResult.success(with: INCurrencyAmount(amount: 99, currencyCode: "USD")))
//            completion(AccountInfoAmountResolutionResult.success(with: amount))
        }
    }
    
    // frequency
    func resolveFrequency(for intent: AccountInfoIntent, with completion: @escaping (FrequencyResolutionResult) -> Void) {
        guard Manager.transferType == .ach else {
            completion(FrequencyResolutionResult.notRequired())
            return
        }
        if intent.frequency != .unknown {
            completion(FrequencyResolutionResult.success(with: intent.frequency))
        } else {
            completion(FrequencyResolutionResult.needsValue())
        }
    }
    
    // Send on
    func resolveSendOn(for intent: AccountInfoIntent, with completion: @escaping (INDateComponentsResolutionResult) -> Void) {
        guard Manager.transferType == .ach else {
            completion(INDateComponentsResolutionResult.notRequired())
            return
        }
        if let sendOn = intent.sendOn {
            completion(INDateComponentsResolutionResult.success(with: sendOn))
        } else {
            let dates = [DateComponents( year: 2021, month: 6, day: 11),
                        DateComponents( year: 2021, month: 6, day: 12),
                        DateComponents( year: 2021, month: 6, day: 13)]
            completion(INDateComponentsResolutionResult.disambiguation(with: dates))
        }
    }
    
    func resolvePayee(for intent: AccountInfoIntent, with completion: @escaping (INPersonResolutionResult) -> Void) {
        selectPayee(for: intent, with: completion)
    }
    
    private func selectPayee(for intent: AccountInfoIntent, with completion: @escaping (INPersonResolutionResult) -> Void) {
        let persons = [INPerson(personHandle: INPersonHandle(value: "+86 15210951027", type: .phoneNumber, label: nil), nameComponents: nil, displayName: "Tom", image: nil, contactIdentifier: "contactId", customIdentifier: "CusId"),
                       INPerson(personHandle: INPersonHandle(value: "+1 28810951023", type: .phoneNumber, label: nil), nameComponents: nil, displayName: "David", image: nil, contactIdentifier: "contactId", customIdentifier: "CusId")]
        
        guard let payee = intent.payee ,  payee.personHandle != nil else {
            completion(INPersonResolutionResult.disambiguation(with: persons))
            return
        }
        Manager.transferType = payee.displayName == "Tom" ? .ach : .wire
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
