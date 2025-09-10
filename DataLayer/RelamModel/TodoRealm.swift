//
//  TodoRealm.swift
//  todoApp
//
//  Created by 조영태 on 3/11/25.
//

import Foundation
internal import RealmSwift

class TodoRealm: Object {
    @Persisted(primaryKey: true) var _id: String
    @Persisted var title: String
    @Persisted var date: Date
    @Persisted var contents: String
    @Persisted var isDone: Bool

    
    convenience init(title: String, date: Date, contents: String) {
        self.init()
        self._id = UUID().uuidString
        self.title = title
        self.date = date
        self.contents = contents
        self.isDone = false
    }
}
public enum RealmConfig {
    static public func setConfig () {

        let config = Realm.Configuration(
            schemaVersion: 2, //
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 2 {
                    // 예: isDone 프로퍼티가 새로 생겼다면 초기값 세팅도 가능
                    migration.enumerateObjects(ofType: TodoRealm.className()) { oldObject, newObject in
                        newObject?["isDone"] = false
                    }
                }
            }
        )
        Realm.Configuration.defaultConfiguration = config

    }
//    public static var configuration: Realm.Configuration {
//        return Realm.Configuration(
//            schemaVersion: 2,
//            migrationBlock: { migration, oldSchemaVersion in
//                if oldSchemaVersion < 2 {
//                    // TodoRealm의 className은 문자열로 접근 가능
//                    migration.enumerateObjects(ofType: "TodoRealm") { _, newObject in
//                        newObject?["isDone"] = false
//                    }
//                }
//            }
//        )
//    }
}
