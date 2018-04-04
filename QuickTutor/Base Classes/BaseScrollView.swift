//
//  BaseScrollView.swift
//  QuickTutor
//
//  Created by QuickTutor on 2/26/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class BaseCollectionViewCell : UICollectionViewCell {
	public var touchStartView : (UIView & Interactable)? = nil
	
	override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		
		if let firstTouch = touches.first {
			let hitView = self.hitTest(firstTouch.location(in: self), with: event)
			
			if (hitView is Interactable) {
				print("BEGAN: INTERACTABLE")
				touchStartView = hitView as? (UIView & Interactable)
				touchStartView?.touchStart()
			} else {
				print("BEGAN: NOT INTERACTABLE")
			}
		}
	}
	
	override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesMoved(touches, with: event)
		
		if(touchStartView == nil) {
			print("MOVING")
		} else {
			if let firstTouch = touches.first {
				let hitView = self.hitTest(firstTouch.location(in: self), with: event)
				let previousView = self.hitTest(firstTouch.previousLocation(in: self), with: event)
				
				if ((touchStartView == hitView) && (previousView == hitView)) {
					print("DRAGGING ON START VIEW")
					touchStartView?.draggingOn()
				} else if (previousView == touchStartView) {
					print("DID DRAG OFF START VIEW")
					touchStartView?.didDragOff()
				} else if ((previousView != touchStartView) && (hitView == touchStartView)) {
					print("DID DRAG ON TO START VIEW")
					touchStartView?.didDragOn()
				} else {
					touchStartView?.draggingOff()
					print("DRAGGING OFF START VIEW")
				}
			}
		}
	}
	
	override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesEnded(touches, with: event)
		
		if(touchStartView == nil) {
			print("ENDED: NON INTERACTABLE")
		}
		else {
			if let firstTouch = touches.first {
				let hitView = self.hitTest(firstTouch.location(in: self), with: event)
				
				if (touchStartView == hitView) {
					print("ENDED: ON START")
					touchStartView?.touchEndOnStart()
				} else {
					touchStartView?.touchEndOffStart()
					touchStartView = nil
					print("ENDED: OFF START")
				}
			}
		}
		handleNavigation()
	}
	
	override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesCancelled(touches, with: event)
		
		if(touchStartView == nil) {
			print("CANCELLED: NON INTERACTABLE")
		} else {
			print("CANCELLED: INTERACTABLE")
			touchStartView?.touchCancelled()
		}
		
		touchStartView = nil
	}
	
	func handleNavigation() {}
}

class BaseScrollView : UIScrollView {
	
    public var touchStartView : (UIView & Interactable)? = nil
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if let firstTouch = touches.first {
            let hitView = self.hitTest(firstTouch.location(in: self), with: event)
            
            if (hitView is Interactable) {
                print("BEGAN: INTERACTABLE")
                touchStartView = hitView as? (UIView & Interactable)
                touchStartView?.touchStart()
            } else {
                print("BEGAN: NOT INTERACTABLE")
            }
        }
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        if(touchStartView == nil) {
            print("MOVING")
        } else {
            if let firstTouch = touches.first {
                let hitView = self.hitTest(firstTouch.location(in: self), with: event)
                let previousView = self.hitTest(firstTouch.previousLocation(in: self), with: event)
                
                if ((touchStartView == hitView) && (previousView == hitView)) {
                    print("DRAGGING ON START VIEW")
                    touchStartView?.draggingOn()
                } else if (previousView == touchStartView) {
                    print("DID DRAG OFF START VIEW")
                    touchStartView?.didDragOff()
                } else if ((previousView != touchStartView) && (hitView == touchStartView)) {
                    print("DID DRAG ON TO START VIEW")
                    touchStartView?.didDragOn()
                } else {
                    touchStartView?.draggingOff()
                    print("DRAGGING OFF START VIEW")
                }
            }
        }
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        if(touchStartView == nil) {
            print("ENDED: NON INTERACTABLE")
        }
        else {
            if let firstTouch = touches.first {
                let hitView = self.hitTest(firstTouch.location(in: self), with: event)
                
                if (touchStartView == hitView) {
                    print("ENDED: ON START")
                    touchStartView?.touchEndOnStart()
                } else {
                    touchStartView?.touchEndOffStart()
                    touchStartView = nil
                    print("ENDED: OFF START")
                }
            }
        }
        
        handleNavigation()
    }
    
    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        if(touchStartView == nil) {
            print("CANCELLED: NON INTERACTABLE")
        } else {
            print("CANCELLED: INTERACTABLE")
            touchStartView?.touchCancelled()
        }
        
        touchStartView = nil
    }
    
    func handleNavigation() {}
}
