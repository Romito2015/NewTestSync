//
//  PostCellProtocol.swift
//  TestApp
//
//  Created by Roma Chopovenko on 7/29/17.
//  Copyright © 2017 Roma Chopovenko. All rights reserved.
//

import UIKit

protocol PostCellProtocol {
    weak var mainImageView: UIImageView! {get}
    func configureCell(withPost post: Post)
}
