//
//  ParticleSystem.swift
//  WaveSlayers
//
//  Created by Developer on 30/08/2025.
//  Copyright © 2025 WaveSlayers Dev. All rights reserved.
//

import SpriteKit
import UIKit

// MARK: - Particle Types
enum ParticleType {
    case explosion
    case smallExplosion
    case engineTrail
    case hit
    case starField
    case boost
    case shield
    case laser
    case plasma
    case missile
    case criticalHit
    case coins
    case powerup
    case teleport
    case warp
    case healing
    case damage
    case death
    case spawn
    case hyperspace
    case blackHole
    case lightning
    case fire
    case ice
    case poison
    case energy
    case debris
}

// MARK: - Particle System
class ParticleSystem {
    static let shared = ParticleSystem()
    
    private var particlePools: [ParticleType: [SKEmitterNode]] = [:]
    private let maxPoolSize = 20
    
    private init() {
        setupParticlePools()
    }
    
    private func setupParticlePools() {
        for particleType in [ParticleType.explosion, .hit, .engineTrail, .boost, .starField] {
            particlePools[particleType] = []
        }
    }
    
    // MARK: - Main Particle Creation
    func createParticle(type: ParticleType, at position: CGPoint, in scene: SKScene) -> SKEmitterNode? {
        // Try to get from pool first
        if let pooledParticle = getFromPool(type: type) {
            pooledParticle.position = position
            scene.addChild(pooledParticle)
            return pooledParticle
        }
        
        // Create new particle if pool is empty
        let particle = createNewParticle(type: type)
        particle.position = position
        scene.addChild(particle)
        
        // Auto-remove after duration
        let duration = getParticleDuration(type: type)
        let removeAction = SKAction.sequence([
            SKAction.wait(forDuration: duration),
            SKAction.run {
                self.returnToPool(particle: particle, type: type)
            }
        ])
        particle.run(removeAction)
        
        return particle
    }
    
    private func createNewParticle(type: ParticleType) -> SKEmitterNode {
        switch type {
        case .explosion:
            return createExplosion()
        case .smallExplosion:
            return createSmallExplosion()
        case .engineTrail:
            return createEngineTrail()
        case .hit:
            return createHitEffect()
        case .starField:
            return createStarField()
        case .boost:
            return createBoostEffect()
        case .shield:
            return createShieldEffect()
        case .laser:
            return createLaserEffect()
        case .plasma:
            return createPlasmaEffect()
        case .missile:
            return createMissileTrail()
        case .criticalHit:
            return createCriticalHitEffect()
        case .coins:
            return createCoinEffect()
        case .powerup:
            return createPowerUpEffect()
        case .teleport:
            return createTeleportEffect()
        case .warp:
            return createWarpEffect()
        case .healing:
            return createHealingEffect()
        case .damage:
            return createDamageEffect()
        case .death:
            return createDeathEffect()
        case .spawn:
            return createSpawnEffect()
        case .hyperspace:
            return createHyperspaceEffect()
        case .blackHole:
            return createBlackHoleEffect()
        case .lightning:
            return createLightningEffect()
        case .fire:
            return createFireEffect()
        case .ice:
            return createIceEffect()
        case .poison:
            return createPoisonEffect()
        case .energy:
            return createEnergyEffect()
        case .debris:
            return createDebrisEffect()
        }
    }
    
    // MARK: - Specific Particle Effects
    private func createExplosion() -> SKEmitterNode {
        let explosion = SKEmitterNode()
        explosion.particleTexture = createParticleTexture(size: CGSize(width: 8, height: 8), color: .orange)
        
        explosion.numParticlesToEmit = 50
        explosion.particleBirthRate = 500
        explosion.particleLifetime = 1.5
        explosion.particleLifetimeRange = 0.5
        
        explosion.particlePositionRange = CGVector(dx: 20, dy: 20)
        explosion.emissionAngleRange = CGFloat.pi * 2
        explosion.particleSpeed = 200
        explosion.particleSpeedRange = 100
        
        explosion.particleAlpha = 0.8
        explosion.particleAlphaRange = 0.2
        explosion.particleAlphaSpeed = -0.8
        
        explosion.particleScale = 0.5
        explosion.particleScaleRange = 0.3
        explosion.particleScaleSpeed = 0.5
        
        explosion.particleColor = .orange
        explosion.particleColorBlendFactor = 1.0
        explosion.particleColorSequence = createExplosionColorSequence()
        
        explosion.particleBlendMode = .add
        
        return explosion
    }
    
    private func createSmallExplosion() -> SKEmitterNode {
        let explosion = createExplosion()
        explosion.numParticlesToEmit = 25
        explosion.particleLifetime = 1.0
        explosion.particleSpeed = 150
        explosion.particleScale = 0.3
        return explosion
    }
    
