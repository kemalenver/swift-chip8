//
//  ViewController.swift
//  CHIP8
//
//  Created by Kemal on 25/3/19.
//  Copyright © 2019 Kemal. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var chip8: CHIP8!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let romPath = Bundle.main.path(forResource: "pong", ofType: "ch8")!
        let romURL = URL(fileURLWithPath: romPath)
        let data: Data = try! Data(contentsOf: romURL)

        let rom: [Byte] = Array(data)

        self.chip8 = CHIP8(program: rom)

        let timer = Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { (timer) in
            self.chip8.step()
        }

    }

}

