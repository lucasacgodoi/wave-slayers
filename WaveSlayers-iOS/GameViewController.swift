//
//  GameViewController.swift
//  WaveSlayers
//
//  Created by Developer on 30/08/2025.
//  Copyright © 2025 WaveSlayers Dev. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the initial menu scene
            let scene = MenuScene(size: CGSize(width: 1024, height: 768))
            
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            
            // Present the scene
            view.presentScene(scene)
            
            view.ignoresSiblingOrder = true
            
            // Show debug information
            #if DEBUG
            view.showsFPS = true
            view.showsNodeCount = true
            view.showsPhysics = false
            #endif
            
            // Set preferred framerate
            view.preferredFramesPerSecond = 60
            
            // Configure multi-touch
            view.isMultipleTouchEnabled = true
        }
        
        // Hide status bar
        setNeedsStatusBarAppearanceUpdate()
        
        // Set up notifications
        setupNotifications()
    }
    
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Prevent device sleep
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Re-enable device sleep
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(pauseGame),
            name: NSNotification.Name("PauseGame"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(resumeGame),
            name: NSNotification.Name("ResumeGame"),
            object: nil
        )
    }
    
    @objc private func pauseGame() {
        if let view = self.view as? SKView,
           let scene = view.scene as? GameScene {
            scene.pauseGame()
        }
    }
    
    @objc private func resumeGame() {
        if let view = self.view as? SKView,
           let scene = view.scene as? GameScene {
            scene.resumeGame()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
