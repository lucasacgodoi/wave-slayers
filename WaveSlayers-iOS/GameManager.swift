//
//  GameManager.swift
//  WaveSlayers
//
//  Created by Developer on 30/08/2025.
//  Copyright © 2025 WaveSlayers Dev. All rights reserved.
//

import Foundation
import SpriteKit

// MARK: - Game States
enum GameState {
    case menu
    case playing
    case paused
    case gameOver
    case progression
    case achievements
    case battlepass
    case shipCustomization
    case leaderboard
    case clan
    case communityEvents
    case multiplayer
}

// MARK: - World Data
struct WorldData {
    let id: String
    let name: String
    let description: String
    let price: Int
    let unlocked: Bool
    let backgroundColor: UIColor
    let starColor: UIColor
    let enemyTypes: [EnemyType]
    let difficulty: Float
}

// MARK: - Ship Data
struct ShipData {
    let id: String
    let name: String
    let description: String
    let health: Int
    let speed: Float
    let damage: Int
    let fireRate: Float
    let specialAbility: String
    let price: Int
    let rarity: ShipRarity
    let color: UIColor
}

enum ShipRarity: String, CaseIterable {
    case common = "Comum"
    case rare = "Raro"
    case epic = "Épico"
    case legendary = "Lendário"
}

// MARK: - Game Manager
class GameManager {
    static let shared = GameManager()
    
    // MARK: - Game State
    var gameState: GameState = .menu
    var isGameRunning = false
    var isPaused = false
    
    // MARK: - Player Stats
    var score = 0
    var level = 1
    var survivalTime: TimeInterval = 0
    var coinsThisRound = 0
    
    // MARK: - Persistent Data
    var coins: Int {
        get { UserDefaults.standard.integer(forKey: "waveslayers_coins") }
        set { UserDefaults.standard.set(newValue, forKey: "waveslayers_coins") }
    }
    
    var currentWorldId: String {
        get { UserDefaults.standard.string(forKey: "waveslayers_current_world") ?? "earth" }
        set { UserDefaults.standard.set(newValue, forKey: "waveslayers_current_world") }
    }
    
    var currentShipId: String {
        get { UserDefaults.standard.string(forKey: "waveslayers_current_ship") ?? "interceptor" }
        set { UserDefaults.standard.set(newValue, forKey: "waveslayers_current_ship") }
    }
    
    var unlockedShips: [String] {
        get { UserDefaults.standard.stringArray(forKey: "waveslayers_unlocked_ships") ?? ["interceptor"] }
        set { UserDefaults.standard.set(newValue, forKey: "waveslayers_unlocked_ships") }
    }
    
    var unlockedWorlds: [String] {
        get { UserDefaults.standard.stringArray(forKey: "waveslayers_unlocked_worlds") ?? ["earth"] }
        set { UserDefaults.standard.set(newValue, forKey: "waveslayers_unlocked_worlds") }
    }
    
