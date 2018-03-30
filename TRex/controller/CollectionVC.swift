//
//  CollectionVC.swift
//  TRex
//
//  Created by Sys on 3/23/18.
//  Copyright © 2018 Sys. All rights reserved.
//

import UIKit
import Photos
import CoreLocation
import MapKit

let reuseIdentifier = "cell"
let albumName = "T-Rex"

class CollectionVC: UIViewController, UIImagePickerControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate{
 
    var albumFound : Bool = false
    var assetCollection: PHAssetCollection = PHAssetCollection()
    var photosAsset: PHFetchResult<PHAsset>!
    var assetThumbnailSize:CGSize!
    var index: Int = 0
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
   
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Check if the folder exists, if not, create it
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let collection:PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
    
        if let first_Obj:AnyObject = collection.firstObject{
            self.albumFound = true
            self.assetCollection = first_Obj as! PHAssetCollection
        }else{
            var albumPlaceholder:PHObjectPlaceholder!
            NSLog("\nFolder \"%@\" does not exist\nCreating now...", albumName)
            PHPhotoLibrary.shared().performChanges({
                let request = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
                albumPlaceholder = request.placeholderForCreatedAssetCollection
            },
                                                   completionHandler: {(success:Bool, error:Error?) in
                                                    if(success){
                                                        print("Successfully created folder")
                                                        self.albumFound = true
                                                        let collection = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [albumPlaceholder.localIdentifier], options: nil)
                                                        self.assetCollection = collection.firstObject!
                                                    }else{
                                                        print("Error creating folder")
                                                        self.albumFound = false
                                                    }
            })
        }
    }
    
 
    override func viewWillAppear(_ animated: Bool) {
        
        if let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout{
            let cellSize = layout.itemSize
            self.assetThumbnailSize = CGSize(width: cellSize.width, height: cellSize.height)
       }

        self.photosAsset = PHAsset.fetchAssets(in: self.assetCollection, options: nil)
 
        self.collectionView.reloadData()
    }


    
    @IBAction func cameraTapped(_ sender: Any) {
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            let picker : UIImagePickerController = UIImagePickerController()
            picker.sourceType = UIImagePickerControllerSourceType.camera
            picker.delegate = self
            picker.allowsEditing = false
            self.present(picker, animated: true, completion: nil)
        }else{
            let picker : UIImagePickerController = UIImagePickerController()
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
            picker.delegate = self
            picker.allowsEditing = false
            self.present(picker, animated: true, completion: nil)
        }
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count: Int = 0
        if(self.photosAsset != nil){
            count = self.photosAsset.count
        }
        return count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionCell
        
        let asset: PHAsset = self.photosAsset[indexPath.item]
        
        PHImageManager.default().requestImage(for: asset, targetSize: self.assetThumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: {(result, info)in
            if let image = result {
                cell.setThumbnailImage(image)
            }
        })
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let actionSheet = UIAlertController(title: "Actions", message: "Choose Source", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Details", style: .default, handler: { (action: UIAlertAction) in
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let desVC = mainStoryboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
            
            
            let cell = collectionView.cellForItem(at: indexPath  as IndexPath) as! CollectionCell
            desVC.index = (self.collectionView.indexPath(for: cell)?.item)!
            desVC.photosAsset = self.photosAsset
            desVC.assetCollection = self.assetCollection
            
            
            
            self.navigationController?.pushViewController(desVC, animated: true)
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Map", style: .default, handler: { (action: UIAlertAction) in
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let desVC = mainStoryboard.instantiateViewController(withIdentifier: "MapVC") as! MapVC
            self.navigationController?.pushViewController(desVC, animated: true)
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action: UIAlertAction) in
            let cell = collectionView.cellForItem(at: indexPath  as IndexPath) as! CollectionCell
            self.index = (self.collectionView.indexPath(for: cell)!.item)
            PHPhotoLibrary.shared().performChanges({
                
                if let request = PHAssetCollectionChangeRequest(for: self.assetCollection){
                    request.removeAssets(at: IndexSet([self.index]))
                }
            }, completionHandler: {(success, error)in
                NSLog("\nDeleted Image -> %@", (success ? "Success":"Error!"))
                
                if(success){
                    DispatchQueue.main.async(execute: {
                        self.photosAsset = PHAsset.fetchAssets(in: self.assetCollection, options: nil)
                        self.collectionView.reloadData()
                        if(self.photosAsset.count == 0){
                            print("No Images Left!!")
                        }else{
                            if(self.index >= self.photosAsset.count){
                                self.index = self.photosAsset.count - 1
                            }
                        }
                    })
                }else{
                    print("Error")
                }
            })
        
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet,animated: true,completion: nil)
        
    }
    
     func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]){
        NSLog("in didFinishPickingMediaWithInfo")
        if let image: UIImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async(execute: {
                PHPhotoLibrary.shared().performChanges({
                    let createAssetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                    let assetPlaceholder = createAssetRequest.placeholderForCreatedAsset
                    if let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection, assets: self.photosAsset) {
                        albumChangeRequest.addAssets([assetPlaceholder!] as NSArray)
                    }
                }, completionHandler: {(success, error)in
                    DispatchQueue.main.async(execute: {
                        NSLog("Adding Image to Library -> %@", (success ? "Sucess":"Error!"))
                        picker.dismiss(animated: true, completion: nil)
                    })
                })
                
            })
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        picker.dismiss(animated: true, completion: nil)
    }
    
}
