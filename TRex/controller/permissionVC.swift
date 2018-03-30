//
//  permissionVC.swift
//  TRex
//
//  Created by Sys on 3/23/18.
//  Copyright © 2018 Sys. All rights reserved.
//

import UIKit
import PermissionsService


extension permissionVC: Permissible {}

struct CameraMessages: ServiceMessages {
    
    let deniedTitle = "Access denied"
    let deniedMessage = "You can enable access to camera in Privacy Settings"
    let restrictedTitle = "Access restricted"
    let restrictedMessage = "Access to camera is restricted"
    
}

class permissionVC: UIViewController {
    
    @IBOutlet weak var locationBtn: UIButton!
    @IBOutlet weak var cameraBtn: UIButton!
    
    var locationBool: Bool = false
    var cameraBool: Bool = false
    
    
let configCamera = DefaultConfiguration(with: CameraMessages())
 let configLocation = LocationConfiguration(.always)


    
    override func viewDidLoad() {
        super.viewDidLoad()
 
    skipPersistanceScreen ()
  
    }
    
    
    func goToNextViewController() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let navigationVC = storyboard.instantiateViewController(withIdentifier: "navigationVC") as! navigationVC
        self.present(navigationVC, animated: false, completion: nil)
    }
        
    @IBAction func locationPremission(_ sender: Any) {
        Permission<Location>.prepare(for: self, with: configLocation) { (granted) in
            if granted {
                self.locationBtn.backgroundColor = UIColor.green
                self.locationBool = true
                if self.locationBool == true && self.cameraBool == true {
                    self.goToNextViewController()
                }else{
                    print("Error")
                }
            } else {
                print("Error....")
                self.locationBool = false
                self.locationBtn.backgroundColor = UIColor.red
            }
            
        }
    }
    
    @IBAction func cameraPermission(_ sender: Any) {
        Permission<Camera>.prepare(for: self, with: configCamera) { (granted) in
            if granted {
                self.cameraBool = true
                self.cameraBtn.backgroundColor = UIColor.green
                if self.locationBool == true && self.cameraBool == true {
                    self.goToNextViewController()
                }else{
                    print("Error")
                }
            } else {
                print("Error....")
                self.cameraBool = false
                self.cameraBtn.backgroundColor = UIColor.red
            }
            
        }
    }
    
    func skipPersistanceScreen (){
        Permission<Location>.prepare(for: self, with: configLocation) { (granted) in
            if granted {
                Permission<Camera>.prepare(for: self, with: self.configCamera) { (granted) in
                    if granted {
                        Permission<Gallery>.prepare(for: self, callback: { (granted) in
                            if granted {
                                self.goToNextViewController()
                            } else {
                                
                            }
                        })
                        
                    }else{
                        print("Tap Camera")
                    }
            }
            }else{
                print("Tap Location")
            }
        }

    }
    
}