    private func createEngineTrail() -> SKEmitterNode {
        let trail = SKEmitterNode()
        trail.particleTexture = createParticleTexture(size: CGSize(width: 4, height: 4), color: .cyan)
        
        trail.numParticlesToEmit = 0 // Continuous
        trail.particleBirthRate = 100
        trail.particleLifetime = 0.8
        trail.particleLifetimeRange = 0.2
        
        trail.particlePositionRange = CGVector(dx: 5, dy: 5)
        trail.emissionAngle = CGFloat.pi
        trail.emissionAngleRange = CGFloat.pi / 6
        trail.particleSpeed = 80
        trail.particleSpeedRange = 20
        
        trail.particleAlpha = 0.6
        trail.particleAlphaSpeed = -0.8
        
        trail.particleScale = 0.3
        trail.particleScaleSpeed = -0.3
        
        trail.particleColor = .cyan
        trail.particleColorSequence = createTrailColorSequence()
        trail.particleBlendMode = .add
        
        return trail
    }
    
    private func createHitEffect() -> SKEmitterNode {
        let hit = SKEmitterNode()
        hit.particleTexture = createParticleTexture(size: CGSize(width: 6, height: 6), color: .white)
        
        hit.numParticlesToEmit = 20
        hit.particleBirthRate = 200
        hit.particleLifetime = 0.5
        hit.particleLifetimeRange = 0.2
        
        hit.particlePositionRange = CGVector(dx: 10, dy: 10)
        hit.emissionAngleRange = CGFloat.pi * 2
        hit.particleSpeed = 100
        hit.particleSpeedRange = 50
        
        hit.particleAlpha = 1.0
        hit.particleAlphaSpeed = -2.0
        
        hit.particleScale = 0.4
        hit.particleScaleSpeed = 0.2
        
        hit.particleColor = .white
        hit.particleColorSequence = createHitColorSequence()
        hit.particleBlendMode = .add
        
        return hit
    }
    
    private func createStarField() -> SKEmitterNode {
        let stars = SKEmitterNode()
        stars.particleTexture = createParticleTexture(size: CGSize(width: 2, height: 2), color: .white)
        
        stars.numParticlesToEmit = 0 // Continuous
        stars.particleBirthRate = 5
        stars.particleLifetime = 10
        stars.particleLifetimeRange = 5
        
        stars.particlePositionRange = CGVector(dx: UIScreen.main.bounds.width, dy: 0)
        stars.emissionAngle = CGFloat.pi / 2
        stars.particleSpeed = 30
        stars.particleSpeedRange = 20
        
        stars.particleAlpha = 0.8
        stars.particleAlphaRange = 0.4
        
        stars.particleScale = 0.5
        stars.particleScaleRange = 0.3
        
        stars.particleColor = .white
        stars.particleColorSequence = createStarColorSequence()
        
        return stars
    }
    
    private func createBoostEffect() -> SKEmitterNode {
        let boost = SKEmitterNode()
        boost.particleTexture = createParticleTexture(size: CGSize(width: 6, height: 6), color: .yellow)
        
        boost.numParticlesToEmit = 0 // Continuous
        boost.particleBirthRate = 150
        boost.particleLifetime = 0.6
        boost.particleLifetimeRange = 0.2
        
        boost.particlePositionRange = CGVector(dx: 8, dy: 8)
        boost.emissionAngle = CGFloat.pi
        boost.emissionAngleRange = CGFloat.pi / 4
        boost.particleSpeed = 120
        boost.particleSpeedRange = 40
        
        boost.particleAlpha = 0.9
        boost.particleAlphaSpeed = -1.5
        
        boost.particleScale = 0.4
        boost.particleScaleSpeed = -0.4
        
        boost.particleColor = .yellow
        boost.particleColorSequence = createBoostColorSequence()
        boost.particleBlendMode = .add
        
        return boost
    }
    
    private func createShieldEffect() -> SKEmitterNode {
        let shield = SKEmitterNode()
        shield.particleTexture = createParticleTexture(size: CGSize(width: 4, height: 4), color: .blue)
        
        shield.numParticlesToEmit = 0 // Continuous
        shield.particleBirthRate = 50
        shield.particleLifetime = 2.0
        shield.particleLifetimeRange = 0.5
        
        shield.particlePositionRange = CGVector(dx: 40, dy: 40)
        shield.emissionAngleRange = CGFloat.pi * 2
        shield.particleSpeed = 20
        shield.particleSpeedRange = 10
        
        shield.particleAlpha = 0.5
        shield.particleAlphaRange = 0.2
        shield.particleAlphaSpeed = -0.25
        
        shield.particleScale = 0.3
        shield.particleScaleRange = 0.1
        
        shield.particleColor = .cyan
        shield.particleColorSequence = createShieldColorSequence()
        shield.particleBlendMode = .add
        
        return shield
    }
    
