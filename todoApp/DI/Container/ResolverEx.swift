//
//  ResolverEx.swift
//  todoApp
//
//  Created by 조영태 on 7/25/25.
//

import Foundation
import Swinject

extension Resolver {
    func resolveOrFail<Service>(
        _ serviceType: Service.Type, name: String? = nil
    ) -> Service {
        guard let resolved = self.resolve(serviceType, name: name) else {
            preconditionFailure(
                #function + "❌ Failed to resolve: \(serviceType)")
        }
        return resolved
    }

    func resolveOrFail<Service, Arg>(
        _ serviceType: Service.Type, argument: Arg, name: String? = nil
    ) -> Service {
        guard
            let resolved = self.resolve(
                serviceType, name: name, argument: argument)
        else {
            preconditionFailure(
                #function
                    + "❌ Failed to resolve: \(serviceType) with argument: \(Arg.self)"
            )
        }
        return resolved
    }

    func resolveOrFail<Service, Arg1, Arg2>(
        _ serviceType: Service.Type, arguments arg1: Arg1, _ arg2: Arg2,
        name: String? = nil
    ) -> Service {
        guard
            let resolved = self.resolve(
                serviceType, name: name, arguments: arg1, arg2)
        else {
            preconditionFailure(
                #function
                    + "❌ Failed to resolve: \(serviceType) with arguments: \(Arg1.self), \(Arg2.self)"
            )
        }
        return resolved
    }
    
    func resolveOrFail<Service, Arg1, Arg2, Arg3>(
        _ serviceType: Service.Type, arguments arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3,
        name: String? = nil
    ) -> Service {
        guard
            let resolved = self.resolve(
                serviceType, name: name, arguments: arg1, arg2, arg3)
        else {
            preconditionFailure(
                #function
                    + "❌ Failed to resolve: \(serviceType) with arguments: \(Arg1.self), \(Arg2.self), \(Arg3.self)"
            )
        }
        return resolved
    }
}
