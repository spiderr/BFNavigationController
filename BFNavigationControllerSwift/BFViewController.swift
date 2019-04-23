//
//  BFViewController.swift
//
//  Created by Heiko Dreyer on 05/11/12.
//  Copyright (c) 2012 boxedfolder.com. All rights reserved.
//  Swift Port by https://github.com/spiderr
//

import Foundation

@objc protocol BFViewController: NSObjectProtocol {
    ///---------------------------------------------------------------------------------------
    /// @name Responding to View Events
    ///---------------------------------------------------------------------------------------
    /**
     *  Notifies the view controller that its view is about to be added to a view hierarchy.
     */
    @objc optional func viewWillAppear(_ animated: Bool)
    /**
     *  Notifies the view controller that its view was added to a view hierarchy.
     */
    @objc optional func viewDidAppear(_ animated: Bool)
    /**
     *  Notifies the view controller that its view is about to be removed from a view hierarchy.
     */
    @objc optional func viewWillDisappear(_ animated: Bool)
    /**
     *  Notifies the view controller that its view was removed from a view hierarchy.
     */
    @objc optional func viewDidDisappear(_ animated: Bool)
}