    private func createLaserEffect() -> SKEmitterNode {
        let laser = SKEmitterNode()
        laser.particleTexture = createParticleTexture(size: CGSize(width: 3, height: 3), color: .red)
        
        laser.numParticlesToEmit = 10
        laser.particleBirthRate = 100
        laser.particleLifetime = 0.3
        laser.particleLifetimeRange = 0.1
        
        laser.particlePositionRange = CGVector(dx: 2, dy: 2)
        laser.emissionAngleRange = CGFloat.pi / 8
        laser.particleSpeed = 50
        laser.particleSpeedRange = 20
        
        laser.particleAlpha = 1.0
        laser.particleAlphaSpeed = -3.0
        
        laser.particleScale = 0.2
        laser.particleScaleSpeed = 0.1
        
        laser.particleColor = .red
        laser.particleBlendMode = .add
        
        return laser
    }
    
    private func createPlasmaEffect() -> SKEmitterNode {
        let plasma = SKEmitterNode()
        plasma.particleTexture = createParticleTexture(size: CGSize(width: 5, height: 5), color: .green)
        
        plasma.numParticlesToEmit = 15
        plasma.particleBirthRate = 150
        plasma.particleLifetime = 0.4
        plasma.particleLifetimeRange = 0.1
        
        plasma.particlePositionRange = CGVector(dx: 4, dy: 4)
        plasma.emissionAngleRange = CGFloat.pi / 6
        plasma.particleSpeed = 60
        plasma.particleSpeedRange = 25
        
        plasma.particleAlpha = 0.8
        plasma.particleAlphaSpeed = -2.0
        
        plasma.particleScale = 0.3
        plasma.particleScaleSpeed = 0.2
        
        plasma.particleColor = .green
        plasma.particleColorSequence = createPlasmaColorSequence()
        plasma.particleBlendMode = .add
        
        return plasma
    }
    
    private func createMissileTrail() -> SKEmitterNode {
        let trail = SKEmitterNode()
        trail.particleTexture = createParticleTexture(size: CGSize(width: 4, height: 4), color: .orange)
        
        trail.numParticlesToEmit = 0 // Continuous
        trail.particleBirthRate = 80
        trail.particleLifetime = 1.0
        trail.particleLifetimeRange = 0.3
        
        trail.particlePositionRange = CGVector(dx: 3, dy: 3)
        trail.emissionAngle = CGFloat.pi
        trail.emissionAngleRange = CGFloat.pi / 8
        trail.particleSpeed = 40
        trail.particleSpeedRange = 15
        
        trail.particleAlpha = 0.7
        trail.particleAlphaSpeed = -0.7
        
        trail.particleScale = 0.2
        trail.particleScaleSpeed = -0.2
        
        trail.particleColor = .orange
        trail.particleColorSequence = createMissileColorSequence()
        trail.particleBlendMode = .add
        
        return trail
    }
    
    private func createCriticalHitEffect() -> SKEmitterNode {
        let crit = createHitEffect()
        crit.numParticlesToEmit = 40
        crit.particleLifetime = 0.8
        crit.particleSpeed = 150
        crit.particleScale = 0.6
        crit.particleColor = .yellow
        crit.particleColorSequence = createCriticalColorSequence()
        return crit
    }
    
    private func createCoinEffect() -> SKEmitterNode {
        let coins = SKEmitterNode()
        coins.particleTexture = createParticleTexture(size: CGSize(width: 6, height: 6), color: .yellow)
        
        coins.numParticlesToEmit = 8
        coins.particleBirthRate = 80
        coins.particleLifetime = 1.2
        coins.particleLifetimeRange = 0.3
        
        coins.particlePositionRange = CGVector(dx: 15, dy: 15)
        coins.emissionAngleRange = CGFloat.pi * 2
        coins.particleSpeed = 80
        coins.particleSpeedRange = 40
        
        coins.particleAlpha = 1.0
        coins.particleAlphaSpeed = -0.8
        
        coins.particleScale = 0.4
        coins.particleScaleSpeed = 0.1
        
        coins.particleColor = .yellow
        coins.particleColorSequence = createCoinColorSequence()
        coins.particleBlendMode = .add
        
        return coins
    }
    
    private func createPowerUpEffect() -> SKEmitterNode {
        let powerup = SKEmitterNode()
        powerup.particleTexture = createParticleTexture(size: CGSize(width: 8, height: 8), color: .magenta)
        
        powerup.numParticlesToEmit = 30
        powerup.particleBirthRate = 300
        powerup.particleLifetime = 1.0
        powerup.particleLifetimeRange = 0.4
        
        powerup.particlePositionRange = CGVector(dx: 20, dy: 20)
        powerup.emissionAngleRange = CGFloat.pi * 2
        powerup.particleSpeed = 100
        powerup.particleSpeedRange = 50
        
        powerup.particleAlpha = 0.9
        powerup.particleAlphaSpeed = -0.9
        
        powerup.particleScale = 0.3
        powerup.particleScaleSpeed = 0.3
        
        powerup.particleColor = .magenta
        powerup.particleColorSequence = createPowerUpColorSequence()
        powerup.particleBlendMode = .add
        
        return powerup
    }
    
