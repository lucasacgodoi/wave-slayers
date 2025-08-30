//
//  MenuScene.swift
//  WaveSlayers
//
//  Created by Developer on 30/08/2025.
//  Copyright © 2025 WaveSlayers Dev. All rights reserved.
//

import SpriteKit
import GameplayKit

class MenuScene: SKScene {
    
    // MARK: - UI Elements
    private var titleLabel: SKLabelNode!
    private var playButton: SKSpriteNode!
    private var upgradeButton: SKSpriteNode!
    private var leaderboardButton: SKSpriteNode!
    private var settingsButton: SKSpriteNode!
    private var socialButton: SKSpriteNode!
    private var achievementsButton: SKSpriteNode!
    
    // Player Info Display
    private var playerLevelLabel: SKLabelNode!
    private var playerXPBar: SKSpriteNode!
    private var playerXPFill: SKSpriteNode!
    private var coinsLabel: SKLabelNode!
    private var gemsLabel: SKLabelNode!
    
    // Background Elements
    private var backgroundLayer: SKNode!
    private var starFieldLayer: SKNode!
    private var planetLayer: SKNode!
    
    // Audio
    private var backgroundMusic: SKAudioNode?
    
    // Animation
    private var animatingElements: [SKNode] = []
    
    override func didMove(to view: SKView) {
        setupScene()
        setupBackground()
        setupUI()
        setupPlayerInfo()
        setupAnimations()
        setupAudio()
        updatePlayerInfo()
    }
    
    // MARK: - Scene Setup
    private func setupScene() {
        backgroundColor = SKColor.black
        scaleMode = .aspectFill
        
        // Create layers
        backgroundLayer = SKNode()
        backgroundLayer.zPosition = -100
        addChild(backgroundLayer)
        
        starFieldLayer = SKNode()
        starFieldLayer.zPosition = -90
        addChild(starFieldLayer)
        
        planetLayer = SKNode()
        planetLayer.zPosition = -80
        addChild(planetLayer)
    }
    
    private func setupBackground() {
        // Create animated star field
        createStarField()
        
        // Create floating planets
        createPlanets()
        
        // Create nebula effects
        createNebula()
        
        // Add particle effects
        if let starParticles = ParticleSystem.shared.createParticle(type: .starField, at: CGPoint(x: size.width/2, y: size.height + 50), in: self) {
            starParticles.zPosition = -95
        }
    }
    
    private func createStarField() {
        for _ in 0..<100 {
            let star = SKSpriteNode(imageNamed: "star_small")
            star.position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height)
            )
            star.alpha = CGFloat.random(in: 0.3...1.0)
            star.setScale(CGFloat.random(in: 0.1...0.3))
            
