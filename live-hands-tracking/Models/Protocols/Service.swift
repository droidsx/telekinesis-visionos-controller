//
//  Service.swift
//
//  Created by Yuriy Nefedov on 16.05.2024.
//

import Foundation

public protocol Service {
    static var serviceName: String { get }
    
    func log(_ msg:String)
}

extension Service {
    static var serviceName: String { String(describing: self) }
    
    public func log(_ msg:String) {
        print("[\(Self.serviceName)]: \(msg)")
    }
}

