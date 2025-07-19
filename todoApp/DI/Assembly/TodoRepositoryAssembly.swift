//
//  TodoRepositoryAssembly.swift
//  todoApp
//
//  Created by 조영태 on 5/1/25.
//

import Foundation
import Moya
import Swinject

import Domain
import DataLayer

final class TodoRepositoryAssembly: Assembly {
    func assemble(container: Container) {
#if DEBUG
        // stub provider 등록
        container
            .register(
                NetworkManager<TodoAPI>.self,
                name: DataEnvironment.stub.rawValue
            ) {
                _ in return NetworkManager(.stub)
            }
            .inObjectScope(.container)
#endif
        // provider 등록
        container.register(
            NetworkManager<TodoAPI>.self,
            name: DataEnvironment.production.rawValue
        ) { _ in
            return NetworkManager(.production)
        }
        .inObjectScope(.container)
        
        // remote dataSource 등록
        container
            .register(TodoDataSourceProtocol.self) { (
                _,
                networkManger:NetworkManager<TodoAPI>
            ) in
                return TodoRemoteDataSource(networkManger)
            }
            .inObjectScope(.container)

        // local dataSource 등록
        container.register(TodoDataSourceProtocol.self) { _ in
            return TodoLocalDataSource()
        }.inObjectScope(.container)
        
        // Repository 등록
        container.register(TodoRepository.self) { (r, env: DataEnvironment) in
            let dataSource:TodoDataSourceProtocol = {
                switch env {
                case .local:
                    return container.resolveOrFail(TodoDataSourceProtocol.self)
                
                case .stub, .production:
                    let provider = container.resolveOrFail(
                        NetworkManager<TodoAPI>.self,
                        name: env.rawValue
                    )

                    return container
                        .resolveOrFail(
                            TodoDataSourceProtocol.self,
                            argument: provider
                        )
                }
            }()
            
            return TodoRepositoryImpl(dataSource)
        }.inObjectScope(.container)
    }
}