    // MARK: - World Definitions
    let worlds: [String: WorldData] = [
        "earth": WorldData(
            id: "earth",
            name: "Terra",
            description: "Nosso planeta natal, com inimigos básicos para treinar suas habilidades.",
            price: 0,
            unlocked: true,
            backgroundColor: UIColor(red: 0.1, green: 0.3, blue: 0.6, alpha: 1.0),
            starColor: UIColor.white,
            enemyTypes: [.grunt, .scout],
            difficulty: 1.0
        ),
        "mars": WorldData(
            id: "mars",
            name: "Marte",
            description: "O planeta vermelho, com tempestades de areia e inimigos mais agressivos.",
            price: 500,
            unlocked: false,
            backgroundColor: UIColor(red: 0.8, green: 0.3, blue: 0.2, alpha: 1.0),
            starColor: UIColor(red: 1.0, green: 0.8, blue: 0.6, alpha: 1.0),
            enemyTypes: [.grunt, .scout, .heavy],
            difficulty: 1.5
        ),
        "jupiter": WorldData(
            id: "jupiter",
            name: "Júpiter",
            description: "O gigante gasoso com suas luas perigosas e inimigos voadores.",
            price: 1000,
            unlocked: false,
            backgroundColor: UIColor(red: 0.9, green: 0.7, blue: 0.4, alpha: 1.0),
            starColor: UIColor(red: 1.0, green: 1.0, blue: 0.8, alpha: 1.0),
            enemyTypes: [.scout, .heavy, .bomber],
            difficulty: 2.0
        ),
        "titan": WorldData(
            id: "titan",
            name: "Titã",
            description: "A misteriosa lua de Saturno, repleta de inimigos tecnológicos.",
            price: 2000,
            unlocked: false,
            backgroundColor: UIColor(red: 0.4, green: 0.2, blue: 0.6, alpha: 1.0),
            starColor: UIColor(red: 0.8, green: 0.6, blue: 1.0, alpha: 1.0),
            enemyTypes: [.heavy, .bomber, .elite],
            difficulty: 2.5
        ),
        "vortex": WorldData(
            id: "vortex",
            name: "Vórtice",
            description: "Uma dimensão distorcida onde o espaço-tempo se dobra.",
            price: 3500,
            unlocked: false,
            backgroundColor: UIColor(red: 0.2, green: 0.1, blue: 0.3, alpha: 1.0),
            starColor: UIColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 1.0),
            enemyTypes: [.bomber, .elite, .boss],
            difficulty: 3.0
        ),
        "nemesis": WorldData(
            id: "nemesis",
            name: "Nêmesis",
            description: "O mundo mais perigoso conhecido, habitado pelos inimigos mais letais.",
            price: 5000,
            unlocked: false,
            backgroundColor: UIColor(red: 0.1, green: 0.0, blue: 0.1, alpha: 1.0),
            starColor: UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0),
            enemyTypes: [.elite, .boss],
            difficulty: 4.0
        )
    ]
    
    // MARK: - Ship Definitions
    let ships: [String: ShipData] = [
        "interceptor": ShipData(
            id: "interceptor",
            name: "Interceptor",
            description: "Nave rápida e ágil, perfeita para iniciantes.",
            health: 100,
            speed: 5.0,
            damage: 10,
            fireRate: 0.3,
            specialAbility: "Boost de Velocidade",
            price: 0,
            rarity: .common,
            color: UIColor.cyan
        ),
        "assault": ShipData(
            id: "assault",
            name: "Assault",
            description: "Nave de combate com maior poder de fogo.",
            health: 120,
            speed: 4.0,
            damage: 15,
            fireRate: 0.25,
            specialAbility: "Rajada Tripla",
            price: 1000,
            rarity: .rare,
            color: UIColor.orange
        ),
        "destroyer": ShipData(
            id: "destroyer",
            name: "Destroyer",
            description: "Nave pesada com armamento devastador.",
            health: 150,
            speed: 3.0,
            damage: 25,
            fireRate: 0.4,
            specialAbility: "Míssil Devastador",
            price: 2500,
            rarity: .epic,
            color: UIColor.red
        ),
        "phoenix": ShipData(
            id: "phoenix",
            name: "Phoenix",
            description: "Nave lendária com capacidade de regeneração.",
            health: 200,
            speed: 4.5,
            damage: 20,
            fireRate: 0.2,
            specialAbility: "Regeneração",
            price: 5000,
            rarity: .legendary,
            color: UIColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0)
        )
    ]
    
    // MARK: - Initialization
    private init() {
        loadInitialData()
    }
    
    private func loadInitialData() {
        // Set initial coins if first time
        if UserDefaults.standard.object(forKey: "waveslayers_coins") == nil {
            coins = 100
        }
    }
    
    // MARK: - Game Control
    func startGame() {
        gameState = .playing
        isGameRunning = true
        isPaused = false
        score = 0
        level = 1
        survivalTime = 0
        coinsThisRound = 0
    }
    
    func pauseGame() {
        if gameState == .playing {
            gameState = .paused
            isPaused = true
        }
    }
    
    func resumeGame() {
        if gameState == .paused {
            gameState = .playing
            isPaused = false
        }
    }
    
    func endGame() {
        gameState = .gameOver
        isGameRunning = false
        isPaused = false
        
        // Add coins earned to total
        coins += coinsThisRound
        
        // Update progression
        ProgressionManager.shared.addXP(coinsThisRound / 10)
        ProgressionManager.shared.updateStats(score: score, survival: survivalTime)
        
        // Check achievements
        ProgressionManager.shared.checkAchievements()
        
        // Save game state
        saveGameState()
    }
    
    func returnToMenu() {
        gameState = .menu
        isGameRunning = false
        isPaused = false
    }
    
    // MARK: - World Management
    func getCurrentWorld() -> WorldData {
        return worlds[currentWorldId] ?? worlds["earth"]!
    }
    
    func unlockWorld(_ worldId: String) -> Bool {
        guard let world = worlds[worldId] else { return false }
        
        if coins >= world.price && !unlockedWorlds.contains(worldId) {
            coins -= world.price
            var unlocked = unlockedWorlds
            unlocked.append(worldId)
            unlockedWorlds = unlocked
            return true
        }
        return false
    }
    
    func selectWorld(_ worldId: String) -> Bool {
        if unlockedWorlds.contains(worldId) {
            currentWorldId = worldId
            return true
        }
        return false
    }
    
    // MARK: - Ship Management
    func getCurrentShip() -> ShipData {
        return ships[currentShipId] ?? ships["interceptor"]!
    }
    
    func unlockShip(_ shipId: String) -> Bool {
        guard let ship = ships[shipId] else { return false }
        
        if coins >= ship.price && !unlockedShips.contains(shipId) {
            coins -= ship.price
            var unlocked = unlockedShips
            unlocked.append(shipId)
            unlockedShips = unlocked
            return true
        }
        return false
    }
    
    func selectShip(_ shipId: String) -> Bool {
        if unlockedShips.contains(shipId) {
            currentShipId = shipId
            return true
        }
        return false
    }
    
    // MARK: - Score Management
    func addScore(_ points: Int) {
        score += points
        
        // Add coins (1 coin per 10 points)
        let newCoins = points / 10
        coinsThisRound += newCoins
        
        // Level progression based on score
        let newLevel = (score / 1000) + 1
        if newLevel > level {
            level = newLevel
        }
    }
    
    // MARK: - Data Persistence
    func saveGameState() {
        UserDefaults.standard.synchronize()
    }
    
    func resetProgress() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "waveslayers_coins")
        defaults.removeObject(forKey: "waveslayers_current_world")
        defaults.removeObject(forKey: "waveslayers_current_ship")
        defaults.removeObject(forKey: "waveslayers_unlocked_ships")
        defaults.removeObject(forKey: "waveslayers_unlocked_worlds")
        
        // Reset to initial values
        coins = 100
        currentWorldId = "earth"
        currentShipId = "interceptor"
        unlockedShips = ["interceptor"]
        unlockedWorlds = ["earth"]
        
        // Reset other managers
        ProgressionManager.shared.resetProgress()
        SocialManager.shared.resetData()
        
        defaults.synchronize()
    }
    
    // MARK: - Difficulty Scaling
    func getDifficultyMultiplier() -> Float {
        let world = getCurrentWorld()
        let levelMultiplier = 1.0 + (Float(level - 1) * 0.1)
        return world.difficulty * levelMultiplier
    }
    
    func getEnemySpawnRate() -> TimeInterval {
        let baseRate: TimeInterval = 2.0
        let difficultyMultiplier = getDifficultyMultiplier()
        return baseRate / Double(difficultyMultiplier)
    }
    
    func getEnemySpeed() -> Float {
        let baseSpeed: Float = 2.0
        let difficultyMultiplier = getDifficultyMultiplier()
        return baseSpeed * difficultyMultiplier
    }
    
    func getEnemyHealth() -> Int {
        let baseHealth = 20
        let difficultyMultiplier = getDifficultyMultiplier()
        return Int(Float(baseHealth) * difficultyMultiplier)
    }
}

// MARK: - Extensions
extension GameManager {
    func showNotification(_ message: String) {
        NotificationCenter.default.post(
            name: NSNotification.Name("ShowGameNotification"),
            object: message
        )
    }
    
    func vibrate() {
        // Haptic feedback for iOS
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    func lightVibrate() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    func heavyVibrate() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
    }
}

import UIKit
