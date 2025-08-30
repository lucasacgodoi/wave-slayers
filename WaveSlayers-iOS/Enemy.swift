//
//  Enemy.swift
//  WaveSlayers
//
//  Created by Developer on 30/08/2025.
//  Copyright © 2025 WaveSlayers Dev. All rights reserved.
//

import SpriteKit
import UIKit

// MARK: - Enemy Types
enum EnemyType: String, CaseIterable {
    case grunt = "grunt"
    case scout = "scout"
    case heavy = "heavy"
    case bomber = "bomber"
    case elite = "elite"
    case boss = "boss"
    
    var health: Int {
        switch self {
        case .grunt: return 20
        case .scout: return 15
        case .heavy: return 50
        case .bomber: return 30
        case .elite: return 80
        case .boss: return 200
        }
    }
    
    var speed: Float {
        switch self {
        case .grunt: return 2.0
        case .scout: return 4.0
        case .heavy: return 1.5
        case .bomber: return 2.5
        case .elite: return 3.0
        case .boss: return 1.0
        }
    }
    
    var damage: Int {
        switch self {
        case .grunt: return 10
        case .scout: return 8
        case .heavy: return 20
        case .bomber: return 15
        case .elite: return 25
        case .boss: return 40
        }
    }
    
    var size: CGSize {
        switch self {
        case .grunt: return CGSize(width: 30, height: 40)
        case .scout: return CGSize(width: 25, height: 35)
        case .heavy: return CGSize(width: 45, height: 55)
        case .bomber: return CGSize(width: 40, height: 50)
        case .elite: return CGSize(width: 50, height: 60)
        case .boss: return CGSize(width: 80, height: 100)
        }
    }
    
    var color: UIColor {
        switch self {
        case .grunt: return UIColor.red
        case .scout: return UIColor.orange
        case .heavy: return UIColor.purple
        case .bomber: return UIColor.yellow
        case .elite: return UIColor.magenta
        case .boss: return UIColor.darkRed
        }
    }
    
    var scoreValue: Int {
        switch self {
        case .grunt: return 10
        case .scout: return 15
        case .heavy: return 30
        case .bomber: return 25
        case .elite: return 50
        case .boss: return 100
        }
    }
    
    var fireRate: Float {
        switch self {
        case .grunt: return 2.0
        case .scout: return 1.5
        case .heavy: return 3.0
        case .bomber: return 4.0
        case .elite: return 1.0
        case .boss: return 0.5
        }
    }
}

// MARK: - Enemy Movement Patterns
enum MovementPattern {
    case straight
    case zigzag
    case circular
    case pursuing
    case formation
}

class Enemy: SKSpriteNode {
    
    // MARK: - Properties
    var enemyType: EnemyType
    var health: Int
    var maxHealth: Int
    var speed: Float
    var damage: Int
    var movementPattern: MovementPattern
    
    private var lastShotTime: TimeInterval = 0
    private var fireRate: Float
    
    // Movement properties
    private var velocity = CGPoint.zero
    private var movementTimer: TimeInterval = 0
    private var patternOffset: Float = 0
    private var targetPosition = CGPoint.zero
    
    // AI properties
    private var playerPosition = CGPoint.zero
    private var aggressionLevel: Float = 1.0
    
    // Visual effects
    private var damageEffect: SKEmitterNode?
    private var thrusterEffect: SKEmitterNode?
    
    // Formation properties
    private var formationIndex: Int = 0
    private var formationPosition = CGPoint.zero
    
    // MARK: - Initialization
    init(type: EnemyType, movementPattern: MovementPattern = .straight) {
        self.enemyType = type
        self.health = Int(Float(type.health) * GameManager.shared.getDifficultyMultiplier())
        self.maxHealth = self.health
        self.speed = type.speed * GameManager.shared.getDifficultyMultiplier()
        self.damage = Int(Float(type.damage) * GameManager.shared.getDifficultyMultiplier())
        self.movementPattern = movementPattern
        self.fireRate = type.fireRate
        
        let texture = SKTexture()
        super.init(texture: texture, color: type.color, size: type.size)
        
        setupEnemy()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.enemyType = .grunt
        self.health = 20
        self.maxHealth = 20
        self.speed = 2.0
        self.damage = 10
        self.movementPattern = .straight
        self.fireRate = 2.0
        
        super.init(coder: aDecoder)
        setupEnemy()
    }
    
