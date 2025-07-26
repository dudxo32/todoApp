//
//  TodoRepositoryAssembly.swift
//  todoApp
//
//  Created by 조영태 on 5/1/25.
//

import Foundation
import Swinject
import Domain
import DataLayer

final class TodoRepositoryAssembly: Assembly {
    private var resolver: Container!

    func assemble(container: Container) {
        self.resolver = container
        // network 등록
        container
            .register(
                NetworkManager<TodoAPI>.self,
                name: DataEnvironment.stub.rawValue
            ) {
                _ in return NetworkManager(.stub)
            }
            .inObjectScope(.container)
  
        container.register(
            NetworkManager<TodoAPI>.self,
            name: DataEnvironment.production.rawValue
        ) { _ in
            return NetworkManager(.production)
        }
        .inObjectScope(.container)

        // remote dataSource 등록
        container
            .register(TodoDataSourceProtocol.self) {
                (
                    _,
                    networkManger: NetworkManager<TodoAPI>
                ) in
                return TodoRemoteDataSource(networkManger)
            }
            .inObjectScope(.container)

        // local dataSource 등록
        container.register(TodoDataSourceProtocol.self) { _ in
            return TodoLocalDataSource()
        }.inObjectScope(.container)

        // Repository 등록
        container.register(TodoRepository.self) { (r, ds: TodoDataSourceProtocol) in
            return TodoRepositoryImpl(ds)
        }.inObjectScope(.container)
    }
    
    private func makeNetworkManager(_ env:DataEnvironment) -> NetworkManager<TodoAPI>{
        switch env {
        case .local:
            preconditionFailure("local 은 올 수 없습니다.")
            
        case .stub, .production:
            return resolver.resolveOrFail(
                NetworkManager<TodoAPI>.self,
                name: env.rawValue
            )
        }
    }
    
    func makeDataSource(_ env: DataEnvironment = .local) -> TodoDataSourceProtocol {
        switch env {
        case .local:
            return resolver.resolveOrFail(TodoDataSourceProtocol.self)

        case .stub, .production:
            let networkManger = makeNetworkManager(env)

            return resolver.resolveOrFail(
                    TodoDataSourceProtocol.self,
                    argument: networkManger
                )
        }
    }
    
    func makeRepository(_ ds:TodoDataSourceProtocol) -> TodoRepository {
        return resolver.resolveOrFail(TodoRepository.self, argument: ds)
    }
}