    private func createTeleportEffect() -> SKEmitterNode {
        let teleport = SKEmitterNode()
        teleport.particleTexture = createParticleTexture(size: CGSize(width: 6, height: 6), color: .purple)
        
        teleport.numParticlesToEmit = 50
        teleport.particleBirthRate = 500
        teleport.particleLifetime = 0.8
        teleport.particleLifetimeRange = 0.2
        
        teleport.particlePositionRange = CGVector(dx: 30, dy: 30)
        teleport.emissionAngleRange = CGFloat.pi * 2
        teleport.particleSpeed = 120
        teleport.particleSpeedRange = 60
        
        teleport.particleAlpha = 0.8
        teleport.particleAlphaSpeed = -1.0
        
        teleport.particleScale = 0.4
        teleport.particleScaleSpeed = -0.2
        
        teleport.particleColor = .purple
        teleport.particleColorSequence = createTeleportColorSequence()
        teleport.particleBlendMode = .add
        
        return teleport
    }
    
    private func createWarpEffect() -> SKEmitterNode {
        let warp = SKEmitterNode()
        warp.particleTexture = createParticleTexture(size: CGSize(width: 2, height: 20), color: .white)
        
        warp.numParticlesToEmit = 100
        warp.particleBirthRate = 1000
        warp.particleLifetime = 0.5
        warp.particleLifetimeRange = 0.1
        
        warp.particlePositionRange = CGVector(dx: UIScreen.main.bounds.width, dy: UIScreen.main.bounds.height)
        warp.emissionAngle = CGFloat.pi / 2
        warp.emissionAngleRange = CGFloat.pi / 12
        warp.particleSpeed = 800
        warp.particleSpeedRange = 200
        
        warp.particleAlpha = 0.9
        warp.particleAlphaSpeed = -1.8
        
        warp.particleScale = 0.5
        warp.particleScaleSpeed = -0.5
        
        warp.particleColor = .white
        warp.particleBlendMode = .add
        
        return warp
    }
    
    private func createHealingEffect() -> SKEmitterNode {
        let healing = SKEmitterNode()
        healing.particleTexture = createParticleTexture(size: CGSize(width: 5, height: 5), color: .green)
        
        healing.numParticlesToEmit = 20
        healing.particleBirthRate = 200
        healing.particleLifetime = 1.5
        healing.particleLifetimeRange = 0.5
        
        healing.particlePositionRange = CGVector(dx: 25, dy: 25)
        healing.emissionAngleRange = CGFloat.pi * 2
        healing.particleSpeed = 30
        healing.particleSpeedRange = 15
        
        healing.particleAlpha = 0.7
        healing.particleAlphaSpeed = -0.5
        
        healing.particleScale = 0.3
        healing.particleScaleSpeed = 0.2
        
        healing.particleColor = .green
        healing.particleColorSequence = createHealingColorSequence()
        healing.particleBlendMode = .add
        
        return healing
    }
    
    private func createDamageEffect() -> SKEmitterNode {
        let damage = SKEmitterNode()
        damage.particleTexture = createParticleTexture(size: CGSize(width: 4, height: 4), color: .red)
        
        damage.numParticlesToEmit = 25
        damage.particleBirthRate = 250
        damage.particleLifetime = 0.6
        damage.particleLifetimeRange = 0.2
        
        damage.particlePositionRange = CGVector(dx: 20, dy: 20)
        damage.emissionAngleRange = CGFloat.pi * 2
        damage.particleSpeed = 80
        damage.particleSpeedRange = 40
        
        damage.particleAlpha = 0.8
        damage.particleAlphaSpeed = -1.3
        
        damage.particleScale = 0.3
        damage.particleScaleSpeed = 0.1
        
        damage.particleColor = .red
        damage.particleColorSequence = createDamageColorSequence()
        damage.particleBlendMode = .add
        
        return damage
    }
    
    private func createDeathEffect() -> SKEmitterNode {
        let death = createExplosion()
        death.numParticlesToEmit = 80
        death.particleLifetime = 2.0
        death.particleSpeed = 250
        death.particleScale = 0.7
        death.particleColorSequence = createDeathColorSequence()
        return death
    }
    
