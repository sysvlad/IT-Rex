//
//  DetailViewController.swift
//  TRex
//
//  Created by Sys on 3/24/18.
//  Copyright © 2018 Sys. All rights reserved.
//

import UIKit
import Photos

class DetailViewController: UIViewController {

    var assetCollection: PHAssetCollection!
    var photosAsset: PHFetchResult<PHAsset>!
    var index: Int = 0
    
    @IBOutlet weak var imageDetail: UIImageView!
    
    var image = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageDetail.image = image
       
    }


    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.hidesBarsOnTap = true    //!!Added Optional Chaining
        
        self.displayPhoto()
    }

    func displayPhoto(){
        // Set targetSize of image to iPhone screen size
        let screenSize: CGSize = UIScreen.main.bounds.size
        let targetSize = CGSize(width: screenSize.width, height: screenSize.height)
        
        let imageManager = PHImageManager.default()
        imageManager.requestImage(for: self.photosAsset[self.index], targetSize: targetSize, contentMode: .aspectFit, options: nil, resultHandler: {
            (result, info)->Void in
            self.imageDetail.image = result
        })
    }

}
