//
//  ViewController.swift
//  ContactTest
//
//  Created by CuSO4 on 2019/6/10.
//  Copyright © 2019 CuSO4. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    @IBAction func pick(_ sender: Any) {
        
        
        ContactTool.pickContact(context: self) { (info) in
            print(info as Any)
        }
        
    }
    
    
}

