//
//  PhotoPostCell.swift
//  TestApp
//
//  Created by Roma Chopovenko on 7/28/17.
//  Copyright © 2017 Roma Chopovenko. All rights reserved.
//

import UIKit

class PhotoPostCell: BaseCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var placeholderImageView: UIImageView!
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var likesCountLabel: UILabel!
    @IBOutlet weak var commentsCountLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    
    override func prepareForReuse() {
        titleLabel.text = ""
        photoImageView.image = nil
        likesCountLabel.text = ""
        commentsCountLabel.text = ""
        dateLabel.text = ""
    }
}

extension PhotoPostCell: PostCellProtocol {
    
    public func configureCell(withPost post: Post) {
        titleLabel.text = post.userName
        likesCountLabel.text = "♥️ \(post.likesCount ?? 0)"
        commentsCountLabel.text = "💬 \(post.commentsCount)"
        dateLabel.text = post.dateCreatedString
//        self.photoImageView.loadImage(withUrl: post.imageURL)
        
        self.photoImageView.image = post.remoteImage?.image
    }
}
