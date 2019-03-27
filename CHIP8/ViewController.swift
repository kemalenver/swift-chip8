//
//  ViewController.swift
//  CHIP8
//
//  Created by Kemal on 25/3/19.
//  Copyright © 2019 Kemal. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var memoryCollectionView: UICollectionView! {
        didSet {
            let nib = UINib(nibName: "MemoryCellCollectionViewCell", bundle: nil)
            memoryCollectionView.register(nib, forCellWithReuseIdentifier: "memory_cell")
            memoryCollectionView.dataSource = self
            memoryCollectionView.delegate = self
        }
    }

    var chip8: CHIP8!
    var timer: Timer!

    override func viewDidLoad() {
        super.viewDidLoad()

        let romPath = Bundle.main.path(forResource: "pong", ofType: "ch8")!
        let romURL = URL(fileURLWithPath: romPath)
        let data: Data = try! Data(contentsOf: romURL)

        let rom: [Byte] = Array(data)

        self.chip8 = CHIP8(program: rom)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)



        self.timer = Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { (timer) in

            self.chip8.step()
            if self.chip8.drawFlag {
                // Update screen
            }

//            self.memoryCollectionView.reloadData()
        }
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let value = self.chip8.memory[indexPath.row]

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "memory_cell", for: indexPath)

        (cell as? MemoryCellCollectionViewCell)?.label.text = String(format:"%02X", value)

        if self.chip8.pc == indexPath.row || self.chip8.pc + 1 == indexPath.row {
            cell.backgroundColor = UIColor.red
        } else {
            cell.backgroundColor = UIColor.white
        }
        return cell
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.chip8.memory.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width / 32, height: 20)
    }
}
