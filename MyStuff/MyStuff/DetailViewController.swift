//
//  DetailViewController.swift
//  MyStuff
//
//  Created by Aniket Zamwar on 11/23/15.
//  Copyright © 2015 Aniket Zamwar. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    
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
    
}

