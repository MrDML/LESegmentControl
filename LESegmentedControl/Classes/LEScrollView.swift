//
//  LEScrollView.swift
//  LESegmentControl
//
//  Created by leon on 2020/9/22.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class LEScrollView: UIScrollView {

    
     override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.isDragging == false {
           self.next?.touchesBegan(touches, with: event)
        }else{
            super.touchesBegan(touches, with: event)
        }
    }
    
     override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if self.isDragging == false {
            self.next?.touchesMoved(touches, with: event)
        }else{
            super.touchesMoved(touches, with: event)
        }
    }
    
    
     override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if self.isDragging == false {
            self.next?.touchesEnded(touches, with: event)
        }else{
            self.next?.touchesEnded(touches, with: event)
        }
        
    }

    
    
}
