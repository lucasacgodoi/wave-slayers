//
//  Bullet.swift
//  WaveSlayers
//
//  Created by Developer on 30/08/2025.
//  Copyright © 2025 WaveSlayers Dev. All rights reserved.
//

import SpriteKit
import UIKit

class Bullet: SKSpriteNode {
    
    // MARK: - Properties
    var velocity = CGPoint.zero
    var damage: Int = 10
    var isPlayerBullet: Bool
    var speed: Float = 400.0
    var isHoming: Bool = false
    var target = CGPoint.zero
    var homingStrength: Float = 2.0
    var lifespan: TimeInterval = 5.0
    
    private var age: TimeInterval = 0
    private var trailEffect: SKEmitterNode?
    
    // Special bullet types
    enum BulletType {
        case normal
        case laser
        case plasma
        case missile
        case explosive
    }
    
    var bulletType: BulletType = .normal
    
    // MARK: - Initialization
    init(isPlayer: Bool, type: BulletType = .normal) {
        self.isPlayerBullet = isPlayer
        self.bulletType = type
        
        let size = Self.getSizeForType(type)
        let texture = SKTexture()
        
        super.init(texture: texture, color: isPlayer ? UIColor.cyan : UIColor.red, size: size)
        
        setupBullet()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.isPlayerBullet = true
        self.bulletType = .normal
        super.init(coder: aDecoder)
        setupBullet()
    }
    
    private static func getSizeForType(_ type: BulletType) -> CGSize {
        switch type {
        case .normal:
            return CGSize(width: 4, height: 12)
        case .laser:
            return CGSize(width: 6, height: 20)
        case .plasma:
            return CGSize(width: 8, height: 16)
        case .missile:
            return CGSize(width: 6, height: 18)
        case .explosive:
            return CGSize(width: 10, height: 14)
        }
    }
    
    private func setupBullet() {
        // Physics
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.categoryBitMask = isPlayerBullet ? PhysicsCategory.playerBullet : PhysicsCategory.enemyBullet
        physicsBody?.contactTestBitMask = isPlayerBullet ? PhysicsCategory.enemy : PhysicsCategory.player
        physicsBody?.collisionBitMask = 0
        physicsBody?.affectedByGravity = false
        
        // Visual setup
        createBulletShape()
        setupTrailEffect()
        
        name = isPlayerBullet ? "playerBullet" : "enemyBullet"
        zPosition = 8
        
        // Set initial velocity
        if isPlayerBullet {
            velocity = CGPoint(x: 0, y: CGFloat(speed))
        } else {
            velocity = CGPoint(x: 0, y: -CGFloat(speed))
        }
        
        // Adjust properties based on type
        configureBulletType()
    }
    
    private func createBulletShape() {
        // Remove existing children
        removeAllChildren()
        
        switch bulletType {
        case .normal:
            createNormalBullet()
        case .laser:
            createLaserBullet()
        case .plasma:
            createPlasmaBullet()
        case .missile:
            createMissileBullet()
        case .explosive:
            createExplosiveBullet()
        }
    }
    
    private func createNormalBullet() {
        // Simple rectangular bullet
        let bulletShape = SKShapeNode(rect: CGRect(x: -size.width/2, y: -size.height/2, width: size.width, height: size.height))
        bulletShape.fillColor = color
        bulletShape.strokeColor = color.withAlphaComponent(0.8)
        bulletShape.lineWidth = 1
        addChild(bulletShape)
        
        // Add core glow
        let glow = SKSpriteNode(color: color.withAlphaComponent(0.3), size: CGSize(width: size.width + 4, height: size.height + 4))
        glow.zPosition = -1
        addChild(glow)
    }
    