    private func createSpawnEffect() -> SKEmitterNode {
        let spawn = SKEmitterNode()
        spawn.particleTexture = createParticleTexture(size: CGSize(width: 6, height: 6), color: .cyan)
        
        spawn.numParticlesToEmit = 40
        spawn.particleBirthRate = 400
        spawn.particleLifetime = 1.0
        spawn.particleLifetimeRange = 0.3
        
        spawn.particlePositionRange = CGVector(dx: 5, dy: 5)
        spawn.emissionAngleRange = CGFloat.pi * 2
        spawn.particleSpeed = 100
        spawn.particleSpeedRange = 50
        
        spawn.particleAlpha = 0.0
        spawn.particleAlphaSpeed = 2.0
        
        spawn.particleScale = 0.1
        spawn.particleScaleSpeed = 0.4
        
        spawn.particleColor = .cyan
        spawn.particleColorSequence = createSpawnColorSequence()
        spawn.particleBlendMode = .add
        
        return spawn
    }
    
    private func createHyperspaceEffect() -> SKEmitterNode {
        let hyperspace = SKEmitterNode()
        hyperspace.particleTexture = createParticleTexture(size: CGSize(width: 1, height: 30), color: .white)
        
        hyperspace.numParticlesToEmit = 200
        hyperspace.particleBirthRate = 2000
        hyperspace.particleLifetime = 0.3
        hyperspace.particleLifetimeRange = 0.1
        
        hyperspace.particlePositionRange = CGVector(dx: UIScreen.main.bounds.width, dy: UIScreen.main.bounds.height)
        hyperspace.emissionAngle = CGFloat.pi / 2
        hyperspace.emissionAngleRange = CGFloat.pi / 20
        hyperspace.particleSpeed = 1200
        hyperspace.particleSpeedRange = 300
        
        hyperspace.particleAlpha = 1.0
        hyperspace.particleAlphaSpeed = -3.0
        
        hyperspace.particleScale = 0.3
        hyperspace.particleScaleSpeed = 0.2
        
        hyperspace.particleColor = .white
        hyperspace.particleBlendMode = .add
        
        return hyperspace
    }
    
    private func createBlackHoleEffect() -> SKEmitterNode {
        let blackHole = SKEmitterNode()
        blackHole.particleTexture = createParticleTexture(size: CGSize(width: 4, height: 4), color: .purple)
        
        blackHole.numParticlesToEmit = 0 // Continuous
        blackHole.particleBirthRate = 100
        blackHole.particleLifetime = 3.0
        blackHole.particleLifetimeRange = 1.0
        
        blackHole.particlePositionRange = CGVector(dx: 100, dy: 100)
        blackHole.emissionAngleRange = CGFloat.pi * 2
        blackHole.particleSpeed = -50 // Negative for inward movement
        blackHole.particleSpeedRange = 30
        
        blackHole.particleAlpha = 0.8
        blackHole.particleAlphaSpeed = 0.2
        
        blackHole.particleScale = 0.2
        blackHole.particleScaleSpeed = -0.1
        
        blackHole.particleColor = .purple
        blackHole.particleColorSequence = createBlackHoleColorSequence()
        blackHole.particleBlendMode = .add
        
        return blackHole
    }
    
    private func createLightningEffect() -> SKEmitterNode {
        let lightning = SKEmitterNode()
        lightning.particleTexture = createParticleTexture(size: CGSize(width: 3, height: 15), color: .yellow)
        
        lightning.numParticlesToEmit = 15
        lightning.particleBirthRate = 150
        lightning.particleLifetime = 0.2
        lightning.particleLifetimeRange = 0.1
        
        lightning.particlePositionRange = CGVector(dx: 10, dy: 10)
        lightning.emissionAngleRange = CGFloat.pi * 2
        lightning.particleSpeed = 200
        lightning.particleSpeedRange = 100
        
        lightning.particleAlpha = 1.0
        lightning.particleAlphaSpeed = -5.0
        
        lightning.particleScale = 0.4
        lightning.particleScaleSpeed = 0.3
        
        lightning.particleColor = .yellow
        lightning.particleColorSequence = createLightningColorSequence()
        lightning.particleBlendMode = .add
        
        return lightning
    }
    
    private func createFireEffect() -> SKEmitterNode {
        let fire = SKEmitterNode()
        fire.particleTexture = createParticleTexture(size: CGSize(width: 6, height: 6), color: .red)
        
        fire.numParticlesToEmit = 30
        fire.particleBirthRate = 300
        fire.particleLifetime = 1.0
        fire.particleLifetimeRange = 0.5
        
        fire.particlePositionRange = CGVector(dx: 15, dy: 15)
        fire.emissionAngleRange = CGFloat.pi * 2
        fire.particleSpeed = 60
        fire.particleSpeedRange = 30
        
        fire.particleAlpha = 0.8
        fire.particleAlphaSpeed = -0.8
        
        fire.particleScale = 0.3
        fire.particleScaleSpeed = 0.2
        
        fire.particleColor = .red
        fire.particleColorSequence = createFireColorSequence()
        fire.particleBlendMode = .add
        
        return fire
    }
    
