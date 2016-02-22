//
//  DetailViewController.swift
//  MyStuff
//
//  Created by Aniket Zamwar on 11/23/15.
//  Copyright © 2015 Aniket Zamwar. All rights reserved.
//

import UIKit
import MobileCoreServices

class DetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    var detailItem: MyWhatsit? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            if nameField != nil {
                nameField.text = detail.name
                locationField.text = detail.location
                imageView.image = detail.viewImage
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changedDetail(sender: AnyObject!) {
        if sender === nameField {
            detailItem?.name = nameField.text!
        } else if sender === locationField {
            detailItem?.location = locationField.text!
        }
    }
    
    @IBAction func choosePicture(_: AnyObject!) {
        if detailItem == nil {
            return
        }
        
        let hasPhotos = UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary)
        let hasCamera = UIImagePickerController.isSourceTypeAvailable(.Camera)
        
        switch (hasPhotos,hasCamera) {
            case (true,true):
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
                alert.addAction(UIAlertAction(title: "Take a Picture", style: .Default, handler: { (_) in self.presentImagePicker(.Camera)}))
                alert.addAction(UIAlertAction(title: "Choose a Photo", style: .Default, handler: { (_) in self.presentImagePicker(.PhotoLibrary)}))
                alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                if let popover = alert.popoverPresentationController {
                    popover.sourceView = imageView
                    popover.sourceRect = imageView.bounds
                    popover.permittedArrowDirections = [ .Up, .Down ]
                }
                presentViewController(alert, animated: true, completion: nil)
        case (true,false):
                presentImagePicker(.PhotoLibrary)
        case (false,true):
                presentImagePicker(.Camera)
        default: /* (false,false) */
            break
        }
    }
    
    func presentImagePicker(source: UIImagePickerControllerSourceType) {
        let picker = UIImagePickerController()
        picker.sourceType = source
        picker.mediaTypes = [kUTTypeImage as NSString as String]
        picker.delegate = self
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var image: UIImage! = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil {
            image = info[UIImagePickerControllerOriginalImage] as! UIImage
        }
        detailItem?.image = image
        imageView.image = image
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_: UIImagePickerController) {
            dismissViewControllerAnimated(true, completion: nil)
    }
    
}

