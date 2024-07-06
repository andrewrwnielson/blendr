//
//  Credentials.swift
//  blendr
//
//  Created by Andrew Nielson on 7/3/24.
//

import Foundation

struct Credentials {
    var username: String
    var password: String
}

enum KeychainError: Error {
    case noPassword
    case unexpectedPasswordData
    case unhandledError(status: OSStatus)
}
