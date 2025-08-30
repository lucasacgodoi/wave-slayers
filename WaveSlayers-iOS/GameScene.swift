//
//  GameScene.swift
//  WaveSlayers
//
//  Created by Developer on 30/08/2025.
//  Copyright © 2025 WaveSlayers Dev. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreHaptics

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Game Entities
    private var player: Player!
    private var enemies: [Enemy] = []
    private var bullets: [Bullet] = []
    private var powerUps: [SKSpriteNode] = []
    private var coins: [SKSpriteNode] = []
    
    // MARK: - Game Layers
    private var backgroundLayer: SKNode!
    private var gameLayer: SKNode!
    private var uiLayer: SKNode!
    private var effectsLayer: SKNode!
    
    // MARK: - UI Elements
    private var healthBar: SKSpriteNode!
    private var healthBarFill: SKSpriteNode!
    private var shieldBar: SKSpriteNode!
    private var shieldBarFill: SKSpriteNode!
    private var scoreLabel: SKLabelNode!
    private var levelLabel: SKLabelNode!
    private var waveLabel: SKLabelNode!
    private var multiplierLabel: SKLabelNode!
    private var coinCountLabel: SKLabelNode!
    private var pauseButton: SKSpriteNode!
    
    // Special ability buttons
    private var specialAbilityButton: SKSpriteNode!
    private var ultimateAbilityButton: SKSpriteNode!
    
    // MARK: - Game State
    private var gameState: GameState = .playing
    private var isPaused = false
    private var lastUpdateTime: TimeInterval = 0
    private var deltaTime: TimeInterval = 0
    
    // Wave management
    private var currentWave = 1
    private var enemiesInWave = 0
    private var enemiesKilledInWave = 0
    private var waveSpawnTimer: Timer?
    private var nextWaveTimer: Timer?
    
    // Scoring
    private var currentScore = 0
    private var scoreMultiplier = 1
    private var multiplierTimer: TimeInterval = 0
    private var coinsCollected = 0
    
    // Special effects
    private var screenShakeIntensity: CGFloat = 0
    private var screenShakeDecay: CGFloat = 0.9
    
    // Audio
    private var backgroundMusic: SKAudioNode?
    
    // Input handling
    private var joystickBase: SKShapeNode!
    private var joystickKnob: SKShapeNode!
    private var joystickActive = false
    private var joystickStartPosition = CGPoint.zero
    private var fireButton: SKShapeNode!
    private var autoFire = false
    
    // Performance
    private var frameCount = 0
    private var lastFrameTime: TimeInterval = 0
    
    enum GameState {
        case playing
        case paused
        case gameOver
        case levelComplete
        case cutscene
    }
    
    override func didMove(to view: SKView) {
        setupScene()
        setupPhysics()
        setupLayers()
        setupBackground()
        setupPlayer()
        setupUI()
        setupControls()
        setupAudio()
        startGame()
    }
    
    // MARK: - Scene Setup
    private func setupScene() {
        backgroundColor = SKColor.black
        scaleMode = .aspectFill
        
        // Enable multi-touch for controls
        view?.isMultipleTouchEnabled = true
    }
    
    private func setupPhysics() {
        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
        physicsWorld.speed = 1.0
    }
    
    private func setupLayers() {
        backgroundLayer = SKNode()
        backgroundLayer.zPosition = -100
        addChild(backgroundLayer)
        
        gameLayer = SKNode()
        gameLayer.zPosition = 0
        addChild(gameLayer)
        
        effectsLayer = SKNode()
        effectsLayer.zPosition = 50
        addChild(effectsLayer)
        
        uiLayer = SKNode()
        uiLayer.zPosition = 100
        addChild(uiLayer)
    }
    
    private func setupBackground() {
        // Create scrolling starfield
        createScrollingStarfield()
        
        // Add nebula effects
        createNebulaBackground()
        
        // Create planet in background
        createBackgroundPlanet()
    }
    
    private func createScrollingStarfield() {
        for i in 0..<2 {
            let starField = SKNode()
            starField.name = "starfield_\(i)"
            starField.position = CGPoint(x: 0, y: CGFloat(i) * size.height)
            
            // Create stars
            for _ in 0..<150 {
                let star = SKSpriteNode(imageNamed: "star_small")
                star.position = CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: CGFloat.random(in: 0...size.height)
                )
                star.alpha = CGFloat.random(in: 0.3...1.0)
                star.setScale(CGFloat.random(in: 0.1...0.4))
                
                // Add twinkling
                let twinkle = SKAction.sequence([
                    SKAction.fadeAlpha(to: 0.2, duration: Double.random(in: 0.5...2.0)),
                    SKAction.fadeAlpha(to: 1.0, duration: Double.random(in: 0.5...2.0))
                ])
                star.run(SKAction.repeatForever(twinkle))
                
                starField.addChild(star)
            }
            
            backgroundLayer.addChild(starField)
        }
    }
    
    private func createNebulaBackground() {
        let nebula = ParticleSystem.shared.createParticle(type: .starField, at: CGPoint(x: size.width/2, y: size.height + 100), in: backgroundLayer)
        nebula?.zPosition = -90
    }
    
    private func createBackgroundPlanet() {
        let planet = SKSpriteNode(imageNamed: "planet_mars")
        planet.position = CGPoint(x: size.width - 100, y: size.height - 100)
        planet.setScale(0.6)
        planet.alpha = 0.6
        planet.zPosition = -80
        
        // Slow rotation
        let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 60)
        planet.run(SKAction.repeatForever(rotate))
        
        backgroundLayer.addChild(planet)
    }
    
    private func setupPlayer() {
        let playerShip = GameManager.shared.getCurrentShip()
        player = Player(shipData: playerShip)
        player.position = CGPoint(x: size.width/2, y: 100)
        player.zPosition = 10
        gameLayer.addChild(player)
        
        // Add engine trail
        if let trail = ParticleSystem.shared.createTrailFor(node: player, type: .engineTrail) {
            trail.position = CGPoint(x: 0, y: -25)
        }
    }
    
    private func setupUI() {
        // Health bar
        let healthBarBG = SKSpriteNode(color: .darkGray, size: CGSize(width: 200, height: 12))
        healthBarBG.position = CGPoint(x: 120, y: size.height - 40)
        healthBarBG.anchorPoint = CGPoint(x: 0, y: 0.5)
        uiLayer.addChild(healthBarBG)
        
        healthBar = healthBarBG
        
        healthBarFill = SKSpriteNode(color: .red, size: CGSize(width: 200, height: 10))
        healthBarFill.position = CGPoint(x: 121, y: size.height - 40)
        healthBarFill.anchorPoint = CGPoint(x: 0, y: 0.5)
        healthBarFill.zPosition = 1
        uiLayer.addChild(healthBarFill)
        
        // Shield bar
        let shieldBarBG = SKSpriteNode(color: .darkGray, size: CGSize(width: 200, height: 8))
        shieldBarBG.position = CGPoint(x: 120, y: size.height - 60)
        shieldBarBG.anchorPoint = CGPoint(x: 0, y: 0.5)
        uiLayer.addChild(shieldBarBG)
        
        shieldBar = shieldBarBG
        
        shieldBarFill = SKSpriteNode(color: .cyan, size: CGSize(width: 200, height: 6))
        shieldBarFill.position = CGPoint(x: 121, y: size.height - 60)
        shieldBarFill.anchorPoint = CGPoint(x: 0, y: 0.5)
        shieldBarFill.zPosition = 1
        uiLayer.addChild(shieldBarFill)
        
        // Score
        scoreLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 18
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: 20, y: size.height - 90)
        scoreLabel.horizontalAlignmentMode = .left
        uiLayer.addChild(scoreLabel)
        
        // Level/Wave
        levelLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        levelLabel.text = "Nível: 1"
        levelLabel.fontSize = 16
        levelLabel.fontColor = .cyan
        levelLabel.position = CGPoint(x: 20, y: size.height - 115)
        levelLabel.horizontalAlignmentMode = .left
        uiLayer.addChild(levelLabel)
        
        waveLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        waveLabel.text = "Onda: 1"
        waveLabel.fontSize = 16
        waveLabel.fontColor = .yellow
        waveLabel.position = CGPoint(x: 20, y: size.height - 140)
        waveLabel.horizontalAlignmentMode = .left
        uiLayer.addChild(waveLabel)
        
        // Multiplier
        multiplierLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        multiplierLabel.text = "x1"
        multiplierLabel.fontSize = 20
        multiplierLabel.fontColor = .orange
        multiplierLabel.position = CGPoint(x: size.width - 40, y: size.height - 90)
        multiplierLabel.horizontalAlignmentMode = .right
        uiLayer.addChild(multiplierLabel)
        
        // Coins
        coinCountLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        coinCountLabel.text = "💰 0"
        coinCountLabel.fontSize = 16
        coinCountLabel.fontColor = .yellow
        coinCountLabel.position = CGPoint(x: size.width - 40, y: size.height - 115)
        coinCountLabel.horizontalAlignmentMode = .right
        uiLayer.addChild(coinCountLabel)
        
        // Pause button
        pauseButton = SKSpriteNode(color: .gray, size: CGSize(width: 40, height: 40))
        pauseButton.position = CGPoint(x: size.width - 30, y: size.height - 30)
        pauseButton.name = "pause_button"
        
        let pauseIcon = SKLabelNode(text: "⏸")
        pauseIcon.fontSize = 20
        pauseIcon.verticalAlignmentMode = .center
        pauseButton.addChild(pauseIcon)
        
        uiLayer.addChild(pauseButton)
        
        // Special ability buttons
        specialAbilityButton = SKSpriteNode(color: .blue, size: CGSize(width: 60, height: 60))
        specialAbilityButton.position = CGPoint(x: size.width - 80, y: 80)
        specialAbilityButton.name = "special_ability"
        
        let specialIcon = SKLabelNode(text: "⚡")
        specialIcon.fontSize = 24
        specialIcon.verticalAlignmentMode = .center
        specialAbilityButton.addChild(specialIcon)
        
        uiLayer.addChild(specialAbilityButton)
        
        ultimateAbilityButton = SKSpriteNode(color: .purple, size: CGSize(width: 60, height: 60))
        ultimateAbilityButton.position = CGPoint(x: size.width - 80, y: 150)
        ultimateAbilityButton.name = "ultimate_ability"
        
        let ultimateIcon = SKLabelNode(text: "💫")
        ultimateIcon.fontSize = 24
        ultimateIcon.verticalAlignmentMode = .center
        ultimateAbilityButton.addChild(ultimateIcon)
        
        uiLayer.addChild(ultimateAbilityButton)
    }
    
    private func setupControls() {
        // Virtual joystick
        joystickBase = SKShapeNode(circleOfRadius: 50)
        joystickBase.fillColor = .gray
        joystickBase.strokeColor = .white
        joystickBase.lineWidth = 2
        joystickBase.alpha = 0.5
        joystickBase.position = CGPoint(x: 80, y: 80)
        joystickBase.name = "joystick_base"
        uiLayer.addChild(joystickBase)
        
        joystickKnob = SKShapeNode(circleOfRadius: 20)
        joystickKnob.fillColor = .white
        joystickKnob.strokeColor = .gray
        joystickKnob.lineWidth = 2
        joystickKnob.position = joystickBase.position
        joystickKnob.name = "joystick_knob"
        uiLayer.addChild(joystickKnob)
        
        // Fire button
        fireButton = SKShapeNode(circleOfRadius: 40)
        fireButton.fillColor = .red
        fireButton.strokeColor = .white
        fireButton.lineWidth = 3
        fireButton.alpha = 0.6
        fireButton.position = CGPoint(x: size.width - 80, y: 220)
        fireButton.name = "fire_button"
        
        let fireIcon = SKLabelNode(text: "🔥")
        fireIcon.fontSize = 24
        fireIcon.verticalAlignmentMode = .center
        fireButton.addChild(fireIcon)
        
        uiLayer.addChild(fireButton)
    }
    
    private func setupAudio() {
        if let musicURL = Bundle.main.url(forResource: "game_music", withExtension: "mp3") {
            backgroundMusic = SKAudioNode(url: musicURL)
            if let music = backgroundMusic {
                music.autoplayLooped = true
                addChild(music)
            }
        }
    }
    
    // MARK: - Game Logic
    private func startGame() {
        gameState = .playing
        startNewWave()
        updateUI()
    }
    
    private func startNewWave() {
        currentWave += 1
        enemiesInWave = calculateEnemiesForWave(currentWave)
        enemiesKilledInWave = 0
        
        waveLabel.text = "Onda: \(currentWave)"
        
        // Show wave announcement
        showWaveAnnouncement()
        
        // Start spawning enemies
        scheduleEnemySpawns()
    }
    
    private func calculateEnemiesForWave(_ wave: Int) -> Int {
        return min(5 + wave * 2, 20) // Cap at 20 enemies per wave
    }
    
    private func showWaveAnnouncement() {
        let announcement = SKLabelNode(fontNamed: "Helvetica-Bold")
        announcement.text = "ONDA \(currentWave)"
        announcement.fontSize = 36
        announcement.fontColor = .yellow
        announcement.position = CGPoint(x: size.width/2, y: size.height/2)
        announcement.alpha = 0
        announcement.zPosition = 200
        
        let sequence = SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.5),
            SKAction.wait(forDuration: 1.0),
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.removeFromParent()
        ])
        
        announcement.run(sequence)
        uiLayer.addChild(announcement)
    }
    
    private func scheduleEnemySpawns() {
        let spawnInterval = max(0.5, 2.0 - CGFloat(currentWave) * 0.1)
        
        waveSpawnTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(spawnInterval), repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            if self.enemies.count < self.enemiesInWave {
                self.spawnEnemy()
            } else {
                timer.invalidate()
                self.waveSpawnTimer = nil
            }
        }
    }
    
    private func spawnEnemy() {
        let enemyTypes: [EnemyType] = [.basic, .fast, .heavy, .shooter, .boss]
        let weights = calculateEnemyWeights(for: currentWave)
        
        let enemyType = weightedRandomEnemyType(types: enemyTypes, weights: weights)
        let enemy = Enemy(type: enemyType)
        
        // Random spawn position at top of screen
        let spawnX = CGFloat.random(in: 50...size.width - 50)
        enemy.position = CGPoint(x: spawnX, y: size.height + 50)
        enemy.zPosition = 5
        
        enemies.append(enemy)
        gameLayer.addChild(enemy)
        
        // Add spawn effect
        ParticleSystem.shared.createParticle(type: .spawn, at: enemy.position, in: effectsLayer)
    }
    
    private func calculateEnemyWeights(for wave: Int) -> [Double] {
        let basicWeight = max(0.1, 0.6 - Double(wave) * 0.05)
        let fastWeight = min(0.4, 0.2 + Double(wave) * 0.03)
        let heavyWeight = min(0.3, Double(wave) * 0.04)
        let shooterWeight = min(0.2, max(0.0, Double(wave - 3) * 0.05))
        let bossWeight = wave % 5 == 0 ? 0.8 : 0.0 // Boss every 5 waves
        
        return [basicWeight, fastWeight, heavyWeight, shooterWeight, bossWeight]
    }
    
    private func weightedRandomEnemyType(types: [EnemyType], weights: [Double]) -> EnemyType {
        let totalWeight = weights.reduce(0, +)
        let random = Double.random(in: 0...totalWeight)
        
        var currentWeight = 0.0
        for (index, weight) in weights.enumerated() {
            currentWeight += weight
            if random <= currentWeight {
                return types[index]
            }
        }
        
        return types[0] // Fallback
    }
    
    private func updateEnemies(_ deltaTime: TimeInterval) {
        for enemy in enemies {
            enemy.update(deltaTime, playerPosition: player.position, screenSize: size)
            
            // Check if enemy is off screen
            if enemy.position.y < -100 {
                enemy.removeFromParent()
                if let index = enemies.firstIndex(of: enemy) {
                    enemies.remove(at: index)
                }
            }
        }
    }
    
    private func updateBullets(_ deltaTime: TimeInterval) {
        for bullet in bullets {
            bullet.update(deltaTime)
            
            // Remove bullets that are off screen
            if bullet.position.y > size.height + 100 || bullet.position.y < -100 ||
               bullet.position.x < -100 || bullet.position.x > size.width + 100 {
                bullet.removeFromParent()
                if let index = bullets.firstIndex(of: bullet) {
                    bullets.remove(at: index)
                }
            }
        }
    }
    
    private func updatePowerUps(_ deltaTime: TimeInterval) {
        for powerUp in powerUps {
            // Move power-ups down slowly
            powerUp.position.y -= 30 * CGFloat(deltaTime)
            
            // Remove if off screen
            if powerUp.position.y < -50 {
                powerUp.removeFromParent()
                if let index = powerUps.firstIndex(of: powerUp) {
                    powerUps.remove(at: index)
                }
            }
        }
    }
    
    private func updateCoins(_ deltaTime: TimeInterval) {
        for coin in coins {
            // Move coins toward player
            let direction = CGPoint(
                x: player.position.x - coin.position.x,
                y: player.position.y - coin.position.y
            )
            let distance = sqrt(direction.x * direction.x + direction.y * direction.y)
            
            if distance < 100 {
                // Magnet effect
                let speed: CGFloat = 200
                coin.position.x += (direction.x / distance) * speed * CGFloat(deltaTime)
                coin.position.y += (direction.y / distance) * speed * CGFloat(deltaTime)
            } else {
                // Normal movement
                coin.position.y -= 50 * CGFloat(deltaTime)
            }
            
            // Remove if off screen
            if coin.position.y < -50 {
                coin.removeFromParent()
                if let index = coins.firstIndex(of: coin) {
                    coins.remove(at: index)
                }
            }
        }
    }
    
    private func updateUI() {
        // Health bar
        let healthPercent = CGFloat(player.health) / CGFloat(player.maxHealth)
        healthBarFill.size.width = 200 * healthPercent
        
        // Change health bar color based on health
        if healthPercent > 0.6 {
            healthBarFill.color = .green
        } else if healthPercent > 0.3 {
            healthBarFill.color = .yellow
        } else {
            healthBarFill.color = .red
        }
        
        // Shield bar
        let shieldPercent = CGFloat(player.shield) / CGFloat(player.maxShield)
        shieldBarFill.size.width = 200 * shieldPercent
        
        // Score and other labels
        scoreLabel.text = "Score: \(currentScore)"
        levelLabel.text = "Nível: \(ProgressionManager.shared.playerLevel)"
        waveLabel.text = "Onda: \(currentWave)"
        multiplierLabel.text = "x\(scoreMultiplier)"
        coinCountLabel.text = "💰 \(coinsCollected)"
        
        // Animate multiplier if > 1
        if scoreMultiplier > 1 {
            let pulse = SKAction.sequence([
                SKAction.scale(to: 1.2, duration: 0.2),
                SKAction.scale(to: 1.0, duration: 0.2)
            ])
            multiplierLabel.run(pulse)
        }
    }
    
    private func updateMultiplier(_ deltaTime: TimeInterval) {
        if scoreMultiplier > 1 {
            multiplierTimer -= deltaTime
            if multiplierTimer <= 0 {
                scoreMultiplier = max(1, scoreMultiplier - 1)
                multiplierTimer = 5.0 // Reset timer
            }
        }
    }
    
    private func addScore(_ points: Int) {
        let finalPoints = points * scoreMultiplier
        currentScore += finalPoints
        
        // Show score popup
        showScorePopup(finalPoints, at: player.position)
        
        // Increase multiplier on consecutive kills
        if scoreMultiplier < 10 {
            scoreMultiplier += 1
            multiplierTimer = 5.0
        }
        
        // Update best score
        if currentScore > GameManager.shared.bestScore {
            GameManager.shared.bestScore = currentScore
        }
    }
    
    private func showScorePopup(_ points: Int, at position: CGPoint) {
        let popup = SKLabelNode(fontNamed: "Helvetica-Bold")
        popup.text = "+\(points)"
        popup.fontSize = 16
        popup.fontColor = .yellow
        popup.position = position
        popup.zPosition = 150
        
        let moveUp = SKAction.moveBy(x: 0, y: 50, duration: 1.0)
        let fadeOut = SKAction.fadeOut(withDuration: 1.0)
        let remove = SKAction.removeFromParent()
        
        popup.run(SKAction.sequence([
            SKAction.group([moveUp, fadeOut]),
            remove
        ]))
        
        effectsLayer.addChild(popup)
    }
    
    // MARK: - Input Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodeAtPoint = atPoint(location)
        
        if let nodeName = nodeAtPoint.name {
            handleUITouch(nodeName, at: location)
        }
        
        handleJoystickTouch(location, phase: .began)
        handleFireButtonTouch(location, phase: .began)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        handleJoystickTouch(location, phase: .moved)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        handleJoystickTouch(location, phase: .ended)
        handleFireButtonTouch(location, phase: .ended)
    }
    
    private func handleUITouch(_ nodeName: String, at location: CGPoint) {
        switch nodeName {
        case "pause_button":
            togglePause()
        case "special_ability":
            useSpecialAbility()
        case "ultimate_ability":
            useUltimateAbility()
        default:
            break
        }
    }
    
    private func handleJoystickTouch(_ location: CGPoint, phase: UITouch.Phase) {
        let joystickLocation = convert(location, to: uiLayer)
        let joystickDistance = distance(from: joystickBase.position, to: joystickLocation)
        
        switch phase {
        case .began:
            if joystickDistance <= 50 {
                joystickActive = true
                joystickStartPosition = joystickLocation
            }
        case .moved:
            if joystickActive {
                let maxDistance: CGFloat = 50
                let clampedDistance = min(joystickDistance, maxDistance)
                let angle = atan2(joystickLocation.y - joystickBase.position.y, joystickLocation.x - joystickBase.position.x)
                
                joystickKnob.position = CGPoint(
                    x: joystickBase.position.x + cos(angle) * clampedDistance,
                    y: joystickBase.position.y + sin(angle) * clampedDistance
                )
                
                // Move player
                let moveSpeed: CGFloat = 300
                let velocity = CGPoint(
                    x: cos(angle) * (clampedDistance / maxDistance) * moveSpeed,
                    y: sin(angle) * (clampedDistance / maxDistance) * moveSpeed
                )
                
                player.move(velocity: velocity)
            }
        case .ended, .cancelled:
            if joystickActive {
                joystickActive = false
                joystickKnob.position = joystickBase.position
                player.move(velocity: CGPoint.zero)
            }
        default:
            break
        }
    }
    
    private func handleFireButtonTouch(_ location: CGPoint, phase: UITouch.Phase) {
        let fireLocation = convert(location, to: uiLayer)
        let fireDistance = distance(from: fireButton.position, to: fireLocation)
        
        switch phase {
        case .began:
            if fireDistance <= 40 {
                autoFire = true
            }
        case .ended, .cancelled:
            autoFire = false
        default:
            break
        }
    }
    
    private func distance(from point1: CGPoint, to point2: CGPoint) -> CGFloat {
        let dx = point2.x - point1.x
        let dy = point2.y - point1.y
        return sqrt(dx * dx + dy * dy)
    }
    
    // MARK: - Abilities
    private func useSpecialAbility() {
        if player.canUseSpecialAbility() {
            player.useSpecialAbility()
            
            // Special ability effects based on ship type
            let shipId = GameManager.shared.selectedShip
            switch shipId {
            case "fighter":
                // Rapid fire
                rapidFireMode()
            case "interceptor":
                // Speed boost
                speedBoostMode()
            case "destroyer":
                // Shield boost
                shieldBoostMode()
            default:
                // Default ability
                rapidFireMode()
            }
        }
    }
    
    private func useUltimateAbility() {
        if player.canUseUltimateAbility() {
            player.useUltimateAbility()
            
            // Screen-clearing attack
            ultimateAttack()
        }
    }
    
    private func rapidFireMode() {
        player.fireRate *= 3
        
        let resetAction = SKAction.sequence([
            SKAction.wait(forDuration: 5.0),
            SKAction.run { [weak self] in
                self?.player.fireRate /= 3
            }
        ])
        
        run(resetAction)
        
        // Visual effect
        ParticleSystem.shared.createParticle(type: .boost, at: player.position, in: effectsLayer)
    }
    
    private func speedBoostMode() {
        player.speed *= 2
        
        let resetAction = SKAction.sequence([
            SKAction.wait(forDuration: 5.0),
            SKAction.run { [weak self] in
                self?.player.speed /= 2
            }
        ])
        
        run(resetAction)
        
        // Visual effect
        ParticleSystem.shared.createParticle(type: .teleport, at: player.position, in: effectsLayer)
    }
    
    private func shieldBoostMode() {
        player.shield = player.maxShield
        
        // Visual effect
        ParticleSystem.shared.createParticle(type: .healing, at: player.position, in: effectsLayer)
    }
    
    private func ultimateAttack() {
        // Damage all enemies on screen
        for enemy in enemies {
            enemy.takeDamage(1000) // Massive damage
            ParticleSystem.shared.createParticle(type: .lightning, at: enemy.position, in: effectsLayer)
        }
        
        // Screen flash effect
        let flash = SKSpriteNode(color: .white, size: size)
        flash.position = CGPoint(x: size.width/2, y: size.height/2)
        flash.alpha = 0.8
        flash.zPosition = 200
        
        let flashAction = SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ])
        
        flash.run(flashAction)
        effectsLayer.addChild(flash)
        
        // Screen shake
        applyScreenShake(intensity: 20)
    }
    
    // MARK: - Effects
    private func applyScreenShake(intensity: CGFloat) {
        screenShakeIntensity = intensity
    }
    
    private func updateScreenShake() {
        if screenShakeIntensity > 0.1 {
            let shakeX = CGFloat.random(in: -screenShakeIntensity...screenShakeIntensity)
            let shakeY = CGFloat.random(in: -screenShakeIntensity...screenShakeIntensity)
            
            gameLayer.position = CGPoint(x: shakeX, y: shakeY)
            backgroundLayer.position = CGPoint(x: shakeX * 0.5, y: shakeY * 0.5)
            
            screenShakeIntensity *= screenShakeDecay
        } else {
            gameLayer.position = CGPoint.zero
            backgroundLayer.position = CGPoint.zero
            screenShakeIntensity = 0
        }
    }
    
    // MARK: - Physics Contact
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch collision {
        case PhysicsCategory.player | PhysicsCategory.enemy:
            handlePlayerEnemyCollision(contact)
        case PhysicsCategory.bullet | PhysicsCategory.enemy:
            handleBulletEnemyCollision(contact)
        case PhysicsCategory.player | PhysicsCategory.powerUp:
            handlePlayerPowerUpCollision(contact)
        case PhysicsCategory.player | PhysicsCategory.coin:
            handlePlayerCoinCollision(contact)
        default:
            break
        }
    }
    
    private func handlePlayerEnemyCollision(_ contact: SKPhysicsContact) {
        let playerBody = contact.bodyA.categoryBitMask == PhysicsCategory.player ? contact.bodyA : contact.bodyB
        let enemyBody = contact.bodyA.categoryBitMask == PhysicsCategory.enemy ? contact.bodyA : contact.bodyB
        
        if let enemyNode = enemyBody.node as? Enemy {
            player.takeDamage(enemyNode.damage)
            
            // Create hit effect
            ParticleSystem.shared.createParticle(type: .hit, at: player.position, in: effectsLayer)
            
            // Screen shake
            applyScreenShake(intensity: 5)
            
            // Check for game over
            if player.health <= 0 {
                gameOver()
            }
        }
    }
    
    private func handleBulletEnemyCollision(_ contact: SKPhysicsContact) {
        let bulletBody = contact.bodyA.categoryBitMask == PhysicsCategory.bullet ? contact.bodyA : contact.bodyB
        let enemyBody = contact.bodyA.categoryBitMask == PhysicsCategory.enemy ? contact.bodyA : contact.bodyB
        
        if let bulletNode = bulletBody.node as? Bullet,
           let enemyNode = enemyBody.node as? Enemy {
            
            enemyNode.takeDamage(bulletNode.damage)
            
            // Create hit effect
            let isCritical = bulletNode.damage > 50
            ParticleSystem.shared.createHitEffectAt(enemyNode.position, in: effectsLayer, critical: isCritical)
            
            // Remove bullet
            bulletNode.removeFromParent()
            if let index = bullets.firstIndex(of: bulletNode) {
                bullets.remove(at: index)
            }
            
            // Check if enemy is destroyed
            if enemyNode.health <= 0 {
                destroyEnemy(enemyNode)
            }
        }
    }
    
    private func handlePlayerPowerUpCollision(_ contact: SKPhysicsContact) {
        let powerUpBody = contact.bodyA.categoryBitMask == PhysicsCategory.powerUp ? contact.bodyA : contact.bodyB
        
        if let powerUpNode = powerUpBody.node {
            // Apply power-up effect
            applyPowerUpEffect(powerUpNode.name ?? "health")
            
            // Remove power-up
            powerUpNode.removeFromParent()
            if let index = powerUps.firstIndex(of: powerUpNode as! SKSpriteNode) {
                powerUps.remove(at: index)
            }
            
            // Effect
            ParticleSystem.shared.createParticle(type: .powerup, at: powerUpNode.position, in: effectsLayer)
        }
    }
    
    private func handlePlayerCoinCollision(_ contact: SKPhysicsContact) {
        let coinBody = contact.bodyA.categoryBitMask == PhysicsCategory.coin ? contact.bodyA : contact.bodyB
        
        if let coinNode = coinBody.node {
            coinsCollected += 1
            GameManager.shared.coins += 1
            
            // Remove coin
            coinNode.removeFromParent()
            if let index = coins.firstIndex(of: coinNode as! SKSpriteNode) {
                coins.remove(at: index)
            }
            
            // Effect
            ParticleSystem.shared.createParticle(type: .coins, at: coinNode.position, in: effectsLayer)
            
            // Score
            addScore(10)
        }
    }
    
    private func destroyEnemy(_ enemy: Enemy) {
        // Add score
        addScore(enemy.scoreValue)
        
        // Create explosion
        ParticleSystem.shared.createExplosionAt(enemy.position, in: effectsLayer)
        
        // Screen shake based on enemy size
        let shakeIntensity: CGFloat = enemy.type == .boss ? 15 : 3
        applyScreenShake(intensity: shakeIntensity)
        
        // Spawn rewards
        spawnRewards(at: enemy.position)
        
        // Remove enemy
        enemy.removeFromParent()
        if let index = enemies.firstIndex(of: enemy) {
            enemies.remove(at: index)
        }
        
        // Track wave progress
        enemiesKilledInWave += 1
        
        // Check if wave is complete
        if enemiesKilledInWave >= enemiesInWave && enemies.isEmpty {
            completeWave()
        }
    }
    
    private func spawnRewards(at position: CGPoint) {
        // Chance for power-ups
        if Float.random(in: 0...1) < 0.1 { // 10% chance
            spawnPowerUp(at: position)
        }
        
        // Always spawn coins
        for _ in 0...Int.random(in: 1...3) {
            spawnCoin(at: position)
        }
    }
    
    private func spawnPowerUp(at position: CGPoint) {
        let powerUpTypes = ["health", "shield", "damage", "speed"]
        let powerUpType = powerUpTypes.randomElement() ?? "health"
        
        let powerUp = SKSpriteNode(imageNamed: "powerup_\(powerUpType)")
        powerUp.position = position
        powerUp.name = powerUpType
        powerUp.setScale(0.5)
        
        // Physics
        powerUp.physicsBody = SKPhysicsBody(circleOfRadius: 15)
        powerUp.physicsBody?.categoryBitMask = PhysicsCategory.powerUp
        powerUp.physicsBody?.contactTestBitMask = PhysicsCategory.player
        powerUp.physicsBody?.collisionBitMask = 0
        powerUp.physicsBody?.affectedByGravity = false
        
        powerUps.append(powerUp)
        gameLayer.addChild(powerUp)
        
        // Animate
        let pulse = SKAction.sequence([
            SKAction.scale(to: 0.6, duration: 0.5),
            SKAction.scale(to: 0.5, duration: 0.5)
        ])
        powerUp.run(SKAction.repeatForever(pulse))
    }
    
    private func spawnCoin(at position: CGPoint) {
        let coin = SKSpriteNode(imageNamed: "coin")
        coin.position = CGPoint(
            x: position.x + CGFloat.random(in: -20...20),
            y: position.y + CGFloat.random(in: -20...20)
        )
        coin.setScale(0.3)
        
        // Physics
        coin.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        coin.physicsBody?.categoryBitMask = PhysicsCategory.coin
        coin.physicsBody?.contactTestBitMask = PhysicsCategory.player
        coin.physicsBody?.collisionBitMask = 0
        coin.physicsBody?.affectedByGravity = false
        
        coins.append(coin)
        gameLayer.addChild(coin)
        
        // Animate
        let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 1.0)
        coin.run(SKAction.repeatForever(rotate))
    }
    
    private func applyPowerUpEffect(_ type: String) {
        switch type {
        case "health":
            player.health = min(player.health + 20, player.maxHealth)
            ParticleSystem.shared.createParticle(type: .healing, at: player.position, in: effectsLayer)
        case "shield":
            player.shield = player.maxShield
            ParticleSystem.shared.createParticle(type: .shield, at: player.position, in: effectsLayer)
        case "damage":
            player.damage *= 1.5
            let resetAction = SKAction.sequence([
                SKAction.wait(forDuration: 10.0),
                SKAction.run { [weak self] in
                    self?.player.damage /= 1.5
                }
            ])
            run(resetAction)
            ParticleSystem.shared.createParticle(type: .boost, at: player.position, in: effectsLayer)
        case "speed":
            player.speed *= 1.5
            let resetAction = SKAction.sequence([
                SKAction.wait(forDuration: 10.0),
                SKAction.run { [weak self] in
                    self?.player.speed /= 1.5
                }
            ])
            run(resetAction)
            ParticleSystem.shared.createParticle(type: .teleport, at: player.position, in: effectsLayer)
        default:
            break
        }
    }
    
    // MARK: - Game State Management
    private func togglePause() {
        isPaused.toggle()
        
        if isPaused {
            physicsWorld.speed = 0
            gameState = .paused
            showPauseMenu()
        } else {
            physicsWorld.speed = 1
            gameState = .playing
            hidePauseMenu()
        }
    }
    
    private func showPauseMenu() {
        let pauseOverlay = SKSpriteNode(color: .black, size: size)
        pauseOverlay.alpha = 0.7
        pauseOverlay.position = CGPoint(x: size.width/2, y: size.height/2)
        pauseOverlay.zPosition = 150
        pauseOverlay.name = "pause_overlay"
        uiLayer.addChild(pauseOverlay)
        
        let pauseLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        pauseLabel.text = "PAUSADO"
        pauseLabel.fontSize = 32
        pauseLabel.fontColor = .white
        pauseLabel.position = CGPoint(x: size.width/2, y: size.height/2)
        pauseLabel.zPosition = 151
        pauseLabel.name = "pause_label"
        uiLayer.addChild(pauseLabel)
    }
    
    private func hidePauseMenu() {
        uiLayer.childNode(withName: "pause_overlay")?.removeFromParent()
        uiLayer.childNode(withName: "pause_label")?.removeFromParent()
    }
    
    private func completeWave() {
        // Add wave completion bonus
        addScore(currentWave * 100)
        
        // Start next wave after delay
        nextWaveTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] timer in
            self?.startNewWave()
            timer.invalidate()
            self?.nextWaveTimer = nil
        }
    }
    
    private func gameOver() {
        gameState = .gameOver
        
        // Stop all timers
        waveSpawnTimer?.invalidate()
        nextWaveTimer?.invalidate()
        
        // Save progress
        ProgressionManager.shared.addXP(currentScore / 10)
        GameManager.shared.saveGameData()
        
        // Show game over screen
        showGameOverScreen()
    }
    
    private func showGameOverScreen() {
        let gameOverOverlay = SKSpriteNode(color: .black, size: size)
        gameOverOverlay.alpha = 0.8
        gameOverOverlay.position = CGPoint(x: size.width/2, y: size.height/2)
        gameOverOverlay.zPosition = 200
        gameOverOverlay.name = "gameover_overlay"
        uiLayer.addChild(gameOverOverlay)
        
        let gameOverLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        gameOverLabel.text = "GAME OVER"
        gameOverLabel.fontSize = 36
        gameOverLabel.fontColor = .red
        gameOverLabel.position = CGPoint(x: size.width/2, y: size.height/2 + 50)
        gameOverLabel.zPosition = 201
        uiLayer.addChild(gameOverLabel)
        
        let finalScoreLabel = SKLabelNode(fontNamed: "Helvetica")
        finalScoreLabel.text = "Pontuação Final: \(currentScore)"
        finalScoreLabel.fontSize = 18
        finalScoreLabel.fontColor = .white
        finalScoreLabel.position = CGPoint(x: size.width/2, y: size.height/2)
        finalScoreLabel.zPosition = 201
        uiLayer.addChild(finalScoreLabel)
        
        // Return to menu button
        let menuButton = SKSpriteNode(color: .blue, size: CGSize(width: 150, height: 40))
        menuButton.position = CGPoint(x: size.width/2, y: size.height/2 - 50)
        menuButton.zPosition = 201
        menuButton.name = "return_to_menu"
        
        let menuLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        menuLabel.text = "MENU"
        menuLabel.fontSize = 16
        menuLabel.fontColor = .white
        menuLabel.verticalAlignmentMode = .center
        menuButton.addChild(menuLabel)
        
        uiLayer.addChild(menuButton)
    }
    
    private func returnToMenu() {
        let menuScene = MenuScene(size: size)
        menuScene.scaleMode = scaleMode
        
        let transition = SKTransition.fade(withDuration: 1.0)
        view?.presentScene(menuScene, transition: transition)
    }
    
    // MARK: - Update Loop
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        
        deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        // Limit delta time to prevent large jumps
        deltaTime = min(deltaTime, 1.0/30.0)
        
        if gameState == .playing {
            // Update game entities
            player.update(deltaTime)
            updateEnemies(deltaTime)
            updateBullets(deltaTime)
            updatePowerUps(deltaTime)
            updateCoins(deltaTime)
            
            // Update game systems
            updateMultiplier(deltaTime)
            updateScreenShake()
            updateBackground(deltaTime)
            
            // Auto fire
            if autoFire {
                fireBullet()
            }
            
            // Update UI
            updateUI()
        }
        
        // Performance monitoring
        frameCount += 1
        if currentTime - lastFrameTime >= 1.0 {
            lastFrameTime = currentTime
            frameCount = 0
        }
    }
    
    private func updateBackground(_ deltaTime: TimeInterval) {
        // Scroll starfield
        for i in 0..<2 {
            if let starField = backgroundLayer.childNode(withName: "starfield_\(i)") {
                starField.position.y -= 50 * CGFloat(deltaTime)
                
                if starField.position.y <= -size.height {
                    starField.position.y = size.height
                }
            }
        }
    }
    
    private func fireBullet() {
        if player.canFire() {
            let bullet = player.fire()
            bullets.append(bullet)
            gameLayer.addChild(bullet)
        }
    }
    
    // MARK: - Cleanup
    override func willMove(from view: SKView) {
        waveSpawnTimer?.invalidate()
        nextWaveTimer?.invalidate()
        backgroundMusic?.removeFromParent()
    }
}
