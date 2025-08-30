//
//  ProgressionManager.swift
//  WaveSlayers
//
//  Created by Developer on 30/08/2025.
//  Copyright © 2025 WaveSlayers Dev. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Achievement Data
struct Achievement {
    let id: String
    let name: String
    let description: String
    let requirement: Int
    let reward: AchievementReward
    let category: AchievementCategory
    var isUnlocked: Bool = false
    var progress: Int = 0
}

enum AchievementCategory: String, CaseIterable {
    case combat = "Combate"
    case survival = "Sobrevivência"
    case progression = "Progressão"
    case exploration = "Exploração"
    case special = "Especial"
}

struct AchievementReward {
    let coins: Int
    let gems: Int
    let xp: Int
    let title: String?
    let shipUnlock: String?
}

// MARK: - Skill Data
struct Skill {
    let id: String
    let name: String
    let description: String
    let maxLevel: Int
    let cost: Int
    let category: SkillCategory
    let prerequisite: String?
    var currentLevel: Int = 0
    var isUnlocked: Bool = false
}

enum SkillCategory: String, CaseIterable {
    case combat = "Combate"
    case defense = "Defesa"
    case mobility = "Mobilidade"
    case utility = "Utilidade"
}

// MARK: - Daily Challenge
struct DailyChallenge {
    let id: String
    let name: String
    let description: String
    let requirement: Int
    let reward: AchievementReward
    var progress: Int = 0
    var isCompleted: Bool = false
    var date: String
}

// MARK: - Battle Pass
struct BattlePassTier {
    let level: Int
    let xpRequired: Int
    let freeReward: AchievementReward?
    let premiumReward: AchievementReward?
    var isUnlocked: Bool = false
}

// MARK: - Player Stats
struct PlayerStats {
    var totalScore: Int = 0
    var bestScore: Int = 0
    var totalPlayTime: TimeInterval = 0
    var enemiesKilled: Int = 0
    var gamesPlayed: Int = 0
    var totalCoinsEarned: Int = 0
    var worldsUnlocked: Int = 1
    var achievementsUnlocked: Int = 0
}

class ProgressionManager {
    static let shared = ProgressionManager()
    
    // MARK: - Player Progression
    var playerLevel: Int {
        get { UserDefaults.standard.integer(forKey: "waveslayers_player_level") }
        set { UserDefaults.standard.set(newValue, forKey: "waveslayers_player_level") }
    }
    
    var playerXP: Int {
        get { UserDefaults.standard.integer(forKey: "waveslayers_player_xp") }
        set { UserDefaults.standard.set(newValue, forKey: "waveslayers_player_xp") }
    }
    
    var skillPoints: Int {
        get { UserDefaults.standard.integer(forKey: "waveslayers_skill_points") }
        set { UserDefaults.standard.set(newValue, forKey: "waveslayers_skill_points") }
    }
    
    var gems: Int {
        get { UserDefaults.standard.integer(forKey: "waveslayers_gems") }
        set { UserDefaults.standard.set(newValue, forKey: "waveslayers_gems") }
    }
    
    var darkMatter: Int {
        get { UserDefaults.standard.integer(forKey: "waveslayers_dark_matter") }
        set { UserDefaults.standard.set(newValue, forKey: "waveslayers_dark_matter") }
    }
    
    // MARK: - Battle Pass
    var battlePassLevel: Int {
        get { UserDefaults.standard.integer(forKey: "waveslayers_battlepass_level") }
        set { UserDefaults.standard.set(newValue, forKey: "waveslayers_battlepass_level") }
    }
    
    var battlePassXP: Int {
        get { UserDefaults.standard.integer(forKey: "waveslayers_battlepass_xp") }
        set { UserDefaults.standard.set(newValue, forKey: "waveslayers_battlepass_xp") }
    }
    
    var battlePassPremium: Bool {
        get { UserDefaults.standard.bool(forKey: "waveslayers_battlepass_premium") }
        set { UserDefaults.standard.set(newValue, forKey: "waveslayers_battlepass_premium") }
    }
    
    var battlePassSeason: String {
        get { UserDefaults.standard.string(forKey: "waveslayers_battlepass_season") ?? "1" }
        set { UserDefaults.standard.set(newValue, forKey: "waveslayers_battlepass_season") }
    }
    
