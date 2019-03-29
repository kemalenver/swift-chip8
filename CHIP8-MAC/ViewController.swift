//
//  ViewController.swift
//  CHIP8-MAC
//
//  Created by Kemal on 29/3/19.
//  Copyright © 2019 Kemal. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    var chip8: CHIP8!
    var timer: Timer!
    
    let ident =  NSUserInterfaceItemIdentifier(rawValue: "Cell")
    
    @IBOutlet var memoryCollectionView: NSCollectionView! {
        didSet {
            
            memoryCollectionView.register(MemoryCVItem.self,forItemWithIdentifier: self.ident)
            
            memoryCollectionView.backgroundColors = [NSColor.red, NSColor.blue]
            memoryCollectionView.delegate = self
            memoryCollectionView.dataSource = self
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()


        let romPath = Bundle.main.path(forResource: "pong", ofType: "ch8")!
        let romURL = URL(fileURLWithPath: romPath)
        let data: Data = try! Data(contentsOf: romURL)
        
        let rom: [Byte] = Array(data)
        
        self.chip8 = CHIP8(program: rom)
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { (timer) in
            
            self.chip8.step()
            if self.chip8.drawFlag {
            
            }
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

extension ViewController: NSCollectionViewDelegate, NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        
        return collectionView.makeItem(withIdentifier: self.ident, for: indexPath)
    }
    
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.chip8.memory.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        return NSSize(width: 40, height: 40)
    }
}
