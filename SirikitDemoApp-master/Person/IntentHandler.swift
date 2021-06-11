//
//  IntentHandler.swift
//  Person
//
//  Created by xingle.li on 17/8/19.
//  Copyright © 2019 Lecoding. All rights reserved.
//

import Intents

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        if intent is INSendPaymentIntent {
            return VLSendPaymentIntentHandlering()
        } else {
            if #available(iOS 13.0, *) {
                if intent is AccountInfoIntent {
                    return AccountInfoIntentHandler()
                }
            }
        }
        return self
    }
}
