//
//  Post.swift
//  TestApp
//
//  Created by Roma Chopovenko on 7/29/17.
//  Copyright © 2017 Roma Chopovenko. All rights reserved.
//

import Foundation

public final class Post {
    
    internal struct Keys {
        static let id               = "identifier"
        static let type             = "type"
        static let userName         = "userName"
        static let imageURL         = "imageURL"
        static let message          = "message"
        static let commentsCount    = "commentsCount"
        static let dateCreated      = "dateCreated"
    }
    
    // MARK: Instance Properties
    public let identifier: Int
    public let type: PostType
    public let userName: String
    public let imageURL: NSURL?
    
    public let message: String?
    public let commentsCount: Int
    public let dateCreated: Date?
    public let dateCreatedString: String
    public let likesCount: Int?
    
    
    public enum PostType: String {
        case photoPost
        case messagePost
    }
    
    public init?(dictionary: [String : Any]) {
        
        
        let message: String?
        if let messageString = dictionary[Keys.message] as? String {
            message = messageString
        } else {
            message = nil
        }
        
        guard let identifier = dictionary[Keys.id] as? Int,
            let rawPost = dictionary[Keys.type] as? String,
            let type = PostType(rawValue: rawPost),
            let userName = dictionary[Keys.userName] as? String,
            let commentsCount = dictionary[Keys.commentsCount] as? Int,
            let dateCreated = dictionary[Keys.dateCreated] as? Date
            else {
                return nil
        }
        
        self.identifier = identifier
        self.type = type
        self.userName = userName
        self.message = message
        self.commentsCount = commentsCount
        
        let imageURL: NSURL?
        
        if let imageURLString = dictionary[Keys.imageURL] as? String  {
            imageURL = NSURL(string: imageURLString)
            
        } else {
            imageURL = nil
        }
        
        self.imageURL = imageURL
        self.dateCreated = dateCreated
        self.dateCreatedString = dateCreated.toString()
        
        if self.type == .photoPost {
            self.likesCount = Int(arc4random_uniform(20) + 1)
        } else {
            self.likesCount = nil
        }
    }

    public class func array(dictArray: [[String : Any]]) -> [Post] {
        return dictArray.flatMap{ Post(dictionary: $0)}
    }
    
}
