//
//  ViewController.swift
//  LESegmentedControl
//
//  Created by dml1630@163.com on 09/22/2020.
//  Copyright (c) 2020 dml1630@163.com. All rights reserved.
//

import UIKit
import LESegmentControl

class ViewController: UIViewController,LESegmentedControlDelegate {

    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let segmentedControl = LESegmentedControl(frame: CGRect(x: 20, y: 100, width: UIScreen.main.bounds.width - 40, height: 60), style: .dynamic)
        segmentedControl.delefate = self
//        segmentedControl.selectionStyle = .stripe
        self.view.addSubview(segmentedControl)
        segmentedControl.reloadData()
    }

    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

}

extension ViewController {
    
    func numberOfTitles(in segmentedControl: LESegmentedControl) -> [Any] {
//        return ["美食","电影","摄影"]
         return ["美大叔大婶多食","电影","摄影","人物","动物","抽象","美食","电影","摄影","人物","动物","抽象"]
    }
    
    func segmented(segment: LESegmentedControl, didSelectRowAtIndex index: Int) {
        print("========>\(index)")
    }
    

    func selectionStripeIndicatorEdgeInset(segmentedControl: LESegmentedControl) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    func segmentEdgeInset(segmentedControl: LESegmentedControl) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    func selectSegmentAttributes(segmentedControl: LESegmentedControl) -> [NSAttributedString.Key : Any]? {
        
       return [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 20),NSAttributedString.Key.foregroundColor:UIColor.red]
        
    }
 
}