    private func createIceEffect() -> SKEmitterNode {
        let ice = SKEmitterNode()
        ice.particleTexture = createParticleTexture(size: CGSize(width: 5, height: 5), color: .cyan)
        
        ice.numParticlesToEmit = 25
        ice.particleBirthRate = 250
        ice.particleLifetime = 1.5
        ice.particleLifetimeRange = 0.5
        
        ice.particlePositionRange = CGVector(dx: 20, dy: 20)
        ice.emissionAngleRange = CGFloat.pi * 2
        ice.particleSpeed = 40
        ice.particleSpeedRange = 20
        
        ice.particleAlpha = 0.7
        ice.particleAlphaSpeed = -0.5
        
        ice.particleScale = 0.2
        ice.particleScaleSpeed = 0.3
        
        ice.particleColor = .cyan
        ice.particleColorSequence = createIceColorSequence()
        ice.particleBlendMode = .add
        
        return ice
    }
    
    private func createPoisonEffect() -> SKEmitterNode {
        let poison = SKEmitterNode()
        poison.particleTexture = createParticleTexture(size: CGSize(width: 4, height: 4), color: .green)
        
        poison.numParticlesToEmit = 20
        poison.particleBirthRate = 200
        poison.particleLifetime = 2.0
        poison.particleLifetimeRange = 0.8
        
        poison.particlePositionRange = CGVector(dx: 18, dy: 18)
        poison.emissionAngleRange = CGFloat.pi * 2
        poison.particleSpeed = 25
        poison.particleSpeedRange = 15
        
        poison.particleAlpha = 0.6
        poison.particleAlphaSpeed = -0.3
        
        poison.particleScale = 0.2
        poison.particleScaleSpeed = 0.1
        
        poison.particleColor = .green
        poison.particleColorSequence = createPoisonColorSequence()
        poison.particleBlendMode = .add
        
        return poison
    }
    
    private func createEnergyEffect() -> SKEmitterNode {
        let energy = SKEmitterNode()
        energy.particleTexture = createParticleTexture(size: CGSize(width: 3, height: 3), color: .blue)
        
        energy.numParticlesToEmit = 0 // Continuous
        energy.particleBirthRate = 80
        energy.particleLifetime = 1.0
        energy.particleLifetimeRange = 0.3
        
        energy.particlePositionRange = CGVector(dx: 12, dy: 12)
        energy.emissionAngleRange = CGFloat.pi * 2
        energy.particleSpeed = 60
        energy.particleSpeedRange = 30
        
        energy.particleAlpha = 0.8
        energy.particleAlphaSpeed = -0.8
        
        energy.particleScale = 0.2
        energy.particleScaleSpeed = 0.1
        
        energy.particleColor = .blue
        energy.particleColorSequence = createEnergyColorSequence()
        energy.particleBlendMode = .add
        
        return energy
    }
    
    private func createDebrisEffect() -> SKEmitterNode {
        let debris = SKEmitterNode()
        debris.particleTexture = createParticleTexture(size: CGSize(width: 3, height: 3), color: .gray)
        
        debris.numParticlesToEmit = 30
        debris.particleBirthRate = 300
        debris.particleLifetime = 2.0
        debris.particleLifetimeRange = 1.0
        
        debris.particlePositionRange = CGVector(dx: 25, dy: 25)
        debris.emissionAngleRange = CGFloat.pi * 2
        debris.particleSpeed = 100
        debris.particleSpeedRange = 80
        
        debris.particleAlpha = 0.9
        debris.particleAlphaSpeed = -0.4
        
        debris.particleScale = 0.3
        debris.particleScaleRange = 0.2
        debris.particleScaleSpeed = -0.1
        
        debris.particleColor = .gray
        debris.particleColorSequence = createDebrisColorSequence()
        
        return debris
    }
    
    // MARK: - Color Sequences
    private func createExplosionColorSequence() -> SKKeyframeSequence {
        let sequence = SKKeyframeSequence(keyframeValues: [
            UIColor.yellow,
            UIColor.orange,
            UIColor.red,
            UIColor.clear
        ], times: [0.0, 0.3, 0.7, 1.0])
        return sequence
    }
    
    private func createTrailColorSequence() -> SKKeyframeSequence {
        let sequence = SKKeyframeSequence(keyframeValues: [
            UIColor.cyan,
            UIColor.blue,
            UIColor.clear
        ], times: [0.0, 0.5, 1.0])
        return sequence
    }
    
    private func createHitColorSequence() -> SKKeyframeSequence {
        let sequence = SKKeyframeSequence(keyframeValues: [
            UIColor.white,
            UIColor.yellow,
            UIColor.clear
        ], times: [0.0, 0.4, 1.0])
        return sequence
    }
    
