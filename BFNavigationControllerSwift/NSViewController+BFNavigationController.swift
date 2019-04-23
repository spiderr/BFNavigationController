//
//  NSViewController+BFNavigationController.swift
//  BFNavigationControllerExample
//
//  Created by Patrick Twohig on 8/11/15.
//  Copyright (c) 2015 boxedfolder.com. All rights reserved.
//  Swift Port by https://github.com/spiderr
//

import Cocoa
import ObjectiveC

extension NSViewController {
    ///---------------------------------------------------------------------------------------
    /// @name Accessing the navigation controller.
    ///---------------------------------------------------------------------------------------

    private static var _navigationController: BFNavigationController?
    
    var navigationController: BFNavigationController? {
        get {
            return NSViewController._navigationController
        }
        set(newNavigationController) {
            NSViewController._navigationController = newNavigationController
        }
    }
}