    // MARK: - Data Storage
    private var achievements: [String: Achievement] = [:]
    private var skills: [String: Skill] = [:]
    private var dailyChallenges: [String: DailyChallenge] = [:]
    private var battlePassTiers: [BattlePassTier] = []
    private var playerStats = PlayerStats()
    
    private var lastDailyReset: String {
        get { UserDefaults.standard.string(forKey: "waveslayers_last_daily_reset") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "waveslayers_last_daily_reset") }
    }
    
    // MARK: - Initialization
    private init() {
        loadInitialData()
        setupAchievements()
        setupSkills()
        setupBattlePass()
        checkDailyReset()
    }
    
    private func loadInitialData() {
        // Set initial values if first time
        if UserDefaults.standard.object(forKey: "waveslayers_player_level") == nil {
            playerLevel = 1
            playerXP = 0
            skillPoints = 0
            gems = 0
            darkMatter = 0
        }
        
        // Load saved data
        loadAchievements()
        loadSkills()
        loadDailyChallenges()
        loadPlayerStats()
    }
    
    // MARK: - XP and Leveling
    func addXP(_ amount: Int) {
        playerXP += amount
        battlePassXP += amount
        
        checkLevelUp()
        checkBattlePassLevelUp()
        
        // Show XP notification
        GameManager.shared.showNotification("+\(amount) XP")
    }
    
    private func checkLevelUp() {
        let requiredXP = getXPRequiredForLevel(playerLevel + 1)
        
        if playerXP >= requiredXP {
            playerLevel += 1
            skillPoints += 2 // Gain 2 skill points per level
            gems += 5 // Bonus gems for leveling up
            
            // Show level up notification
            GameManager.shared.showNotification("🎉 Level Up! Nível \(playerLevel)")
            GameManager.shared.heavyVibrate()
            
            // Check for more level ups
            checkLevelUp()
        }
    }
    
    func getXPRequiredForLevel(_ level: Int) -> Int {
        return 100 * level + (level - 1) * 50 // Progressive XP requirement
    }
    
    func getXPProgress() -> Float {
        let currentLevelXP = getXPRequiredForLevel(playerLevel)
        let nextLevelXP = getXPRequiredForLevel(playerLevel + 1)
        let progressXP = playerXP - currentLevelXP
        let levelRangeXP = nextLevelXP - currentLevelXP
        
        return Float(progressXP) / Float(levelRangeXP)
    }
    
    // MARK: - Achievements System
    private func setupAchievements() {
        achievements = [
            "first_kill": Achievement(
                id: "first_kill",
                name: "Primeira Morte",
                description: "Destrua seu primeiro inimigo",
                requirement: 1,
                reward: AchievementReward(coins: 50, gems: 5, xp: 100, title: nil, shipUnlock: nil),
                category: .combat
            ),
            "kill_100": Achievement(
                id: "kill_100",
                name: "Dizimador",
                description: "Destrua 100 inimigos",
                requirement: 100,
                reward: AchievementReward(coins: 500, gems: 25, xp: 1000, title: "Dizimador", shipUnlock: nil),
                category: .combat
            ),
            "kill_1000": Achievement(
                id: "kill_1000",
                name: "Exterminador",
                description: "Destrua 1000 inimigos",
                requirement: 1000,
                reward: AchievementReward(coins: 2000, gems: 100, xp: 5000, title: "Exterminador", shipUnlock: "assault"),
                category: .combat
            ),
            "survive_60": Achievement(
                id: "survive_60",
                name: "Sobrevivente",
                description: "Sobreviva por 60 segundos",
                requirement: 60,
                reward: AchievementReward(coins: 300, gems: 15, xp: 500, title: nil, shipUnlock: nil),
                category: .survival
            ),
            "survive_300": Achievement(
                id: "survive_300",
                name: "Resistente",
                description: "Sobreviva por 5 minutos",
                requirement: 300,
                reward: AchievementReward(coins: 1000, gems: 50, xp: 2000, title: "Resistente", shipUnlock: nil),
                category: .survival
            ),
            "score_10000": Achievement(
                id: "score_10000",
                name: "Pontuador",
                description: "Alcance 10.000 pontos",
                requirement: 10000,
                reward: AchievementReward(coins: 800, gems: 30, xp: 1500, title: nil, shipUnlock: nil),
                category: .progression
            ),
            "score_100000": Achievement(
                id: "score_100000",
                name: "Mestre da Pontuação",
                description: "Alcance 100.000 pontos",
                requirement: 100000,
                reward: AchievementReward(coins: 3000, gems: 150, xp: 8000, title: "Mestre da Pontuação", shipUnlock: "destroyer"),
                category: .progression
            ),
            "level_10": Achievement(
                id: "level_10",
                name: "Experiente",
                description: "Alcance o nível 10",
                requirement: 10,
                reward: AchievementReward(coins: 1500, gems: 75, xp: 0, title: "Experiente", shipUnlock: nil),
                category: .progression
            ),
            "unlock_mars": Achievement(
                id: "unlock_mars",
                name: "Explorador Marciano",
                description: "Desbloqueie Marte",
                requirement: 1,
                reward: AchievementReward(coins: 1000, gems: 50, xp: 2000, title: nil, shipUnlock: nil),
                category: .exploration
            ),
            "unlock_all_worlds": Achievement(
                id: "unlock_all_worlds",
                name: "Conquistador Galáctico",
                description: "Desbloqueie todos os mundos",
                requirement: 6,
                reward: AchievementReward(coins: 10000, gems: 500, xp: 20000, title: "Conquistador Galáctico", shipUnlock: "phoenix"),
                category: .exploration
            ),
            "perfect_game": Achievement(
                id: "perfect_game",
                name: "Jogo Perfeito",
                description: "Complete uma partida sem levar dano",
                requirement: 1,
                reward: AchievementReward(coins: 2000, gems: 100, xp: 5000, title: "Intocável", shipUnlock: nil),
                category: .special
            )
        ]
    }
    
    func checkAchievements() {
        for (id, achievement) in achievements {
            if !achievement.isUnlocked {
                var shouldUnlock = false
                var currentProgress = 0
                
                switch id {
                case "first_kill", "kill_100", "kill_1000":
                    currentProgress = playerStats.enemiesKilled
                    shouldUnlock = currentProgress >= achievement.requirement
                    
                case "survive_60", "survive_300":
                    currentProgress = Int(playerStats.totalPlayTime)
                    shouldUnlock = currentProgress >= achievement.requirement
                    
                case "score_10000", "score_100000":
                    currentProgress = playerStats.bestScore
                    shouldUnlock = currentProgress >= achievement.requirement
                    
                case "level_10":
                    currentProgress = playerLevel
                    shouldUnlock = currentProgress >= achievement.requirement
                    
                case "unlock_mars":
                    currentProgress = GameManager.shared.unlockedWorlds.contains("mars") ? 1 : 0
                    shouldUnlock = currentProgress >= achievement.requirement
                    
                case "unlock_all_worlds":
                    currentProgress = GameManager.shared.unlockedWorlds.count
                    shouldUnlock = currentProgress >= achievement.requirement
                    
                default:
                    break
                }
                
                // Update progress
                achievements[id]?.progress = currentProgress
                
                if shouldUnlock {
                    unlockAchievement(id)
                }
            }
        }
    }
    
    private func unlockAchievement(_ achievementId: String) {
        guard var achievement = achievements[achievementId], !achievement.isUnlocked else { return }
        
        achievement.isUnlocked = true
        achievements[achievementId] = achievement
        
        // Give rewards
        GameManager.shared.coins += achievement.reward.coins
        gems += achievement.reward.gems
        if achievement.reward.xp > 0 {
            addXP(achievement.reward.xp)
        }
        
        // Unlock ship if specified
        if let shipId = achievement.reward.shipUnlock {
            var unlockedShips = GameManager.shared.unlockedShips
            if !unlockedShips.contains(shipId) {
                unlockedShips.append(shipId)
                GameManager.shared.unlockedShips = unlockedShips
            }
        }
        
        // Show achievement notification
        GameManager.shared.showNotification("🏆 \(achievement.name) Desbloqueado!")
        GameManager.shared.heavyVibrate()
        
        playerStats.achievementsUnlocked += 1
        saveAchievements()
    }
    
    // MARK: - Skills System
    private func setupSkills() {
        skills = [
            "damage_boost": Skill(
                id: "damage_boost",
                name: "Poder de Fogo",
                description: "Aumenta o dano dos projéteis em 10%",
                maxLevel: 5,
                cost: 1,
                category: .combat,
                prerequisite: nil
            ),
            "fire_rate": Skill(
                id: "fire_rate",
                name: "Tiro Rápido",
                description: "Aumenta a velocidade de tiro em 15%",
                maxLevel: 3,
                cost: 2,
                category: .combat,
                prerequisite: "damage_boost"
            ),
            "health_boost": Skill(
                id: "health_boost",
                name: "Casco Reforçado",
                description: "Aumenta a vida máxima em 20 pontos",
                maxLevel: 5,
                cost: 1,
                category: .defense,
                prerequisite: nil
            ),
            "shield_regen": Skill(
                id: "shield_regen",
                name: "Regeneração",
                description: "Regenera 1 ponto de vida a cada 5 segundos",
                maxLevel: 3,
                cost: 3,
                category: .defense,
                prerequisite: "health_boost"
            ),
            "speed_boost": Skill(
                id: "speed_boost",
                name: "Motor Turbinado",
                description: "Aumenta a velocidade de movimento em 20%",
                maxLevel: 3,
                cost: 1,
                category: .mobility,
                prerequisite: nil
            ),
            "dash": Skill(
                id: "dash",
                name: "Dash",
                description: "Permite uma investida rápida",
                maxLevel: 1,
                cost: 4,
                category: .mobility,
                prerequisite: "speed_boost"
            ),
            "coin_bonus": Skill(
                id: "coin_bonus",
                name: "Coletor",
                description: "Aumenta ganho de moedas em 25%",
                maxLevel: 3,
                cost: 2,
                category: .utility,
                prerequisite: nil
            ),
            "xp_bonus": Skill(
                id: "xp_bonus",
                name: "Aprendiz Rápido",
                description: "Aumenta ganho de XP em 30%",
                maxLevel: 3,
                cost: 3,
                category: .utility,
                prerequisite: "coin_bonus"
            )
        ]
    }
    
    func unlockSkill(_ skillId: String) -> Bool {
        guard var skill = skills[skillId] else { return false }
        guard skillPoints >= skill.cost else { return false }
        guard skill.currentLevel < skill.maxLevel else { return false }
        
        // Check prerequisite
        if let prerequisiteId = skill.prerequisite,
           let prerequisite = skills[prerequisiteId],
           prerequisite.currentLevel == 0 {
            return false
        }
        
        // Unlock skill
        skillPoints -= skill.cost
        skill.currentLevel += 1
        if skill.currentLevel == 1 {
            skill.isUnlocked = true
        }
        skills[skillId] = skill
        
        saveSkills()
        return true
    }
    
    func getSkillBonus(_ skillId: String) -> Float {
        guard let skill = skills[skillId] else { return 0 }
        
        switch skillId {
        case "damage_boost":
            return Float(skill.currentLevel) * 0.1
        case "fire_rate":
            return Float(skill.currentLevel) * 0.15
        case "speed_boost":
            return Float(skill.currentLevel) * 0.2
        case "coin_bonus":
            return Float(skill.currentLevel) * 0.25
        case "xp_bonus":
            return Float(skill.currentLevel) * 0.3
        default:
            return Float(skill.currentLevel)
        }
    }
    
    // MARK: - Daily Challenges
    private func checkDailyReset() {
        let today = DateFormatter().string(from: Date())
        
        if lastDailyReset != today {
            generateDailyChallenges()
            lastDailyReset = today
        }
    }
    
    private func generateDailyChallenges() {
        let today = DateFormatter().string(from: Date())
        
        dailyChallenges = [
            "daily_kills": DailyChallenge(
                id: "daily_kills",
                name: "Exterminação Diária",
                description: "Destrua 50 inimigos hoje",
                requirement: 50,
                reward: AchievementReward(coins: 200, gems: 10, xp: 500, title: nil, shipUnlock: nil),
                date: today
            ),
            "daily_score": DailyChallenge(
                id: "daily_score",
                name: "Pontuação Diária",
                description: "Alcance 5.000 pontos em uma partida",
                requirement: 5000,
                reward: AchievementReward(coins: 300, gems: 15, xp: 800, title: nil, shipUnlock: nil),
                date: today
            ),
            "daily_survival": DailyChallenge(
                id: "daily_survival",
                name: "Sobrevivência Diária",
                description: "Sobreviva por 2 minutos",
                requirement: 120,
                reward: AchievementReward(coins: 250, gems: 12, xp: 600, title: nil, shipUnlock: nil),
                date: today
            )
        ]
        
        saveDailyChallenges()
    }
    
    func updateDailyChallenge(_ challengeId: String, progress: Int) {
        guard var challenge = dailyChallenges[challengeId], !challenge.isCompleted else { return }
        
        challenge.progress = max(challenge.progress, progress)
        
        if challenge.progress >= challenge.requirement && !challenge.isCompleted {
            challenge.isCompleted = true
            
            // Give rewards
            GameManager.shared.coins += challenge.reward.coins
            gems += challenge.reward.gems
            addXP(challenge.reward.xp)
            
            GameManager.shared.showNotification("✅ Desafio Diário Completo!")
        }
        
        dailyChallenges[challengeId] = challenge
        saveDailyChallenges()
    }
    
    // MARK: - Battle Pass
    private func setupBattlePass() {
        battlePassTiers = []
        
        for level in 1...50 {
            let xpRequired = level * 1000
            
            let freeReward: AchievementReward?
            let premiumReward: AchievementReward?
            
            if level % 5 == 0 {
                // Special rewards every 5 levels
                freeReward = AchievementReward(coins: 500, gems: 20, xp: 0, title: nil, shipUnlock: nil)
                premiumReward = AchievementReward(coins: 1000, gems: 50, xp: 0, title: nil, shipUnlock: level == 25 ? "assault" : nil)
            } else {
                freeReward = AchievementReward(coins: 100, gems: 5, xp: 0, title: nil, shipUnlock: nil)
                premiumReward = AchievementReward(coins: 200, gems: 10, xp: 0, title: nil, shipUnlock: nil)
            }
            
            battlePassTiers.append(BattlePassTier(
                level: level,
                xpRequired: xpRequired,
                freeReward: freeReward,
                premiumReward: premiumReward
            ))
        }
    }
    
    private func checkBattlePassLevelUp() {
        let currentTier = battlePassLevel
        
        if currentTier < battlePassTiers.count {
            let requiredXP = battlePassTiers[currentTier].xpRequired
            
            if battlePassXP >= requiredXP {
                battlePassLevel += 1
                
                // Give free reward
                if let freeReward = battlePassTiers[currentTier].freeReward {
                    GameManager.shared.coins += freeReward.coins
                    gems += freeReward.gems
                }
                
                // Give premium reward if applicable
                if battlePassPremium, let premiumReward = battlePassTiers[currentTier].premiumReward {
                    GameManager.shared.coins += premiumReward.coins
                    gems += premiumReward.gems
                    
                    if let shipId = premiumReward.shipUnlock {
                        var unlockedShips = GameManager.shared.unlockedShips
                        if !unlockedShips.contains(shipId) {
                            unlockedShips.append(shipId)
                            GameManager.shared.unlockedShips = unlockedShips
                        }
                    }
                }
                
                GameManager.shared.showNotification("🎖️ Battle Pass Nível \(battlePassLevel)!")
                
                // Check for more level ups
                checkBattlePassLevelUp()
            }
        }
    }
    
    func purchaseBattlePassPremium() -> Bool {
        let cost = 500 // Cost in gems
        
        if gems >= cost && !battlePassPremium {
            gems -= cost
            battlePassPremium = true
            
            // Give all previous premium rewards
            for i in 0..<battlePassLevel {
                if let premiumReward = battlePassTiers[i].premiumReward {
                    GameManager.shared.coins += premiumReward.coins
                    gems += premiumReward.gems
                    
                    if let shipId = premiumReward.shipUnlock {
                        var unlockedShips = GameManager.shared.unlockedShips
                        if !unlockedShips.contains(shipId) {
                            unlockedShips.append(shipId)
                            GameManager.shared.unlockedShips = unlockedShips
                        }
                    }
                }
            }
            
            saveProgress()
            return true
        }
        
        return false
    }
    
    // MARK: - Stats Tracking
    func updateStats(score: Int, survival: TimeInterval) {
        playerStats.totalScore += score
        playerStats.bestScore = max(playerStats.bestScore, score)
        playerStats.totalPlayTime += survival
        playerStats.gamesPlayed += 1
        
        // Update daily challenges
        updateDailyChallenge("daily_score", progress: score)
        updateDailyChallenge("daily_survival", progress: Int(survival))
        
        savePlayerStats()
    }
    
    func enemyKilled(type: EnemyType) {
        playerStats.enemiesKilled += 1
        updateDailyChallenge("daily_kills", progress: playerStats.enemiesKilled)
        savePlayerStats()
    }
    
    func coinsEarned(_ amount: Int) {
        playerStats.totalCoinsEarned += amount
        savePlayerStats()
    }
    
    // MARK: - Data Persistence
    func saveProgress() {
        saveAchievements()
        saveSkills()
        saveDailyChallenges()
        savePlayerStats()
        UserDefaults.standard.synchronize()
    }
    
    private func saveAchievements() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(achievements) {
            UserDefaults.standard.set(data, forKey: "waveslayers_achievements")
        }
    }
    
    private func loadAchievements() {
        let decoder = JSONDecoder()
        if let data = UserDefaults.standard.data(forKey: "waveslayers_achievements"),
           let savedAchievements = try? decoder.decode([String: Achievement].self, from: data) {
            // Merge with default achievements to handle new additions
            for (id, achievement) in achievements {
                if let saved = savedAchievements[id] {
                    achievements[id] = saved
                }
            }
        }
    }
    
    private func saveSkills() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(skills) {
            UserDefaults.standard.set(data, forKey: "waveslayers_skills")
        }
    }
    
    private func loadSkills() {
        let decoder = JSONDecoder()
        if let data = UserDefaults.standard.data(forKey: "waveslayers_skills"),
           let savedSkills = try? decoder.decode([String: Skill].self, from: data) {
            // Merge with default skills
            for (id, skill) in skills {
                if let saved = savedSkills[id] {
                    skills[id] = saved
                }
            }
        }
    }
    
    private func saveDailyChallenges() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(dailyChallenges) {
            UserDefaults.standard.set(data, forKey: "waveslayers_daily_challenges")
        }
    }
    
    private func loadDailyChallenges() {
        let decoder = JSONDecoder()
        if let data = UserDefaults.standard.data(forKey: "waveslayers_daily_challenges"),
           let saved = try? decoder.decode([String: DailyChallenge].self, from: data) {
            dailyChallenges = saved
        }
    }
    
    private func savePlayerStats() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(playerStats) {
            UserDefaults.standard.set(data, forKey: "waveslayers_player_stats")
        }
    }
    
    private func loadPlayerStats() {
        let decoder = JSONDecoder()
        if let data = UserDefaults.standard.data(forKey: "waveslayers_player_stats"),
           let saved = try? decoder.decode(PlayerStats.self, from: data) {
            playerStats = saved
        }
    }
    
    func resetProgress() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "waveslayers_player_level")
        defaults.removeObject(forKey: "waveslayers_player_xp")
        defaults.removeObject(forKey: "waveslayers_skill_points")
        defaults.removeObject(forKey: "waveslayers_gems")
        defaults.removeObject(forKey: "waveslayers_dark_matter")
        defaults.removeObject(forKey: "waveslayers_battlepass_level")
        defaults.removeObject(forKey: "waveslayers_battlepass_xp")
        defaults.removeObject(forKey: "waveslayers_battlepass_premium")
        defaults.removeObject(forKey: "waveslayers_achievements")
        defaults.removeObject(forKey: "waveslayers_skills")
        defaults.removeObject(forKey: "waveslayers_daily_challenges")
        defaults.removeObject(forKey: "waveslayers_player_stats")
        defaults.removeObject(forKey: "waveslayers_last_daily_reset")
        
        // Reset to initial values
        playerLevel = 1
        playerXP = 0
        skillPoints = 0
        gems = 0
        darkMatter = 0
        battlePassLevel = 0
        battlePassXP = 0
        battlePassPremium = false
        
        playerStats = PlayerStats()
        setupAchievements()
        setupSkills()
        generateDailyChallenges()
        
        defaults.synchronize()
    }
    
    // MARK: - Getters
    func getAllAchievements() -> [Achievement] {
        return Array(achievements.values).sorted { $0.category.rawValue < $1.category.rawValue }
    }
    
    func getAllSkills() -> [Skill] {
        return Array(skills.values).sorted { $0.category.rawValue < $1.category.rawValue }
    }
    
    func getAllDailyChallenges() -> [DailyChallenge] {
        return Array(dailyChallenges.values)
    }
    
    func getBattlePassTiers() -> [BattlePassTier] {
        return battlePassTiers
    }
    
    func getPlayerStats() -> PlayerStats {
        return playerStats
    }
}

// MARK: - Extensions for Codable
extension Achievement: Codable {}
extension AchievementReward: Codable {}
extension Skill: Codable {}
extension DailyChallenge: Codable {}
extension PlayerStats: Codable {}
