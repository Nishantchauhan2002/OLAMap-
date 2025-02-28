//
//  Errors.swift
//  DroomApp
//
//  Created by Vikrant Rohilla on 06/08/21.
//  Copyright © 2021 DROOM. All rights reserved.
//

import Foundation

public protocol MyErrorProtocol: LocalizedError {
    var title: String? { get }
}

public struct NotURLError: MyErrorProtocol {
    public var title: String?
    public var errorDescription: String? { return _description }
    public var failureReason: String? { return _description }

    private var _description: String

    init(title: String?, description: String) {
        self.title = title ?? "Invalid parse to URL."
        self._description = description
    }
}

public struct InvalidCodableError: MyErrorProtocol {
    public var title: String?
    public var errorDescription: String? { return _description }
    public var failureReason: String? { return _description }

    private var _description: String

    init(title: String?, description: String) {
        self.title = title ?? "Invalid Codable Object."
        self._description = description
    }
}