    private func createLaserBullet() {
        // Laser beam style
        let core = SKShapeNode(rect: CGRect(x: -size.width/4, y: -size.height/2, width: size.width/2, height: size.height))
        core.fillColor = UIColor.white
        core.strokeColor = color
        core.lineWidth = 2
        addChild(core)
        
        // Outer glow
        let outerGlow = SKShapeNode(rect: CGRect(x: -size.width/2, y: -size.height/2, width: size.width, height: size.height))
        outerGlow.fillColor = color.withAlphaComponent(0.4)
        outerGlow.strokeColor = UIColor.clear
        outerGlow.zPosition = -1
        addChild(outerGlow)
        
        // Animate laser
        let pulseAction = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.6, duration: 0.1),
            SKAction.fadeAlpha(to: 1.0, duration: 0.1)
        ])
        core.run(SKAction.repeatForever(pulseAction))
    }
    
    private func createPlasmaBullet() {
        // Plasma ball with energy
        let core = SKShapeNode(circleOfRadius: size.width/2)
        core.fillColor = color
        core.strokeColor = UIColor.white
        core.lineWidth = 2
        addChild(core)
        
        // Energy field
        let energyField = SKShapeNode(circleOfRadius: size.width/2 + 3)
        energyField.fillColor = UIColor.clear
        energyField.strokeColor = color.withAlphaComponent(0.6)
        energyField.lineWidth = 2
        energyField.zPosition = -1
        addChild(energyField)
        
        // Animate energy field
        let expandAction = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.2),
            SKAction.scale(to: 1.0, duration: 0.2)
        ])
        energyField.run(SKAction.repeatForever(expandAction))
    }
    
    private func createMissileBullet() {
        // Missile with fins
        let body = SKShapeNode(rect: CGRect(x: -size.width/3, y: -size.height/2, width: size.width * 2/3, height: size.height))
        body.fillColor = color
        body.strokeColor = color.withAlphaComponent(0.8)
        body.lineWidth = 1
        addChild(body)
        
        // Nose cone
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -size.width/3, y: size.height/2))
        path.addLine(to: CGPoint(x: 0, y: size.height/2 + 4))
        path.addLine(to: CGPoint(x: size.width/3, y: size.height/2))
        path.addLine(to: CGPoint(x: -size.width/3, y: size.height/2))
        
        let noseCone = SKShapeNode(path: path)
        noseCone.fillColor = UIColor.white
        noseCone.strokeColor = color
        noseCone.lineWidth = 1
        addChild(noseCone)
        
        // Fins
        let leftFin = SKShapeNode(rect: CGRect(x: -size.width/2, y: -size.height/2, width: size.width/6, height: size.height/3))
        leftFin.fillColor = color.withAlphaComponent(0.7)
        addChild(leftFin)
        
        let rightFin = SKShapeNode(rect: CGRect(x: size.width/3, y: -size.height/2, width: size.width/6, height: size.height/3))
        rightFin.fillColor = color.withAlphaComponent(0.7)
        addChild(rightFin)
    }
    
    private func createExplosiveBullet() {
        // Explosive round with unstable energy
        let core = SKShapeNode(circleOfRadius: size.width/2)
        core.fillColor = color
        core.strokeColor = UIColor.orange
        core.lineWidth = 2
        addChild(core)
        
        // Unstable energy indicators
        for i in 0..<4 {
            let angle = Float(i) * .pi / 2
            let indicator = SKShapeNode(circleOfRadius: 2)
            indicator.position = CGPoint(
                x: CGFloat(cos(angle)) * size.width/3,
                y: CGFloat(sin(angle)) * size.width/3
            )
            indicator.fillColor = UIColor.orange
            indicator.strokeColor = UIColor.red
            addChild(indicator)
            
            // Animate indicators
            let flickerAction = SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.1),
                SKAction.fadeIn(withDuration: 0.1)
            ])
            indicator.run(SKAction.repeatForever(flickerAction))
        }
    }
    
    private func configureBulletType() {
        switch bulletType {
        case .normal:
            damage = isPlayerBullet ? 10 : 8
            speed = 400
            
        case .laser:
            damage = isPlayerBullet ? 15 : 12
            speed = 600
            lifespan = 3.0
            
        case .plasma:
            damage = isPlayerBullet ? 20 : 15
            speed = 350
            
        case .missile:
            damage = isPlayerBullet ? 25 : 20
            speed = 300
            isHoming = true
            homingStrength = 3.0
            
        case .explosive:
            damage = isPlayerBullet ? 30 : 25
            speed = 250
        }
    }
    
    private func setupTrailEffect() {
        trailEffect = SKEmitterNode()
        if let trail = trailEffect {
            trail.particleTexture = SKTexture()
            trail.particleColor = color.withAlphaComponent(0.6)
            trail.particleSize = CGSize(width: 2, height: 2)
            trail.particleBirthRate = 20
            trail.particleLifetime = 0.3
            trail.particleSpeed = 0
            trail.particleSpeedRange = 10
            trail.emissionAngleRange = .pi * 2
            trail.particleAlpha = 0.8
            trail.particleAlphaRange = 0.2
            trail.particleScaleSpeed = -2.0
            trail.position = CGPoint(x: 0, y: isPlayerBullet ? -size.height/2 : size.height/2)
            trail.zPosition = -1
            addChild(trail)
            
            // Adjust trail based on bullet type
            switch bulletType {
            case .laser:
                trail.particleColor = UIColor.white
                trail.particleBirthRate = 40
            case .plasma:
                trail.particleBirthRate = 60
                trail.particleLifetime = 0.5
            case .missile:
                trail.particleColor = UIColor.orange
                trail.particleBirthRate = 80
                trail.particleSpeed = 50
            case .explosive:
                trail.particleColor = UIColor.orange
                trail.particleBirthRate = 100
                // Add spark effect
                trail.particleSpeedRange = 30
            default:
                break
            }
        }
    }
    
    // MARK: - Update
    func update(deltaTime: TimeInterval, playerPosition: CGPoint? = nil) {
        age += deltaTime
        
        // Update homing behavior
        if isHoming, let targetPos = playerPosition ?? (target != CGPoint.zero ? target : nil) {
            updateHomingMovement(targetPosition: targetPos, deltaTime: deltaTime)
        }
        
        // Update position
        position.x += velocity.x * CGFloat(deltaTime)
        position.y += velocity.y * CGFloat(deltaTime)
        
        // Update visual effects based on movement
        updateVisualEffects()
        
        // Check if bullet should be removed
        if shouldBeRemoved() {
            removeFromParent()
        }
    }
    
    private func updateHomingMovement(targetPosition: CGPoint, deltaTime: TimeInterval) {
        let dx = targetPosition.x - position.x
        let dy = targetPosition.y - position.y
        let distance = sqrt(dx * dx + dy * dy)
        
        if distance > 0 {
            let normalizedX = dx / distance
            let normalizedY = dy / distance
            
            // Apply homing force
            let homingForce = CGFloat(homingStrength * 100)
            velocity.x += normalizedX * homingForce * CGFloat(deltaTime)
            velocity.y += normalizedY * homingForce * CGFloat(deltaTime)
            
            // Limit velocity
            let currentSpeed = sqrt(velocity.x * velocity.x + velocity.y * velocity.y)
            let maxSpeed = CGFloat(speed)
            
            if currentSpeed > maxSpeed {
                velocity.x = (velocity.x / currentSpeed) * maxSpeed
                velocity.y = (velocity.y / currentSpeed) * maxSpeed
            }
            
            // Rotate bullet to face movement direction
            let angle = atan2(velocity.y, velocity.x) + .pi/2
            zRotation = angle
        }
    }
    
    private func updateVisualEffects() {
        // Update trail based on speed
        if let trail = trailEffect {
            let currentSpeed = sqrt(velocity.x * velocity.x + velocity.y * velocity.y)
            let speedRatio = currentSpeed / CGFloat(speed)
            trail.particleBirthRate = 20 * speedRatio
        }
        
        // Special effects for certain bullet types
        switch bulletType {
        case .plasma:
            // Pulsing effect for plasma
            let scale = 1.0 + sin(age * 10) * 0.1
            setScale(CGFloat(scale))
            
        case .explosive:
            // Unstable flickering for explosive
            if Int(age * 20) % 3 == 0 {
                alpha = 0.8 + Float.random(in: 0...0.2)
            }
            
        default:
            break
        }
    }
    
    // MARK: - Collision Handling
    func onHit() {
        switch bulletType {
        case .explosive:
            createExplosion()
        case .plasma:
            createPlasmaBlast()
        case .laser:
            createLaserImpact()
        default:
            createHitEffect()
        }
        
        removeFromParent()
    }
    
    private func createExplosion() {
        let explosion = SKEmitterNode()
        explosion.particleTexture = SKTexture()
        explosion.particleColor = UIColor.orange
        explosion.particleColorSequence = nil
        explosion.particleSize = CGSize(width: 8, height: 8)
        explosion.particleBirthRate = 150
        explosion.particleLifetime = 0.8
        explosion.particleSpeed = 200
        explosion.particleSpeedRange = 100
        explosion.emissionAngleRange = .pi * 2
        explosion.particleScaleSpeed = -1.5
        explosion.position = position
        
        if let scene = scene {
            scene.addChild(explosion)
            
            // Create explosion damage area
            createExplosionDamage()
            
            let removeAction = SKAction.sequence([
                SKAction.wait(forDuration: 1.0),
                SKAction.run { explosion.removeFromParent() }
            ])
            scene.run(removeAction)
        }
    }
    
    private func createExplosionDamage() {
        // Create invisible damage area
        let damageArea = SKShapeNode(circleOfRadius: 40)
        damageArea.fillColor = UIColor.clear
        damageArea.strokeColor = UIColor.clear
        damageArea.position = position
        damageArea.name = "explosionDamage"
        
        // Physics for damage detection
        damageArea.physicsBody = SKPhysicsBody(circleOfRadius: 40)
        damageArea.physicsBody?.categoryBitMask = isPlayerBullet ? PhysicsCategory.playerBullet : PhysicsCategory.enemyBullet
        damageArea.physicsBody?.contactTestBitMask = isPlayerBullet ? PhysicsCategory.enemy : PhysicsCategory.player
        damageArea.physicsBody?.collisionBitMask = 0
        damageArea.physicsBody?.affectedByGravity = false
        
        if let scene = scene {
            scene.addChild(damageArea)
            
            // Remove damage area after short time
            let removeAction = SKAction.sequence([
                SKAction.wait(forDuration: 0.1),
                SKAction.run { damageArea.removeFromParent() }
            ])
            scene.run(removeAction)
        }
    }
    
    private func createPlasmaBlast() {
        let blast = SKEmitterNode()
        blast.particleTexture = SKTexture()
        blast.particleColor = color
        blast.particleSize = CGSize(width: 6, height: 6)
        blast.particleBirthRate = 100
        blast.particleLifetime = 0.6
        blast.particleSpeed = 150
        blast.particleSpeedRange = 50
        blast.emissionAngleRange = .pi * 2
        blast.particleAlpha = 0.8
        blast.particleScaleSpeed = -1.0
        blast.position = position
        
        if let scene = scene {
            scene.addChild(blast)
            
            let removeAction = SKAction.sequence([
                SKAction.wait(forDuration: 0.8),
                SKAction.run { blast.removeFromParent() }
            ])
            scene.run(removeAction)
        }
    }
    
    private func createLaserImpact() {
        let impact = SKEmitterNode()
        impact.particleTexture = SKTexture()
        impact.particleColor = UIColor.white
        impact.particleSize = CGSize(width: 4, height: 4)
        impact.particleBirthRate = 80
        impact.particleLifetime = 0.3
        impact.particleSpeed = 100
        impact.emissionAngle = atan2(velocity.y, velocity.x) + .pi
        impact.emissionAngleRange = .pi / 4
        impact.position = position
        
        if let scene = scene {
            scene.addChild(impact)
            
            let removeAction = SKAction.sequence([
                SKAction.wait(forDuration: 0.4),
                SKAction.run { impact.removeFromParent() }
            ])
            scene.run(removeAction)
        }
    }
    
    private func createHitEffect() {
        let hit = SKEmitterNode()
        hit.particleTexture = SKTexture()
        hit.particleColor = color
        hit.particleSize = CGSize(width: 3, height: 3)
        hit.particleBirthRate = 40
        hit.particleLifetime = 0.2
        hit.particleSpeed = 80
        hit.emissionAngleRange = .pi * 2
        hit.position = position
        
        if let scene = scene {
            scene.addChild(hit)
            
            let removeAction = SKAction.sequence([
                SKAction.wait(forDuration: 0.3),
                SKAction.run { hit.removeFromParent() }
            ])
            scene.run(removeAction)
        }
    }
    
    // MARK: - Utility
    func shouldBeRemoved() -> Bool {
        guard let scene = scene else { return true }
        
        // Remove if too old
        if age >= lifespan {
            return true
        }
        
        // Remove if off screen
        let margin: CGFloat = 50
        return position.x < -margin ||
               position.x > scene.size.width + margin ||
               position.y < -margin ||
               position.y > scene.size.height + margin
    }
    
    // MARK: - Special Bullet Creation
    static func createTripleShot(position: CGPoint, isPlayer: Bool) -> [Bullet] {
        var bullets: [Bullet] = []
        
        for i in 0..<3 {
            let bullet = Bullet(isPlayer: isPlayer)
            bullet.position = position
            
            // Spread the bullets
            let angle = Float(-0.3 + Float(i) * 0.3) // -0.3, 0, 0.3 radians
            let speed: Float = isPlayer ? 400 : -400
            
            bullet.velocity = CGPoint(
                x: CGFloat(sin(angle)) * 100,
                y: CGFloat(speed)
            )
            
            bullets.append(bullet)
        }
        
        return bullets
    }
    
    static func createDevastatorMissile(position: CGPoint, isPlayer: Bool) -> Bullet {
        let missile = Bullet(isPlayer: isPlayer, type: .explosive)
        missile.position = position
        missile.damage = 50
        missile.speed = 300
        missile.isHoming = true
        missile.homingStrength = 4.0
        missile.size = CGSize(width: 12, height: 24)
        
        return missile
    }
}
