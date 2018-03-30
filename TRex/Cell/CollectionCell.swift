//
//  CollectionCell.swift
//  TRex
//
//  Created by Sys on 3/24/18.
//  Copyright © 2018 Sys. All rights reserved.
//

import UIKit

class CollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func setThumbnailImage(_ thumbnailImage: UIImage){
        self.imageView.image = thumbnailImage
    }
}