            // Twinkling animation
            let twinkle = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.3, duration: Double.random(in: 1.0...3.0)),
                SKAction.fadeAlpha(to: 1.0, duration: Double.random(in: 1.0...3.0))
            ])
            star.run(SKAction.repeatForever(twinkle))
            
            starFieldLayer.addChild(star)
        }
    }
    
    private func createPlanets() {
        let planetNames = ["planet_earth", "planet_mars", "planet_jupiter", "planet_neptune"]
        
        for i in 0..<3 {
            let planetName = planetNames[i % planetNames.count]
            let planet = SKSpriteNode(imageNamed: planetName)
            
            planet.position = CGPoint(
                x: CGFloat.random(in: -100...size.width + 100),
                y: CGFloat.random(in: -100...size.height + 100)
            )
            planet.setScale(CGFloat.random(in: 0.3...0.8))
            planet.alpha = 0.7
            planet.zRotation = CGFloat.random(in: 0...CGFloat.pi * 2)
            
            // Slow rotation
            let rotation = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: Double.random(in: 30...60))
            planet.run(SKAction.repeatForever(rotation))
            
            // Floating movement
            let float = SKAction.sequence([
                SKAction.moveBy(x: CGFloat.random(in: -50...50), y: CGFloat.random(in: -30...30), duration: Double.random(in: 8...15)),
                SKAction.moveBy(x: CGFloat.random(in: -50...50), y: CGFloat.random(in: -30...30), duration: Double.random(in: 8...15))
            ])
            planet.run(SKAction.repeatForever(float))
            
            planetLayer.addChild(planet)
        }
    }
    
    private func createNebula() {
        for _ in 0..<5 {
            let nebula = SKSpriteNode(imageNamed: "nebula_cloud")
            nebula.position = CGPoint(
                x: CGFloat.random(in: -200...size.width + 200),
                y: CGFloat.random(in: -200...size.height + 200)
            )
            nebula.setScale(CGFloat.random(in: 0.5...1.5))
            nebula.alpha = CGFloat.random(in: 0.1...0.3)
            nebula.blendMode = .add
            nebula.zPosition = -85
            
            // Slow drift
            let drift = SKAction.sequence([
                SKAction.moveBy(x: CGFloat.random(in: -100...100), y: CGFloat.random(in: -50...50), duration: Double.random(in: 20...40)),
                SKAction.moveBy(x: CGFloat.random(in: -100...100), y: CGFloat.random(in: -50...50), duration: Double.random(in: 20...40))
            ])
            nebula.run(SKAction.repeatForever(drift))
            
            backgroundLayer.addChild(nebula)
        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Title
        titleLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        titleLabel.text = "WAVE SLAYERS"
        titleLabel.fontSize = 48
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: size.width/2, y: size.height - 120)
        titleLabel.zPosition = 10
        
        // Add glow effect
        titleLabel.fontColor = SKColor.cyan
        let glow = titleLabel.copy() as! SKLabelNode
        glow.fontColor = SKColor.white
        glow.fontSize = 50
        glow.alpha = 0.3
        glow.zPosition = 9
        addChild(glow)
        addChild(titleLabel)
        
        // Animate title
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 2.0),
            SKAction.scale(to: 1.0, duration: 2.0)
        ])
        titleLabel.run(SKAction.repeatForever(pulse))
        animatingElements.append(titleLabel)
        
        // Main Buttons
        let buttonWidth: CGFloat = 200
        let buttonHeight: CGFloat = 50
        let buttonSpacing: CGFloat = 70
        let startY = size.height/2 + 100
        
        // Play Button
        playButton = createButton(
            text: "JOGAR",
            position: CGPoint(x: size.width/2, y: startY),
            size: CGSize(width: buttonWidth, height: buttonHeight),
            color: .green
        )
        addChild(playButton)
        
        // Upgrade Button
        upgradeButton = createButton(
            text: "MELHORIAS",
            position: CGPoint(x: size.width/2, y: startY - buttonSpacing),
            size: CGSize(width: buttonWidth, height: buttonHeight),
            color: .blue
        )
        addChild(upgradeButton)
        
        // Leaderboard Button
        leaderboardButton = createButton(
            text: "RANKING",
            position: CGPoint(x: size.width/2, y: startY - buttonSpacing * 2),
            size: CGSize(width: buttonWidth, height: buttonHeight),
            color: .orange
        )
        addChild(leaderboardButton)
        
        // Side Buttons
        let sideButtonSize: CGFloat = 60
        let sideButtonY = size.height - 80
        
        // Settings Button
        settingsButton = createIconButton(
            icon: "⚙️",
            position: CGPoint(x: 50, y: sideButtonY),
            size: CGSize(width: sideButtonSize, height: sideButtonSize),
            color: .gray
        )
        addChild(settingsButton)
        
        // Social Button
        socialButton = createIconButton(
            icon: "👥",
            position: CGPoint(x: size.width - 50, y: sideButtonY),
            size: CGSize(width: sideButtonSize, height: sideButtonSize),
            color: .purple
        )
        addChild(socialButton)
        
        // Achievements Button
        achievementsButton = createIconButton(
            icon: "🏆",
            position: CGPoint(x: size.width - 50, y: sideButtonY - 80),
            size: CGSize(width: sideButtonSize, height: sideButtonSize),
            color: .yellow
        )
        addChild(achievementsButton)
    }
    
    private func setupPlayerInfo() {
        // Player Level
        playerLevelLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        playerLevelLabel.fontSize = 20
        playerLevelLabel.fontColor = .white
        playerLevelLabel.position = CGPoint(x: 120, y: size.height - 180)
        playerLevelLabel.horizontalAlignmentMode = .left
        playerLevelLabel.zPosition = 10
        addChild(playerLevelLabel)
        
        // XP Bar Background
        playerXPBar = SKSpriteNode(color: .darkGray, size: CGSize(width: 200, height: 8))
        playerXPBar.position = CGPoint(x: 200, y: size.height - 210)
        playerXPBar.zPosition = 10
        addChild(playerXPBar)
        
        // XP Bar Fill
        playerXPFill = SKSpriteNode(color: .cyan, size: CGSize(width: 0, height: 8))
        playerXPFill.anchorPoint = CGPoint(x: 0, y: 0.5)
        playerXPFill.position = CGPoint(x: 100, y: size.height - 210)
        playerXPFill.zPosition = 11
        addChild(playerXPFill)
        
        // Coins
        let coinIcon = SKLabelNode(text: "💰")
        coinIcon.fontSize = 20
        coinIcon.position = CGPoint(x: 50, y: size.height - 250)
        coinIcon.zPosition = 10
        addChild(coinIcon)
        
        coinsLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        coinsLabel.fontSize = 16
        coinsLabel.fontColor = .yellow
        coinsLabel.position = CGPoint(x: 80, y: size.height - 250)
        coinsLabel.horizontalAlignmentMode = .left
        coinsLabel.zPosition = 10
        addChild(coinsLabel)
        
        // Gems
        let gemIcon = SKLabelNode(text: "💎")
        gemIcon.fontSize = 20
        gemIcon.position = CGPoint(x: 200, y: size.height - 250)
        gemIcon.zPosition = 10
        addChild(gemIcon)
        
        gemsLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        gemsLabel.fontSize = 16
        gemsLabel.fontColor = .magenta
        gemsLabel.position = CGPoint(x: 230, y: size.height - 250)
        gemsLabel.horizontalAlignmentMode = .left
        gemsLabel.zPosition = 10
        addChild(gemsLabel)
    }
    
    private func createButton(text: String, position: CGPoint, size: CGSize, color: SKColor) -> SKSpriteNode {
        let button = SKSpriteNode(color: color, size: size)
        button.position = position
        button.name = text.lowercased()
        button.zPosition = 10
        
        // Add border
        let border = SKShapeNode(rect: CGRect(x: -size.width/2, y: -size.height/2, width: size.width, height: size.height))
        border.strokeColor = .white
        border.lineWidth = 2
        border.fillColor = .clear
        border.zPosition = 1
        button.addChild(border)
        
        // Add label
        let label = SKLabelNode(fontNamed: "Helvetica-Bold")
        label.text = text
        label.fontSize = 18
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.zPosition = 2
        button.addChild(label)
        
        // Add hover effect
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.05, duration: 0.8),
            SKAction.scale(to: 1.0, duration: 0.8)
        ])
        button.run(SKAction.repeatForever(pulse))
        animatingElements.append(button)
        
        return button
    }
    
    private func createIconButton(icon: String, position: CGPoint, size: CGSize, color: SKColor) -> SKSpriteNode {
        let button = SKSpriteNode(color: color, size: size)
        button.position = position
        button.name = icon
        button.zPosition = 10
        
        // Make it circular
        let circle = SKShapeNode(circleOfRadius: size.width/2)
        circle.fillColor = color
        circle.strokeColor = .white
        circle.lineWidth = 2
        circle.zPosition = 0
        button.addChild(circle)
        
        // Add icon
        let iconLabel = SKLabelNode(text: icon)
        iconLabel.fontSize = 24
        iconLabel.verticalAlignmentMode = .center
        iconLabel.zPosition = 2
        button.addChild(iconLabel)
        
        return button
    }
    
    // MARK: - Animations
    private func setupAnimations() {
        // Floating animation for buttons
        for element in animatingElements {
            let float = SKAction.sequence([
                SKAction.moveBy(x: 0, y: 5, duration: 1.5),
                SKAction.moveBy(x: 0, y: -5, duration: 1.5)
            ])
            element.run(SKAction.repeatForever(float))
        }
        
        // Background elements movement
        let moveStars = SKAction.moveBy(x: 0, y: -30, duration: 10)
        starFieldLayer.run(SKAction.repeatForever(moveStars))
    }
    
    // MARK: - Audio
    private func setupAudio() {
        if let musicURL = Bundle.main.url(forResource: "menu_music", withExtension: "mp3") {
            backgroundMusic = SKAudioNode(url: musicURL)
            if let music = backgroundMusic {
                music.autoplayLooped = true
                addChild(music)
            }
        }
    }
    
    // MARK: - Update Player Info
    private func updatePlayerInfo() {
        let progressionManager = ProgressionManager.shared
        
        // Update level
        playerLevelLabel.text = "Nível \(progressionManager.playerLevel)"
        
        // Update XP bar
        let currentXP = progressionManager.currentXP
        let neededXP = progressionManager.xpForNextLevel
        let progress = CGFloat(currentXP) / CGFloat(neededXP)
        
        let xpBarWidth: CGFloat = 200
        playerXPFill.size.width = xpBarWidth * progress
        
        // Update currency
        coinsLabel.text = "\(GameManager.shared.coins)"
        gemsLabel.text = "\(progressionManager.gems)"
        
        // Animate currency updates
        let coinsPulse = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ])
        coinsLabel.run(coinsPulse)
        gemsLabel.run(coinsPulse)
    }
    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)
        
        handleButtonPress(touchedNode)
    }
    
    private func handleButtonPress(_ node: SKNode) {
        // Button press animation
        let pressAnimation = SKAction.sequence([
            SKAction.scale(to: 0.9, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ])
        
        if let nodeName = node.name ?? node.parent?.name {
            node.run(pressAnimation)
            
            switch nodeName {
            case "jogar":
                startGame()
            case "melhorias":
                openUpgrades()
            case "ranking":
                openLeaderboard()
            case "⚙️":
                openSettings()
            case "👥":
                openSocial()
            case "🏆":
                openAchievements()
            default:
                break
            }
        }
    }
    
    // MARK: - Navigation
    private func startGame() {
        playButtonPressSound()
        
        // Transition to game scene
        let gameScene = GameScene(size: size)
        gameScene.scaleMode = scaleMode
        
        let transition = SKTransition.fade(withDuration: 1.0)
        view?.presentScene(gameScene, transition: transition)
    }
    
    private func openUpgrades() {
        playButtonPressSound()
        showUpgradeMenu()
    }
    
    private func openLeaderboard() {
        playButtonPressSound()
        showLeaderboard()
    }
    
    private func openSettings() {
        playButtonPressSound()
        showSettings()
    }
    
    private func openSocial() {
        playButtonPressSound()
        showSocialMenu()
    }
    
    private func openAchievements() {
        playButtonPressSound()
        showAchievements()
    }
    
    // MARK: - Menu Overlays
    private func showUpgradeMenu() {
        let overlay = createMenuOverlay()
        
        let title = SKLabelNode(fontNamed: "Helvetica-Bold")
        title.text = "MELHORIAS"
        title.fontSize = 32
        title.fontColor = .white
        title.position = CGPoint(x: 0, y: 150)
        overlay.addChild(title)
        
        // Ship Selection
        let shipTitle = SKLabelNode(fontNamed: "Helvetica-Bold")
        shipTitle.text = "Selecionar Nave"
        shipTitle.fontSize = 20
        shipTitle.fontColor = .cyan
        shipTitle.position = CGPoint(x: 0, y: 80)
        overlay.addChild(shipTitle)
        
        // Display available ships
        let ships = GameManager.shared.ships
        let unlockedShips = GameManager.shared.unlockedShips
        
        for (index, ship) in ships.enumerated() {
            let shipButton = createShipButton(ship: ship, index: index, isUnlocked: unlockedShips.contains(ship.id))
            shipButton.position = CGPoint(x: -150 + CGFloat(index % 3) * 100, y: 20 - CGFloat(index / 3) * 80)
            overlay.addChild(shipButton)
        }
        
        addChild(overlay)
    }
    
    private func createShipButton(ship: ShipData, index: Int, isUnlocked: Bool) -> SKNode {
        let container = SKNode()
        container.name = "ship_\(ship.id)"
        
        // Ship sprite
        let shipSprite = SKSpriteNode(imageNamed: ship.sprite)
        shipSprite.setScale(0.5)
        shipSprite.alpha = isUnlocked ? 1.0 : 0.5
        container.addChild(shipSprite)
        
        // Lock overlay
        if !isUnlocked {
            let lock = SKLabelNode(text: "🔒")
            lock.fontSize = 20
            lock.position = CGPoint(x: 0, y: -30)
            container.addChild(lock)
            
            let costLabel = SKLabelNode(fontNamed: "Helvetica")
            costLabel.text = "\(ship.cost) 💰"
            costLabel.fontSize = 12
            costLabel.fontColor = .yellow
            costLabel.position = CGPoint(x: 0, y: -45)
            container.addChild(costLabel)
        }
        
        // Selection indicator
        if ship.id == GameManager.shared.selectedShip {
            let indicator = SKShapeNode(circleOfRadius: 25)
            indicator.strokeColor = .green
            indicator.lineWidth = 3
            indicator.fillColor = .clear
            indicator.zPosition = -1
            container.addChild(indicator)
        }
        
        return container
    }
    
    private func showLeaderboard() {
        let overlay = createMenuOverlay()
        
        let title = SKLabelNode(fontNamed: "Helvetica-Bold")
        title.text = "RANKING"
        title.fontSize = 32
        title.fontColor = .white
        title.position = CGPoint(x: 0, y: 150)
        overlay.addChild(title)
        
        // Category buttons
        let categories = ["overall", "weekly", "monthly"]
        let categoryNames = ["Geral", "Semanal", "Mensal"]
        
        for (index, category) in categories.enumerated() {
            let button = createButton(
                text: categoryNames[index],
                position: CGPoint(x: -100 + CGFloat(index) * 100, y: 100),
                size: CGSize(width: 80, height: 30),
                color: .blue
            )
            button.name = "leaderboard_\(category)"
            overlay.addChild(button)
        }
        
        // Display leaderboard entries
        let leaderboard = SocialManager.shared.getLeaderboard(category: "overall")
        
        for (index, entry) in leaderboard.prefix(10).enumerated() {
            let entryNode = createLeaderboardEntry(entry: entry, index: index)
            entryNode.position = CGPoint(x: 0, y: 50 - CGFloat(index) * 25)
            overlay.addChild(entryNode)
        }
        
        addChild(overlay)
    }
    
    private func createLeaderboardEntry(entry: LeaderboardEntry, index: Int) -> SKNode {
        let container = SKNode()
        
        // Background
        let background = SKSpriteNode(color: entry.isCurrentPlayer ? .darkGreen : .darkGray, size: CGSize(width: 300, height: 20))
        background.alpha = 0.5
        container.addChild(background)
        
        // Rank
        let rankLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        rankLabel.text = "\(entry.rank)"
        rankLabel.fontSize = 14
        rankLabel.fontColor = .white
        rankLabel.position = CGPoint(x: -140, y: -7)
        rankLabel.horizontalAlignmentMode = .left
        container.addChild(rankLabel)
        
        // Name
        let nameLabel = SKLabelNode(fontNamed: "Helvetica")
        nameLabel.text = entry.playerName
        nameLabel.fontSize = 12
        nameLabel.fontColor = entry.isCurrentPlayer ? .green : .white
        nameLabel.position = CGPoint(x: -100, y: -7)
        nameLabel.horizontalAlignmentMode = .left
        container.addChild(nameLabel)
        
        // Score
        let scoreLabel = SKLabelNode(fontNamed: "Helvetica")
        scoreLabel.text = "\(entry.score)"
        scoreLabel.fontSize = 12
        scoreLabel.fontColor = .yellow
        scoreLabel.position = CGPoint(x: 140, y: -7)
        scoreLabel.horizontalAlignmentMode = .right
        container.addChild(scoreLabel)
        
        return container
    }
    
    private func showSettings() {
        let overlay = createMenuOverlay()
        
        let title = SKLabelNode(fontNamed: "Helvetica-Bold")
        title.text = "CONFIGURAÇÕES"
        title.fontSize = 32
        title.fontColor = .white
        title.position = CGPoint(x: 0, y: 150)
        overlay.addChild(title)
        
        // Sound toggle
        let soundButton = createButton(
            text: GameManager.shared.soundEnabled ? "Som: ON" : "Som: OFF",
            position: CGPoint(x: 0, y: 50),
            size: CGSize(width: 150, height: 40),
            color: GameManager.shared.soundEnabled ? .green : .red
        )
        soundButton.name = "toggle_sound"
        overlay.addChild(soundButton)
        
        // Music toggle
        let musicButton = createButton(
            text: GameManager.shared.musicEnabled ? "Música: ON" : "Música: OFF",
            position: CGPoint(x: 0, y: 0),
            size: CGSize(width: 150, height: 40),
            color: GameManager.shared.musicEnabled ? .green : .red
        )
        musicButton.name = "toggle_music"
        overlay.addChild(musicButton)
        
        // Reset progress button
        let resetButton = createButton(
            text: "RESETAR PROGRESSO",
            position: CGPoint(x: 0, y: -50),
            size: CGSize(width: 200, height: 40),
            color: .red
        )
        resetButton.name = "reset_progress"
        overlay.addChild(resetButton)
        
        addChild(overlay)
    }
    
    private func showSocialMenu() {
        let overlay = createMenuOverlay()
        
        let title = SKLabelNode(fontNamed: "Helvetica-Bold")
        title.text = "SOCIAL"
        title.fontSize = 32
        title.fontColor = .white
        title.position = CGPoint(x: 0, y: 150)
        overlay.addChild(title)
        
        // Player name
        let nameLabel = SKLabelNode(fontNamed: "Helvetica")
        nameLabel.text = "Jogador: \(SocialManager.shared.playerName)"
        nameLabel.fontSize = 16
        nameLabel.fontColor = .cyan
        nameLabel.position = CGPoint(x: 0, y: 100)
        overlay.addChild(nameLabel)
        
        // Clan info
        if let clan = SocialManager.shared.playerClan {
            let clanLabel = SKLabelNode(fontNamed: "Helvetica")
            clanLabel.text = "Clã: \(clan.name)"
            clanLabel.fontSize = 16
            clanLabel.fontColor = .purple
            clanLabel.position = CGPoint(x: 0, y: 70)
            overlay.addChild(clanLabel)
        } else {
            let noClanButton = createButton(
                text: "PROCURAR CLÃ",
                position: CGPoint(x: 0, y: 70),
                size: CGSize(width: 150, height: 30),
                color: .purple
            )
            noClanButton.name = "find_clan"
            overlay.addChild(noClanButton)
        }
        
        // Share score button
        let shareButton = createButton(
            text: "COMPARTILHAR",
            position: CGPoint(x: 0, y: 20),
            size: CGSize(width: 150, height: 40),
            color: .blue
        )
        shareButton.name = "share_score"
        overlay.addChild(shareButton)
        
        addChild(overlay)
    }
    
    private func showAchievements() {
        let overlay = createMenuOverlay()
        
        let title = SKLabelNode(fontNamed: "Helvetica-Bold")
        title.text = "CONQUISTAS"
        title.fontSize = 32
        title.fontColor = .white
        title.position = CGPoint(x: 0, y: 150)
        overlay.addChild(title)
        
        // Display achievements
        let achievements = ProgressionManager.shared.achievements
        
        for (index, achievement) in achievements.prefix(8).enumerated() {
            let achievementNode = createAchievementNode(achievement: achievement)
            achievementNode.position = CGPoint(
                x: -100 + CGFloat(index % 2) * 200,
                y: 100 - CGFloat(index / 2) * 40
            )
            overlay.addChild(achievementNode)
        }
        
        addChild(overlay)
    }
    
    private func createAchievementNode(achievement: Achievement) -> SKNode {
        let container = SKNode()
        
        // Background
        let background = SKSpriteNode(color: achievement.isCompleted ? .darkGreen : .darkGray, size: CGSize(width: 180, height: 30))
        background.alpha = 0.7
        container.addChild(background)
        
        // Icon
        let icon = SKLabelNode(text: achievement.icon)
        icon.fontSize = 16
        icon.position = CGPoint(x: -75, y: -8)
        container.addChild(icon)
        
        // Title
        let titleLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        titleLabel.text = achievement.title
        titleLabel.fontSize = 10
        titleLabel.fontColor = achievement.isCompleted ? .white : .gray
        titleLabel.position = CGPoint(x: -50, y: -2)
        titleLabel.horizontalAlignmentMode = .left
        container.addChild(titleLabel)
        
        // Progress
        let progressLabel = SKLabelNode(fontNamed: "Helvetica")
        progressLabel.text = "\(achievement.currentProgress)/\(achievement.targetProgress)"
        progressLabel.fontSize = 8
        progressLabel.fontColor = .lightGray
        progressLabel.position = CGPoint(x: -50, y: -12)
        progressLabel.horizontalAlignmentMode = .left
        container.addChild(progressLabel)
        
        return container
    }
    
    private func createMenuOverlay() -> SKNode {
        let overlay = SKNode()
        overlay.name = "menu_overlay"
        overlay.zPosition = 100
        
        // Background
        let background = SKSpriteNode(color: .black, size: size)
        background.alpha = 0.8
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        overlay.addChild(background)
        
        // Container
        let container = SKNode()
        container.position = CGPoint(x: size.width/2, y: size.height/2)
        overlay.addChild(container)
        
        // Close button
        let closeButton = createIconButton(
            icon: "✕",
            position: CGPoint(x: size.width/2 - 50, y: size.height/2 - 50),
            size: CGSize(width: 40, height: 40),
            color: .red
        )
        closeButton.name = "close_menu"
        overlay.addChild(closeButton)
        
        return overlay
    }
    
    private func closeMenuOverlay() {
        childNode(withName: "menu_overlay")?.removeFromParent()
    }
    
    // MARK: - Audio
    private func playButtonPressSound() {
        if GameManager.shared.soundEnabled {
            run(SKAction.playSoundFileNamed("button_press.wav", waitForCompletion: false))
        }
    }
    
    // MARK: - Scene Lifecycle
    override func willMove(from view: SKView) {
        backgroundMusic?.removeFromParent()
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Update any time-based elements
        updatePlayerInfo()
    }
}
