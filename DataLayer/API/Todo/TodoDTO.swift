//
//  File.swift
//  todoApp
//
//  Created by 조영태 on 3/5/25.
//

import Foundation

// MARK: - Response
public struct TodoResponse {
    public struct Fetch: Codable {
        let id: String
        let title: String
        let date: Date
        let contents: String
        let isDone: Bool
    }
    
    public struct Write: Codable {
        let id: String
        let title: String
        let date: Date
        let contents: String
        let isDone: Bool
    }
    
    public struct Delete: Codable {
        let id: String
    }
    
    public struct Update: Codable {
        let id: String
        let title: String
        let date: Date
        let contents: String
        let isDone: Bool
    }
}

// MARK: - Request
public struct TodoRequest{
    public struct Write: Encodable {
        let title:String
        let date:Date
        let contents:String
        
        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(title, forKey: .title)
            try container.encode(contents, forKey: .contents)
            
            let formatter = ISO8601DateFormatter()
            let dateString = formatter.string(from: date)
            try container.encode(dateString, forKey: .date)
        }
        
        enum CodingKeys: String, CodingKey {
            case title, date, contents
        }
    }
    
    public struct Delete: Encodable {
        let id:String
    }
    
    public struct Update: Encodable {
        let id:String
        let title:String
        let contents:String
        let isDone:Bool
        let date:Date
        
        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(id, forKey: .id)
            try container.encode(title, forKey: .title)
            try container.encode(contents, forKey: .contents)
            try container.encode(isDone, forKey: .isDone)
            
            let formatter = ISO8601DateFormatter()
            let dateString = formatter.string(from: date)
            try container.encode(dateString, forKey: .date)
        }
        
        enum CodingKeys: String, CodingKey {
            case id, title, contents, isDone, date
        }
    }
}