    private func createStarColorSequence() -> SKKeyframeSequence {
        let sequence = SKKeyframeSequence(keyframeValues: [
            UIColor.white,
            UIColor(red: 0.8, green: 0.8, blue: 1.0, alpha: 1.0),
            UIColor.white
        ], times: [0.0, 0.5, 1.0])
        return sequence
    }
    
    private func createBoostColorSequence() -> SKKeyframeSequence {
        let sequence = SKKeyframeSequence(keyframeValues: [
            UIColor.yellow,
            UIColor.orange,
            UIColor.clear
        ], times: [0.0, 0.6, 1.0])
        return sequence
    }
    
    private func createShieldColorSequence() -> SKKeyframeSequence {
        let sequence = SKKeyframeSequence(keyframeValues: [
            UIColor.cyan,
            UIColor.blue,
            UIColor.cyan,
            UIColor.clear
        ], times: [0.0, 0.3, 0.7, 1.0])
        return sequence
    }
    
    private func createPlasmaColorSequence() -> SKKeyframeSequence {
        let sequence = SKKeyframeSequence(keyframeValues: [
            UIColor.green,
            UIColor.yellow,
            UIColor.clear
        ], times: [0.0, 0.5, 1.0])
        return sequence
    }
    
    private func createMissileColorSequence() -> SKKeyframeSequence {
        let sequence = SKKeyframeSequence(keyframeValues: [
            UIColor.orange,
            UIColor.red,
            UIColor.clear
        ], times: [0.0, 0.6, 1.0])
        return sequence
    }
    
    private func createCriticalColorSequence() -> SKKeyframeSequence {
        let sequence = SKKeyframeSequence(keyframeValues: [
            UIColor.yellow,
            UIColor.orange,
            UIColor.yellow,
            UIColor.clear
        ], times: [0.0, 0.2, 0.6, 1.0])
        return sequence
    }
    
    private func createCoinColorSequence() -> SKKeyframeSequence {
        let sequence = SKKeyframeSequence(keyframeValues: [
            UIColor.yellow,
            UIColor.orange,
            UIColor.yellow,
            UIColor.clear
        ], times: [0.0, 0.4, 0.8, 1.0])
        return sequence
    }
    
    private func createPowerUpColorSequence() -> SKKeyframeSequence {
        let sequence = SKKeyframeSequence(keyframeValues: [
            UIColor.magenta,
            UIColor.purple,
            UIColor.blue,
            UIColor.clear
        ], times: [0.0, 0.3, 0.7, 1.0])
        return sequence
    }
    
    private func createTeleportColorSequence() -> SKKeyframeSequence {
        let sequence = SKKeyframeSequence(keyframeValues: [
            UIColor.purple,
            UIColor.magenta,
            UIColor.clear
        ], times: [0.0, 0.5, 1.0])
        return sequence
    }
    
    private func createHealingColorSequence() -> SKKeyframeSequence {
        let sequence = SKKeyframeSequence(keyframeValues: [
            UIColor.green,
            UIColor.yellow,
            UIColor.green,
            UIColor.clear
        ], times: [0.0, 0.3, 0.7, 1.0])
        return sequence
    }
    
    private func createDamageColorSequence() -> SKKeyframeSequence {
        let sequence = SKKeyframeSequence(keyframeValues: [
            UIColor.red,
            UIColor.orange,
            UIColor.clear
        ], times: [0.0, 0.5, 1.0])
        return sequence
    }
    
    private func createDeathColorSequence() -> SKKeyframeSequence {
        let sequence = SKKeyframeSequence(keyframeValues: [
            UIColor.white,
            UIColor.red,
            UIColor.black,
            UIColor.clear
        ], times: [0.0, 0.2, 0.7, 1.0])
        return sequence
    }
    
    private func createSpawnColorSequence() -> SKKeyframeSequence {
        let sequence = SKKeyframeSequence(keyframeValues: [
            UIColor.clear,
            UIColor.cyan,
            UIColor.white,
            UIColor.cyan
        ], times: [0.0, 0.3, 0.6, 1.0])
        return sequence
    }
    
    private func createBlackHoleColorSequence() -> SKKeyframeSequence {
        let sequence = SKKeyframeSequence(keyframeValues: [
            UIColor.purple,
            UIColor.black,
            UIColor.purple
        ], times: [0.0, 0.5, 1.0])
        return sequence
    }
    
    private func createLightningColorSequence() -> SKKeyframeSequence {
        let sequence = SKKeyframeSequence(keyframeValues: [
            UIColor.white,
            UIColor.yellow,
            UIColor.blue,
            UIColor.clear
        ], times: [0.0, 0.2, 0.6, 1.0])
        return sequence
    }
    
