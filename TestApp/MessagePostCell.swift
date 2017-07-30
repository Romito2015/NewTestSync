//
//  MessagePostCell.swift
//  TestApp
//
//  Created by Roma Chopovenko on 7/28/17.
//  Copyright © 2017 Roma Chopovenko. All rights reserved.
//

import UIKit

class MessagePostCell: BaseCell {

    @IBOutlet weak var avaHolderImageView: UIImageView!
    
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var commentsCountLabel: UILabel!
    
    var isExpanded:Bool = false
    {
        didSet
        {
            if !isExpanded {
                self.messageLabel.numberOfLines = 3
                
            } else {
                self.messageLabel.numberOfLines = 0
            }
        }
    }
    
    override func prepareForReuse() {
        titleLabel.text = ""
        commentsCountLabel.text = ""
        messageLabel.text = ""
        dateLabel.text = ""
    }
}

extension MessagePostCell: PostCellProtocol {
    
    public func configureCell(withPost post: Post) {
        titleLabel.text = post.userName
        commentsCountLabel.text = "💬 \(post.commentsCount)"
        dateLabel.text = post.dateCreatedString
//        messageLabel.text = post.message
        
        self.mainImageView.imageUrl = post.imageURL
    }
}
