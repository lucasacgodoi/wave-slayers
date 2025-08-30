//
//  Player.swift
//  WaveSlayers
//
//  Created by Developer on 30/08/2025.
//  Copyright © 2025 WaveSlayers Dev. All rights reserved.
//

import SpriteKit
import UIKit

class Player: SKSpriteNode {
    
    // MARK: - Properties
    var health: Int = 100
    var maxHealth: Int = 100
    var speed: Float = 5.0
    var damage: Int = 10
    var fireRate: Float = 0.3
    var specialAbility: String = ""
    
    private var lastShotTime: TimeInterval = 0
    private var specialCooldown: TimeInterval = 0
    private var specialCooldownDuration: TimeInterval = 5.0
    
    // Movement
    private var velocity = CGPoint.zero
    private var isMovingUp = false
    private var isMovingDown = false
    private var isMovingLeft = false
    private var isMovingRight = false
    
    // Visual effects
    private var thrusterParticles: SKEmitterNode?
    private var damageEffect: SKEmitterNode?
    
    // Animation
    private var lastPosition = CGPoint.zero
    private var tiltAmount: CGFloat = 0
    
    // MARK: - Initialization
    init() {
        let texture = SKTexture()
        super.init(texture: texture, color: UIColor.cyan, size: CGSize(width: 40, height: 60))
        
        setupPlayer()
        loadShipData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupPlayer()
        loadShipData()
    }
    
    private func setupPlayer() {
        // Physics
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.categoryBitMask = PhysicsCategory.player
        physicsBody?.contactTestBitMask = PhysicsCategory.enemy | PhysicsCategory.enemyBullet | PhysicsCategory.powerUp
        physicsBody?.collisionBitMask = 0
        physicsBody?.affectedByGravity = false
        
        // Visual setup
        setupVisuals()
        setupParticleEffects()
        
        // Position
        position = CGPoint(x: 100, y: 400)
        
        name = "player"
        zPosition = 10
    }
    