    private func createFireColorSequence() -> SKKeyframeSequence {
        let sequence = SKKeyframeSequence(keyframeValues: [
            UIColor.yellow,
            UIColor.orange,
            UIColor.red,
            UIColor.clear
        ], times: [0.0, 0.3, 0.7, 1.0])
        return sequence
    }
    
    private func createIceColorSequence() -> SKKeyframeSequence {
        let sequence = SKKeyframeSequence(keyframeValues: [
            UIColor.white,
            UIColor.cyan,
            UIColor.blue,
            UIColor.clear
        ], times: [0.0, 0.3, 0.7, 1.0])
        return sequence
    }
    
    private func createPoisonColorSequence() -> SKKeyframeSequence {
        let sequence = SKKeyframeSequence(keyframeValues: [
            UIColor.green,
            UIColor.yellow,
            UIColor.green,
            UIColor.clear
        ], times: [0.0, 0.4, 0.8, 1.0])
        return sequence
    }
    
    private func createEnergyColorSequence() -> SKKeyframeSequence {
        let sequence = SKKeyframeSequence(keyframeValues: [
            UIColor.blue,
            UIColor.cyan,
            UIColor.white,
            UIColor.clear
        ], times: [0.0, 0.3, 0.7, 1.0])
        return sequence
    }
    
    private func createDebrisColorSequence() -> SKKeyframeSequence {
        let sequence = SKKeyframeSequence(keyframeValues: [
            UIColor.gray,
            UIColor.darkGray,
            UIColor.black,
            UIColor.clear
        ], times: [0.0, 0.4, 0.8, 1.0])
        return sequence
    }
    
    // MARK: - Helper Methods
    private func createParticleTexture(size: CGSize, color: UIColor) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
        return SKTexture(image: image)
    }
    
    private func getParticleDuration(type: ParticleType) -> TimeInterval {
        switch type {
        case .explosion, .smallExplosion, .death:
            return 2.0
        case .hit, .laser, .lightning:
            return 0.5
        case .engineTrail, .boost, .missile:
            return 1.0
        case .starField:
            return 15.0
        case .shield, .energy:
            return 3.0
        case .criticalHit, .coins, .powerup:
            return 1.5
        case .teleport, .warp, .hyperspace:
            return 1.0
        case .healing, .damage:
            return 1.0
        case .spawn:
            return 1.2
        case .blackHole:
            return 5.0
        case .fire, .ice, .poison:
            return 2.0
        case .plasma:
            return 0.6
        case .debris:
            return 3.0
        }
    }
    
    // MARK: - Pool Management
    private func getFromPool(type: ParticleType) -> SKEmitterNode? {
        guard var pool = particlePools[type], !pool.isEmpty else { return nil }
        
        let particle = pool.removeLast()
        particlePools[type] = pool
        
        // Reset particle properties
        particle.resetSimulation()
        particle.alpha = 1.0
        particle.isHidden = false
        
        return particle
    }
    
    private func returnToPool(particle: SKEmitterNode, type: ParticleType) {
        particle.removeFromParent()
        
        if var pool = particlePools[type], pool.count < maxPoolSize {
            pool.append(particle)
            particlePools[type] = pool
        }
    }
    
    // MARK: - Convenience Methods
    func createExplosionAt(_ position: CGPoint, in scene: SKScene, scale: CGFloat = 1.0) {
        if let explosion = createParticle(type: .explosion, at: position, in: scene) {
            explosion.particleScale *= scale
            explosion.particleSpeed *= scale
        }
    }
    
    func createHitEffectAt(_ position: CGPoint, in scene: SKScene, critical: Bool = false) {
        let type: ParticleType = critical ? .criticalHit : .hit
        createParticle(type: type, at: position, in: scene)
    }
    
    func createTrailFor(node: SKNode, type: ParticleType = .engineTrail) -> SKEmitterNode? {
        let trail = createNewParticle(type: type)
        node.addChild(trail)
        return trail
    }
    
    func createShieldFor(node: SKNode) -> SKEmitterNode? {
        let shield = createNewParticle(type: .shield)
        node.addChild(shield)
        return shield
    }
    
    func stopAllParticles(in node: SKNode) {
        node.enumerateChildNodes(withName: "*") { child, _ in
            if let emitter = child as? SKEmitterNode {
                emitter.numParticlesToEmit = 0
                let removeAction = SKAction.sequence([
                    SKAction.wait(forDuration: TimeInterval(emitter.particleLifetime)),
                    SKAction.removeFromParent()
                ])
                emitter.run(removeAction)
            }
        }
    }
    
    func removeAllParticles(in node: SKNode) {
        node.enumerateChildNodes(withName: "*") { child, _ in
            if child is SKEmitterNode {
                child.removeFromParent()
            }
        }
    }
}