    private func setupEnemy() {
        // Physics
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.categoryBitMask = PhysicsCategory.enemy
        physicsBody?.contactTestBitMask = PhysicsCategory.playerBullet | PhysicsCategory.player
        physicsBody?.collisionBitMask = 0
        physicsBody?.affectedByGravity = false
        
        // Visual setup
        createEnemyShape()
        setupParticleEffects()
        
        name = "enemy"
        zPosition = 5
        
        // Random pattern offset for variety
        patternOffset = Float.random(in: 0...(2 * Float.pi))
    }
    
    private func createEnemyShape() {
        // Remove existing children
        removeAllChildren()
        
        // Create enemy shape based on type
        switch enemyType {
        case .grunt:
            createGruntShape()
        case .scout:
            createScoutShape()
        case .heavy:
            createHeavyShape()
        case .bomber:
            createBomberShape()
        case .elite:
            createEliteShape()
        case .boss:
            createBossShape()
        }
        
        // Add glow effect
        let glowNode = SKSpriteNode(color: color.withAlphaComponent(0.3), size: CGSize(width: size.width + 8, height: size.height + 8))
        glowNode.zPosition = -1
        addChild(glowNode)
    }
    
    private func createGruntShape() {
        // Simple triangular grunt
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: -size.height/2))
        path.addLine(to: CGPoint(x: -size.width/2, y: size.height/2))
        path.addLine(to: CGPoint(x: size.width/2, y: size.height/2))
        path.addLine(to: CGPoint(x: 0, y: -size.height/2))
        
        let shape = SKShapeNode(path: path)
        shape.fillColor = color
        shape.strokeColor = color.withAlphaComponent(0.8)
        shape.lineWidth = 2
        addChild(shape)
    }
    
    private func createScoutShape() {
        // Fast, sleek scout
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: -size.height/2))
        path.addLine(to: CGPoint(x: -size.width/3, y: 0))
        path.addLine(to: CGPoint(x: -size.width/4, y: size.height/2))
        path.addLine(to: CGPoint(x: size.width/4, y: size.height/2))
        path.addLine(to: CGPoint(x: size.width/3, y: 0))
        path.addLine(to: CGPoint(x: 0, y: -size.height/2))
        
        let shape = SKShapeNode(path: path)
        shape.fillColor = color
        shape.strokeColor = color.withAlphaComponent(0.8)
        shape.lineWidth = 2
        addChild(shape)
        
        // Add speed lines
        for i in 0..<3 {
            let line = SKShapeNode(rect: CGRect(x: -2, y: size.height/2 + CGFloat(i * 8), width: 4, height: 6))
            line.fillColor = color.withAlphaComponent(0.5)
            addChild(line)
        }
    }
    
    private func createHeavyShape() {
        // Bulky heavy enemy
        let mainBody = SKShapeNode(rect: CGRect(x: -size.width/2, y: -size.height/2, width: size.width, height: size.height))
        mainBody.fillColor = color
        mainBody.strokeColor = color.withAlphaComponent(0.8)
        mainBody.lineWidth = 3
        addChild(mainBody)
        
        // Add armor plating
        let armor1 = SKShapeNode(rect: CGRect(x: -size.width/3, y: -size.height/3, width: size.width/6, height: size.height/2))
        armor1.fillColor = color.withAlphaComponent(0.7)
        armor1.strokeColor = color
        addChild(armor1)
        
        let armor2 = SKShapeNode(rect: CGRect(x: size.width/6, y: -size.height/3, width: size.width/6, height: size.height/2))
        armor2.fillColor = color.withAlphaComponent(0.7)
        armor2.strokeColor = color
        addChild(armor2)
    }
    
    private func createBomberShape() {
        // Rounded bomber with payload
        let mainBody = SKShapeNode(circleOfRadius: size.width/2)
        mainBody.fillColor = color
        mainBody.strokeColor = color.withAlphaComponent(0.8)
        mainBody.lineWidth = 2
        addChild(mainBody)
        
        // Add bomb bay
        let bombBay = SKShapeNode(rect: CGRect(x: -size.width/4, y: -size.height/3, width: size.width/2, height: size.height/6))
        bombBay.fillColor = UIColor.darkGray
        bombBay.strokeColor = color
        addChild(bombBay)
        
        // Add fins
        let leftFin = SKShapeNode(rect: CGRect(x: -size.width/2, y: 0, width: size.width/8, height: size.height/3))
        leftFin.fillColor = color.withAlphaComponent(0.8)
        addChild(leftFin)
        
        let rightFin = SKShapeNode(rect: CGRect(x: size.width/2 - size.width/8, y: 0, width: size.width/8, height: size.height/3))
        rightFin.fillColor = color.withAlphaComponent(0.8)
        addChild(rightFin)
    }
    
    private func createEliteShape() {
        // Advanced elite design
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: -size.height/2))
        path.addLine(to: CGPoint(x: -size.width/2, y: 0))
        path.addLine(to: CGPoint(x: -size.width/3, y: size.height/2))
        path.addLine(to: CGPoint(x: size.width/3, y: size.height/2))
        path.addLine(to: CGPoint(x: size.width/2, y: 0))
        path.addLine(to: CGPoint(x: 0, y: -size.height/2))
        
        let shape = SKShapeNode(path: path)
        shape.fillColor = color
        shape.strokeColor = UIColor.white
        shape.lineWidth = 3
        addChild(shape)
        
        // Add energy core
        let core = SKShapeNode(circleOfRadius: 8)
        core.fillColor = UIColor.white
        core.strokeColor = color
        core.lineWidth = 2
        addChild(core)
        
        // Animate core
        let pulseAction = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5)
        ])
        core.run(SKAction.repeatForever(pulseAction))
    }
    
    private func createBossShape() {
        // Massive boss enemy
        let mainBody = SKShapeNode(rect: CGRect(x: -size.width/2, y: -size.height/2, width: size.width, height: size.height))
        mainBody.fillColor = color
        mainBody.strokeColor = UIColor.red
        mainBody.lineWidth = 4
        addChild(mainBody)
        
        // Add multiple weapons
        for i in 0..<3 {
            let weapon = SKShapeNode(rect: CGRect(x: -size.width/2 + CGFloat(i) * size.width/3, y: size.height/2 - 10, width: size.width/6, height: 15))
            weapon.fillColor = UIColor.darkRed
            weapon.strokeColor = UIColor.red
            addChild(weapon)
        }
        
        // Add command center
        let commandCenter = SKShapeNode(circleOfRadius: 12)
        commandCenter.fillColor = UIColor.red
        commandCenter.strokeColor = UIColor.white
        commandCenter.lineWidth = 2
        addChild(commandCenter)
        
        // Add shield effect
        let shield = SKShapeNode(circleOfRadius: size.width/2 + 5)
        shield.fillColor = UIColor.clear
        shield.strokeColor = UIColor.cyan.withAlphaComponent(0.5)
        shield.lineWidth = 3
        addChild(shield)
        
        // Animate shield
        let shieldAction = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.2, duration: 1.0),
            SKAction.fadeAlpha(to: 0.8, duration: 1.0)
        ])
        shield.run(SKAction.repeatForever(shieldAction))
    }
    
    private func setupParticleEffects() {
        // Thruster effect for movement
        thrusterEffect = SKEmitterNode()
        if let thrusters = thrusterEffect {
            thrusters.particleTexture = SKTexture()
            thrusters.particleColor = color.withAlphaComponent(0.6)
            thrusters.particleSize = CGSize(width: 3, height: 3)
            thrusters.particleBirthRate = 20
            thrusters.particleLifetime = 0.3
            thrusters.particleSpeed = 80
            thrusters.emissionAngle = .pi / 2
            thrusters.emissionAngleRange = .pi / 6
            thrusters.position = CGPoint(x: 0, y: size.height/2)
            thrusters.zPosition = -1
            addChild(thrusters)
        }
    }
    
    // MARK: - Update
    func update(deltaTime: TimeInterval, playerPosition: CGPoint) {
        self.playerPosition = playerPosition
        movementTimer += deltaTime
        
        // Update movement based on pattern
        updateMovement(deltaTime: deltaTime)
        
        // Update position
        position.x += velocity.x * CGFloat(deltaTime)
        position.y += velocity.y * CGFloat(deltaTime)
        
        // Try to shoot
        attemptToShoot(currentTime: CACurrentMediaTime())
        
        // Update AI behavior
        updateAI(deltaTime: deltaTime)
        
        // Update visual effects
        updateVisualEffects()
    }
    
    private func updateMovement(deltaTime: TimeInterval) {
        switch movementPattern {
        case .straight:
            velocity = CGPoint(x: 0, y: -CGFloat(speed * 60))
            
        case .zigzag:
            let zigzagSpeed = sin(Float(movementTimer) * 3.0 + patternOffset) * speed * 30
            velocity = CGPoint(x: CGFloat(zigzagSpeed), y: -CGFloat(speed * 60))
            
        case .circular:
            let radius: Float = 50
            let angularSpeed: Float = 2.0
            let angle = Float(movementTimer) * angularSpeed + patternOffset
            let centerX = Float(position.x)
            let centerY = Float(position.y) - speed * 60 * Float(deltaTime)
            
            let newX = centerX + cos(angle) * radius * Float(deltaTime)
            let newY = centerY + sin(angle) * radius * Float(deltaTime)
            
            velocity = CGPoint(x: CGFloat(newX - Float(position.x)), y: CGFloat(newY - Float(position.y)))
            
        case .pursuing:
            let dx = playerPosition.x - position.x
            let dy = playerPosition.y - position.y
            let distance = sqrt(dx * dx + dy * dy)
            
            if distance > 0 {
                let normalizedX = dx / distance
                let normalizedY = dy / distance
                velocity = CGPoint(
                    x: normalizedX * CGFloat(speed * 40),
                    y: normalizedY * CGFloat(speed * 40)
                )
            }
            
        case .formation:
            // Move towards formation position
            let dx = formationPosition.x - position.x
            let dy = formationPosition.y - position.y
            
            velocity = CGPoint(
                x: dx * CGFloat(speed * 0.5),
                y: dy * CGFloat(speed * 0.5) - CGFloat(speed * 30)
            )
        }
    }
    
    private func updateAI(deltaTime: TimeInterval) {
        // Increase aggression over time
        aggressionLevel += Float(deltaTime) * 0.1
        aggressionLevel = min(aggressionLevel, 3.0)
        
        // Adjust behavior based on health
        let healthPercentage = Float(health) / Float(maxHealth)
        if healthPercentage < 0.3 {
            // Become more aggressive when low on health
            fireRate *= 0.8
            speed *= 1.2
        }
        
        // Special behavior for boss
        if enemyType == .boss {
            updateBossAI(deltaTime: deltaTime)
        }
    }
    
    private func updateBossAI(deltaTime: TimeInterval) {
        // Boss phases based on health
        let healthPercentage = Float(health) / Float(maxHealth)
        
        if healthPercentage > 0.75 {
            // Phase 1: Slow and steady
            fireRate = 2.0
        } else if healthPercentage > 0.5 {
            // Phase 2: Faster shooting
            fireRate = 1.5
        } else if healthPercentage > 0.25 {
            // Phase 3: Aggressive
            fireRate = 1.0
            movementPattern = .pursuing
        } else {
            // Phase 4: Desperate
            fireRate = 0.5
            speed *= 1.5
        }
    }
    
    private func updateVisualEffects() {
        // Update thruster based on movement
        if let thrusters = thrusterEffect {
            let isMoving = abs(velocity.x) > 10 || abs(velocity.y) > 10
            thrusters.particleBirthRate = isMoving ? 40 : 10
        }
        
        // Health-based visual changes
        let healthPercentage = Float(health) / Float(maxHealth)
        if healthPercentage < 0.5 {
            // Add damage smoke
            if damageEffect == nil {
                createDamageEffect()
            }
        }
    }
    
    private func createDamageEffect() {
        damageEffect = SKEmitterNode()
        if let damage = damageEffect {
            damage.particleTexture = SKTexture()
            damage.particleColor = UIColor.gray
            damage.particleSize = CGSize(width: 4, height: 4)
            damage.particleBirthRate = 15
            damage.particleLifetime = 1.0
            damage.particleSpeed = 30
            damage.emissionAngleRange = .pi * 2
            damage.particleAlpha = 0.6
            damage.particleScaleSpeed = -0.5
            addChild(damage)
        }
    }
    
    // MARK: - Combat
    private func attemptToShoot(currentTime: TimeInterval) -> Bullet? {
        if currentTime - lastShotTime >= TimeInterval(fireRate / aggressionLevel) {
            lastShotTime = currentTime
            return shoot()
        }
        return nil
    }
    
    func shoot() -> Bullet? {
        guard let scene = scene else { return nil }
        
        let bullet = Bullet(isPlayer: false)
        bullet.position = CGPoint(x: position.x, y: position.y - size.height/2)
        bullet.damage = damage
        bullet.color = color.withAlphaComponent(0.8)
        
        // Different shooting patterns for different enemies
        switch enemyType {
        case .boss:
            // Boss shoots multiple bullets
            return createBossShot()
        case .elite:
            // Elite shoots homing bullets
            bullet.isHoming = true
            bullet.target = playerPosition
        default:
            break
        }
        
        return bullet
    }
    
    private func createBossShot() -> Bullet? {
        // Boss creates multiple bullets in a spread pattern
        guard let scene = scene else { return nil }
        
        let bulletCount = 5
        let spreadAngle: Float = .pi / 3 // 60 degrees
        
        for i in 0..<bulletCount {
            let bullet = Bullet(isPlayer: false)
            bullet.position = CGPoint(x: position.x, y: position.y - size.height/2)
            bullet.damage = damage
            bullet.color = color.withAlphaComponent(0.8)
            
            // Calculate angle for spread
            let angleStep = spreadAngle / Float(bulletCount - 1)
            let angle = -spreadAngle/2 + Float(i) * angleStep
            
            bullet.velocity = CGPoint(
                x: CGFloat(sin(angle)) * 200,
                y: CGFloat(-cos(angle)) * 200
            )
            
            scene.addChild(bullet)
        }
        
        return nil // Return nil since we already added bullets to scene
    }
    
    // MARK: - Damage System
    func takeDamage(_ damage: Int) {
        health -= damage
        
        // Visual feedback
        flashDamage()
        createHitParticles()
        
        if health <= 0 {
            health = 0
            die()
        }
    }
    
    private func flashDamage() {
        let originalColor = color
        color = UIColor.white
        
        let flashAction = SKAction.sequence([
            SKAction.wait(forDuration: 0.05),
            SKAction.run { [weak self] in
                self?.color = originalColor
            }
        ])
        run(flashAction)
    }
    
    private func createHitParticles() {
        let hitEffect = SKEmitterNode()
        hitEffect.particleTexture = SKTexture()
        hitEffect.particleColor = UIColor.white
        hitEffect.particleSize = CGSize(width: 3, height: 3)
        hitEffect.particleBirthRate = 30
        hitEffect.particleLifetime = 0.3
        hitEffect.particleSpeed = 100
        hitEffect.emissionAngleRange = .pi * 2
        hitEffect.position = position
        
        if let scene = scene {
            scene.addChild(hitEffect)
            
            let removeAction = SKAction.sequence([
                SKAction.wait(forDuration: 0.3),
                SKAction.run { hitEffect.removeFromParent() }
            ])
            scene.run(removeAction)
        }
    }
    
    private func die() {
        // Award score
        GameManager.shared.addScore(enemyType.scoreValue)
        
        // Create death explosion
        createDeathExplosion()
        
        // Remove from scene
        removeFromParent()
        
        // Notify progression system
        ProgressionManager.shared.enemyKilled(type: enemyType)
    }
    
    private func createDeathExplosion() {
        let explosion = SKEmitterNode()
        explosion.particleTexture = SKTexture()
        explosion.particleColor = color
        explosion.particleSize = CGSize(width: 6, height: 6)
        explosion.particleBirthRate = 100
        explosion.particleLifetime = 0.8
        explosion.particleSpeed = 150
        explosion.particleSpeedRange = 50
        explosion.emissionAngleRange = .pi * 2
        explosion.particleScaleSpeed = -1.0
        explosion.position = position
        
        if let scene = scene {
            scene.addChild(explosion)
            
            let removeAction = SKAction.sequence([
                SKAction.wait(forDuration: 1.0),
                SKAction.run { explosion.removeFromParent() }
            ])
            scene.run(removeAction)
        }
    }
    
    // MARK: - Formation Support
    func setFormationPosition(_ position: CGPoint, index: Int) {
        formationPosition = position
        formationIndex = index
        movementPattern = .formation
    }
    
    // MARK: - Cleanup
    func shouldBeRemoved() -> Bool {
        guard let scene = scene else { return true }
        
        // Remove if off screen (below)
        return position.y < -size.height
    }
}
