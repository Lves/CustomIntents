//
//  AccountManager.swift
//  Siri-Demo
//
//  Created by LvesLi on 2021/5/31.
//  Copyright © 2021 Centelon. All rights reserved.
//

import Foundation

public struct AccountManager {
    public var account: IntentAccount?
    public static var shared = AccountManager()
}
