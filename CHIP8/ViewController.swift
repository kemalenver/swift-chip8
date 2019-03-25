//
//  ViewController.swift
//  CHIP8
//
//  Created by Kemal on 25/3/19.
//  Copyright © 2019 Kemal. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let chip8 = CHIP8(program: [])
        
    }

}

