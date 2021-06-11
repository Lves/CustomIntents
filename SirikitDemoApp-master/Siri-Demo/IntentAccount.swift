//
//  IntentAccount.swift
//  Siri-Demo
//
//  Created by LvesLi on 2021/5/31.
//  Copyright © 2021 Centelon. All rights reserved.
//

import Foundation

public class IntentAccount {
    public let accountNo: String
    public let amount: Double
    public let accountType: String
    
    public init(accountNo: String, amount: Double, accountType: String) {
        self.accountNo = accountNo
        self.amount = amount
        self.accountType = accountType
    }
    
}