    private func setupVisuals() {
        // Create ship shape with pixel art style
        createShipShape()
        
        // Add glow effect
        let glowNode = SKSpriteNode(color: color.withAlphaComponent(0.3), size: CGSize(width: size.width + 10, height: size.height + 10))
        glowNode.zPosition = -1
        addChild(glowNode)
        
        // Animate glow
        let pulseAction = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.8),
            SKAction.scale(to: 1.0, duration: 0.8)
        ])
        glowNode.run(SKAction.repeatForever(pulseAction))
    }
    
    private func createShipShape() {
        // Remove old shape
        removeAllChildren()
        
        // Create ship based on current ship type
        let shipData = GameManager.shared.getCurrentShip()
        color = shipData.color
        
        // Create detailed ship sprite
        let path = CGMutablePath()
        
        // Ship body (main triangle)
        path.move(to: CGPoint(x: 0, y: size.height/2))
        path.addLine(to: CGPoint(x: -size.width/3, y: -size.height/2))
        path.addLine(to: CGPoint(x: -size.width/6, y: -size.height/3))
        path.addLine(to: CGPoint(x: size.width/6, y: -size.height/3))
        path.addLine(to: CGPoint(x: size.width/3, y: -size.height/2))
        path.addLine(to: CGPoint(x: 0, y: size.height/2))
        
        let shipShape = SKShapeNode(path: path)
        shipShape.fillColor = color
        shipShape.strokeColor = color.withAlphaComponent(0.8)
        shipShape.lineWidth = 2
        addChild(shipShape)
        
        // Wings
        let leftWing = SKShapeNode(rect: CGRect(x: -size.width/2, y: -size.height/4, width: size.width/6, height: size.height/3))
        leftWing.fillColor = color.withAlphaComponent(0.7)
        leftWing.strokeColor = color
        leftWing.lineWidth = 1
        addChild(leftWing)
        
        let rightWing = SKShapeNode(rect: CGRect(x: size.width/3, y: -size.height/4, width: size.width/6, height: size.height/3))
        rightWing.fillColor = color.withAlphaComponent(0.7)
        rightWing.strokeColor = color
        rightWing.lineWidth = 1
        addChild(rightWing)
        
        // Cockpit
        let cockpit = SKShapeNode(circleOfRadius: 6)
        cockpit.position = CGPoint(x: 0, y: size.height/6)
        cockpit.fillColor = UIColor.white.withAlphaComponent(0.8)
        cockpit.strokeColor = color
        cockpit.lineWidth = 1
        addChild(cockpit)
    }
    
    private func setupParticleEffects() {
        // Thruster particles
        thrusterParticles = SKEmitterNode()
        if let thrusters = thrusterParticles {
            thrusters.particleTexture = SKTexture()
            thrusters.particleColor = UIColor.orange
            thrusters.particleColorSequence = nil
            thrusters.particleSize = CGSize(width: 4, height: 4)
            thrusters.particleBirthRate = 50
            thrusters.particleLifetime = 0.5
            thrusters.particleSpeed = 100
            thrusters.particleSpeedRange = 20
            thrusters.emissionAngle = .pi
            thrusters.emissionAngleRange = .pi / 4
            thrusters.particleAlpha = 0.8
            thrusters.particleAlphaRange = 0.2
            thrusters.particleScaleSpeed = -1.0
            thrusters.position = CGPoint(x: 0, y: -size.height/2)
            thrusters.zPosition = -1
            addChild(thrusters)
        }
    }
    
    private func loadShipData() {
        let shipData = GameManager.shared.getCurrentShip()
        health = shipData.health
        maxHealth = shipData.health
        speed = shipData.speed
        damage = shipData.damage
        fireRate = shipData.fireRate
        specialAbility = shipData.specialAbility
        
        // Update visuals
        createShipShape()
    }
    
    // MARK: - Movement
    func startMoving(direction: Direction) {
        switch direction {
        case .up:
            isMovingUp = true
        case .down:
            isMovingDown = true
        case .left:
            isMovingLeft = true
        case .right:
            isMovingRight = true
        }
        updateMovement()
    }
    
    func stopMoving(direction: Direction) {
        switch direction {
        case .up:
            isMovingUp = false
        case .down:
            isMovingDown = false
        case .left:
            isMovingLeft = false
        case .right:
            isMovingRight = false
        }
        updateMovement()
    }
    
    private func updateMovement() {
        velocity = CGPoint.zero
        
        if isMovingUp {
            velocity.y += CGFloat(speed * 60) // 60 pixels per second per speed unit
        }
        if isMovingDown {
            velocity.y -= CGFloat(speed * 60)
        }
        if isMovingLeft {
            velocity.x -= CGFloat(speed * 60)
        }
        if isMovingRight {
            velocity.x += CGFloat(speed * 60)
        }
        
        // Normalize diagonal movement
        if velocity.x != 0 && velocity.y != 0 {
            velocity.x *= 0.707 // 1/√2
            velocity.y *= 0.707
        }
    }
    
    func update(deltaTime: TimeInterval) {
        // Update position
        lastPosition = position
        position.x += velocity.x * CGFloat(deltaTime)
        position.y += velocity.y * CGFloat(deltaTime)
        
        // Keep player on screen
        keepOnScreen()
        
        // Update tilt based on movement
        updateTilt()
        
        // Update special cooldown
        if specialCooldown > 0 {
            specialCooldown -= deltaTime
        }
        
        // Update thruster particles based on movement
        updateThrusterEffects()
    }
    
    private func keepOnScreen() {
        guard let scene = scene else { return }
        
        let halfWidth = size.width / 2
        let halfHeight = size.height / 2
        
        if position.x < halfWidth {
            position.x = halfWidth
        } else if position.x > scene.size.width - halfWidth {
            position.x = scene.size.width - halfWidth
        }
        
        if position.y < halfHeight {
            position.y = halfHeight
        } else if position.y > scene.size.height - halfHeight {
            position.y = scene.size.height - halfHeight
        }
    }
    
    private func updateTilt() {
        let deltaX = position.x - lastPosition.x
        let targetTilt = deltaX * 0.001 // Adjust tilt sensitivity
        
        tiltAmount = tiltAmount * 0.9 + targetTilt * 0.1 // Smooth tilt
        zRotation = tiltAmount
    }
    
    private func updateThrusterEffects() {
        guard let thrusters = thrusterParticles else { return }
        
        let isMoving = velocity.x != 0 || velocity.y != 0
        thrusters.particleBirthRate = isMoving ? 100 : 20
        
        if isMoving {
            let speed = sqrt(velocity.x * velocity.x + velocity.y * velocity.y)
            thrusters.particleSpeed = 50 + speed * 0.5
        }
    }
    
    // MARK: - Combat
    func shoot() -> Bullet? {
        let currentTime = CACurrentMediaTime()
        
        if currentTime - lastShotTime >= TimeInterval(fireRate) {
            lastShotTime = currentTime
            
            let bullet = Bullet(isPlayer: true)
            bullet.position = CGPoint(x: position.x, y: position.y + size.height/2)
            bullet.damage = damage
            bullet.color = color
            
            return bullet
        }
        
        return nil
    }
    
    func useSpecialAbility() -> Bool {
        if specialCooldown > 0 { return false }
        
        specialCooldown = specialCooldownDuration
        
        switch specialAbility {
        case "Boost de Velocidade":
            return activateSpeedBoost()
        case "Rajada Tripla":
            return activateTripleShot()
        case "Míssil Devastador":
            return activateDevastatorMissile()
        case "Regeneração":
            return activateRegeneration()
        default:
            return false
        }
    }
    
    private func activateSpeedBoost() -> Bool {
        let originalSpeed = speed
        speed *= 2.0
        
        // Visual effect
        let speedEffect = SKEmitterNode()
        speedEffect.particleTexture = SKTexture()
        speedEffect.particleColor = UIColor.yellow
        speedEffect.particleSize = CGSize(width: 8, height: 8)
        speedEffect.particleBirthRate = 100
        speedEffect.particleLifetime = 0.3
        speedEffect.particleSpeed = 150
        speedEffect.position = CGPoint(x: 0, y: -size.height/2)
        addChild(speedEffect)
        
        // Restore speed after duration
        let restoreAction = SKAction.sequence([
            SKAction.wait(forDuration: 3.0),
            SKAction.run { [weak self] in
                self?.speed = originalSpeed
                speedEffect.removeFromParent()
            }
        ])
        run(restoreAction)
        
        return true
    }
    
    private func activateTripleShot() -> Bool {
        // This will be handled by the game scene to spawn 3 bullets
        return true
    }
    
    private func activateDevastatorMissile() -> Bool {
        // This will be handled by the game scene to spawn a special missile
        return true
    }
    
    private func activateRegeneration() -> Bool {
        let healAmount = maxHealth / 4
        health = min(health + healAmount, maxHealth)
        
        // Visual effect
        let healEffect = SKEmitterNode()
        healEffect.particleTexture = SKTexture()
        healEffect.particleColor = UIColor.green
        healEffect.particleSize = CGSize(width: 6, height: 6)
        healEffect.particleBirthRate = 80
        healEffect.particleLifetime = 1.0
        healEffect.particleSpeed = 50
        healEffect.emissionAngleRange = .pi * 2
        addChild(healEffect)
        
        let removeEffect = SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.run { healEffect.removeFromParent() }
        ])
        run(removeEffect)
        
        return true
    }
    
    // MARK: - Damage System
    func takeDamage(_ damage: Int) {
        health -= damage
        
        // Visual feedback
        showDamageEffect()
        flashRed()
        
        // Haptic feedback
        GameManager.shared.lightVibrate()
        
        if health <= 0 {
            health = 0
            die()
        }
    }
    
    private func showDamageEffect() {
        let damageParticles = SKEmitterNode()
        damageParticles.particleTexture = SKTexture()
        damageParticles.particleColor = UIColor.red
        damageParticles.particleSize = CGSize(width: 4, height: 4)
        damageParticles.particleBirthRate = 50
        damageParticles.particleLifetime = 0.5
        damageParticles.particleSpeed = 100
        damageParticles.emissionAngleRange = .pi * 2
        damageParticles.position = position
        
        if let scene = scene {
            scene.addChild(damageParticles)
            
            let removeAction = SKAction.sequence([
                SKAction.wait(forDuration: 0.5),
                SKAction.run { damageParticles.removeFromParent() }
            ])
            scene.run(removeAction)
        }
    }
    
    private func flashRed() {
        let originalColor = color
        color = UIColor.red
        
        let flashAction = SKAction.sequence([
            SKAction.wait(forDuration: 0.1),
            SKAction.run { [weak self] in
                self?.color = originalColor
            }
        ])
        run(flashAction)
    }
    
    private func die() {
        // Death animation
        let scaleAction = SKAction.scale(to: 0.1, duration: 0.3)
        let fadeAction = SKAction.fadeOut(withDuration: 0.3)
        let deathAction = SKAction.group([scaleAction, fadeAction])
        
        run(deathAction) { [weak self] in
            self?.removeFromParent()
        }
        
        // Create explosion effect
        createExplosionEffect()
        
        // Notify game over
        NotificationCenter.default.post(name: NSNotification.Name("PlayerDied"), object: nil)
    }
    
    private func createExplosionEffect() {
        let explosion = SKEmitterNode()
        explosion.particleTexture = SKTexture()
        explosion.particleColor = UIColor.orange
        explosion.particleColorSequence = nil
        explosion.particleSize = CGSize(width: 8, height: 8)
        explosion.particleBirthRate = 200
        explosion.particleLifetime = 1.5
        explosion.particleSpeed = 200
        explosion.particleSpeedRange = 50
        explosion.emissionAngleRange = .pi * 2
        explosion.particleScaleSpeed = -0.5
        explosion.position = position
        
        if let scene = scene {
            scene.addChild(explosion)
            
            let removeAction = SKAction.sequence([
                SKAction.wait(forDuration: 2.0),
                SKAction.run { explosion.removeFromParent() }
            ])
            scene.run(removeAction)
        }
    }
    
    // MARK: - Health Management
    func heal(_ amount: Int) {
        health = min(health + amount, maxHealth)
    }
    
    func getHealthPercentage() -> Float {
        return Float(health) / Float(maxHealth)
    }
    
    // MARK: - Special Ability Status
    func getSpecialCooldownPercentage() -> Float {
        return Float(specialCooldown / specialCooldownDuration)
    }
    
    func isSpecialReady() -> Bool {
        return specialCooldown <= 0
    }
}

// MARK: - Direction Enum
enum Direction {
    case up, down, left, right
}

// MARK: - Physics Categories
struct PhysicsCategory {
    static let none: UInt32 = 0
    static let player: UInt32 = 0b1
    static let enemy: UInt32 = 0b10
    static let playerBullet: UInt32 = 0b100
    static let enemyBullet: UInt32 = 0b1000
    static let powerUp: UInt32 = 0b10000
}
