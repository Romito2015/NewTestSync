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
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var commentsCountLabel: UILabel!
    
    
    
    override func prepareForReuse() {
        titleLabel.text = ""
        commentsCountLabel.text = ""
        dateLabel.text = ""
    }
}

extension MessagePostCell: PostCellProtocol {
    
    public func configureCell(withPost post: Post) {
        titleLabel.text = post.userName
        commentsCountLabel.text = "💬 \(post.commentsCount)"
        dateLabel.text = post.dateCreatedString
//        self.avatarImageView.loadImage(withUrl: post.imageURL)
        self.avatarImageView.image = post.remoteImage?.image
    }
}
