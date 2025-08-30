//
//  SocialManager.swift
//  WaveSlayers
//
//  Created by Developer on 30/08/2025.
//  Copyright © 2025 WaveSlayers Dev. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Leaderboard Data
struct LeaderboardEntry {
    let id: String
    let playerName: String
    let score: Int
    let level: Int
    let world: String
    let rank: Int
    let isCurrentPlayer: Bool
}

// MARK: - Clan Data
struct ClanData {
    let id: String
    let name: String
    let description: String
    let level: Int
    let memberCount: Int
    let maxMembers: Int
    let trophies: Int
    let rank: Int
    let isPublic: Bool
    let inviteCode: String
}

struct ClanMember {
    let id: String
    let name: String
    let level: Int
    let contribution: Int
    let rank: ClanMemberRank
    let lastActive: Date
}

enum ClanMemberRank: String, CaseIterable {
    case member = "Membro"
    case veteran = "Veterano"
    case elder = "Ancião"
    case viceLeader = "Vice-Líder"
    case leader = "Líder"
}

// MARK: - Community Events
struct CommunityEvent {
    let id: String
    let name: String
    let description: String
    let type: EventType
    let startDate: Date
    let endDate: Date
    let currentProgress: Int
    let targetProgress: Int
    let reward: EventReward
    let isParticipating: Bool
    let playerContribution: Int
}

enum EventType: String, CaseIterable {
    case globalChallenge = "Desafio Global"
    case invasion = "Invasão Alienígena"
    case treasureHunt = "Caça ao Tesouro"
    case tournament = "Torneio"
}

struct EventReward {
    let coins: Int
    let gems: Int
    let xp: Int
    let title: String?
    let shipUnlock: String?
    let skinUnlock: String?
}

// MARK: - Multiplayer Room
struct MultiplayerRoom {
    let id: String
    let name: String
    let hostName: String
    let currentPlayers: Int
    let maxPlayers: Int
    let gameMode: GameMode
    let difficulty: String
    let isPrivate: Bool
    let inviteCode: String?
    let createdAt: Date
}

enum GameMode: String, CaseIterable {
    case cooperative = "Cooperativo"
    case versus = "Versus"
    case survival = "Sobrevivência"
    case race = "Corrida"
}

// MARK: - Social Manager
class SocialManager {
    static let shared = SocialManager()
    
    // MARK: - Player Data
    var playerName: String {
        get { UserDefaults.standard.string(forKey: "waveslayers_player_name") ?? generateRandomPlayerName() }
        set { UserDefaults.standard.set(newValue, forKey: "waveslayers_player_name") }
    }
    
    var playerClan: ClanData? {
        get {
            if let data = UserDefaults.standard.data(forKey: "waveslayers_player_clan"),
               let clan = try? JSONDecoder().decode(ClanData.self, from: data) {
                return clan
            }
            return nil
        }
        set {
            if let clan = newValue,
               let data = try? JSONEncoder().encode(clan) {
                UserDefaults.standard.set(data, forKey: "waveslayers_player_clan")
            } else {
                UserDefaults.standard.removeObject(forKey: "waveslayers_player_clan")
            }
        }
    }
    
    // MARK: - Mock Data
    private var mockLeaderboards: [String: [LeaderboardEntry]] = [:]
    private var mockClans: [ClanData] = []
    private var mockEvents: [CommunityEvent] = []
    private var mockRooms: [MultiplayerRoom] = []
    
    // MARK: - Real Data Storage
    private var realLeaderboard: [LeaderboardEntry] = []
    
    // MARK: - Initialization
    private init() {
        setupMockData()
        loadSavedData()
    }
    
    private func setupMockData() {
        setupMockLeaderboards()
        setupMockClans()
        setupMockEvents()
        setupMockRooms()
    }
    
    private func setupMockLeaderboards() {
        mockLeaderboards = [
            "overall": [
                LeaderboardEntry(id: "1", playerName: "CosmicHunter", score: 2580000, level: 47, world: "Nêmesis", rank: 1, isCurrentPlayer: false),
                LeaderboardEntry(id: "2", playerName: "StarDestroyer", score: 2340000, level: 43, world: "Vórtice", rank: 2, isCurrentPlayer: false),
                LeaderboardEntry(id: "3", playerName: "GalaxyMaster", score: 2100000, level: 41, world: "Nêmesis", rank: 3, isCurrentPlayer: false),
                LeaderboardEntry(id: "4", playerName: "NebulaWarrior", score: 1950000, level: 38, world: "Titã", rank: 4, isCurrentPlayer: false),
                LeaderboardEntry(id: "5", playerName: "VoidSlayer", score: 1800000, level: 36, world: "Titã", rank: 5, isCurrentPlayer: false),
                LeaderboardEntry(id: "6", playerName: "PhotonBlaster", score: 1650000, level: 34, world: "Júpiter", rank: 6, isCurrentPlayer: false),
                LeaderboardEntry(id: "7", playerName: "SolarFlare", score: 1500000, level: 32, world: "Júpiter", rank: 7, isCurrentPlayer: false),
                LeaderboardEntry(id: "8", playerName: "DarkMatter", score: 1350000, level: 30, world: "Marte", rank: 8, isCurrentPlayer: false),
                LeaderboardEntry(id: "9", playerName: "LunarEclipse", score: 1200000, level: 28, world: "Marte", rank: 9, isCurrentPlayer: false),
                LeaderboardEntry(id: "10", playerName: "MeteorStorm", score: 1050000, level: 26, world: "Terra", rank: 10, isCurrentPlayer: false)
            ],
            "weekly": [
                LeaderboardEntry(id: "11", playerName: "WeeklyChamp", score: 850000, level: 35, world: "Vórtice", rank: 1, isCurrentPlayer: false),
                LeaderboardEntry(id: "12", playerName: "SpeedRunner", score: 780000, level: 32, world: "Titã", rank: 2, isCurrentPlayer: false),
                LeaderboardEntry(id: "13", playerName: "FastPilot", score: 720000, level: 30, world: "Júpiter", rank: 3, isCurrentPlayer: false)
            ],
            "monthly": [
                LeaderboardEntry(id: "14", playerName: "MonthlyKing", score: 3200000, level: 52, world: "Nêmesis", rank: 1, isCurrentPlayer: false),
                LeaderboardEntry(id: "15", playerName: "ConsistentPlayer", score: 2900000, level: 48, world: "Vórtice", rank: 2, isCurrentPlayer: false),
                LeaderboardEntry(id: "16", playerName: "RegularGamer", score: 2600000, level: 44, world: "Titã", rank: 3, isCurrentPlayer: false)
            ]
        ]
    }
    
    private func setupMockClans() {
        mockClans = [
            ClanData(id: "1", name: "Guardiões da Galáxia", description: "Os melhores pilotos do universo", level: 15, memberCount: 42, maxMembers: 50, trophies: 125000, rank: 23, isPublic: true, inviteCode: "GUARD123"),
            ClanData(id: "2", name: "Estrelas Negras", description: "Somos as sombras do espaço", level: 18, memberCount: 38, maxMembers: 50, trophies: 145000, rank: 15, isPublic: true, inviteCode: "DARK456"),
            ClanData(id: "3", name: "Caçadores de Cometas", description: "Perseguimos a velocidade", level: 12, memberCount: 25, maxMembers: 30, trophies: 85000, rank: 67, isPublic: true, inviteCode: "COMET789"),
            ClanData(id: "4", name: "Império Galáctico", description: "Dominaremos todas as galáxias", level: 20, memberCount: 50, maxMembers: 50, trophies: 200000, rank: 5, isPublic: false, inviteCode: "EMPIRE001"),
            ClanData(id: "5", name: "Cavaleiros do Vazio", description: "Honra e glória no espaço", level: 16, memberCount: 35, maxMembers: 40, trophies: 115000, rank: 35, isPublic: true, inviteCode: "VOID222")
        ]
    }
    
    private func setupMockEvents() {
        let now = Date()
        let dayInSeconds: TimeInterval = 24 * 60 * 60
        
        mockEvents = [
            CommunityEvent(
                id: "invasion_2025",
                name: "Grande Invasão Alienígena",
                description: "Alienígenas estão invadindo todas as galáxias! Junte-se à defesa!",
                type: .invasion,
                startDate: now.addingTimeInterval(-dayInSeconds * 2),
                endDate: now.addingTimeInterval(dayInSeconds * 5),
                currentProgress: 750000,
                targetProgress: 1000000,
                reward: EventReward(coins: 5000, gems: 200, xp: 10000, title: "Defensor da Galáxia", shipUnlock: "elite_fighter", skinUnlock: nil),
                isParticipating: false,
                playerContribution: 0
            ),
            CommunityEvent(
                id: "treasure_hunt_2025",
                name: "Caça ao Tesouro Espacial",
                description: "Encontre tesouros escondidos em asteroides!",
                type: .treasureHunt,
                startDate: now.addingTimeInterval(-dayInSeconds),
                endDate: now.addingTimeInterval(dayInSeconds * 3),
                currentProgress: 320000,
                targetProgress: 500000,
                reward: EventReward(coins: 3000, gems: 150, xp: 7500, title: "Caçador de Tesouros", shipUnlock: nil, skinUnlock: "golden_skin"),
                isParticipating: false,
                playerContribution: 0
            ),
            CommunityEvent(
                id: "tournament_2025",
                name: "Torneio dos Campeões",
                description: "Prove que você é o melhor piloto!",
                type: .tournament,
                startDate: now.addingTimeInterval(dayInSeconds),
                endDate: now.addingTimeInterval(dayInSeconds * 7),
                currentProgress: 0,
                targetProgress: 100,
                reward: EventReward(coins: 10000, gems: 500, xp: 20000, title: "Campeão Galáctico", shipUnlock: "champion_ship", skinUnlock: "champion_skin"),
                isParticipating: false,
                playerContribution: 0
            )
        ]
    }
    
    private func setupMockRooms() {
        let now = Date()
        
        mockRooms = [
            MultiplayerRoom(id: "room1", name: "Sobrevivência Extrema", hostName: "SpaceCommander", currentPlayers: 3, maxPlayers: 4, gameMode: .survival, difficulty: "Difícil", isPrivate: false, inviteCode: nil, createdAt: now.addingTimeInterval(-300)),
            MultiplayerRoom(id: "room2", name: "Corrida nas Estrelas", hostName: "StarRacer", currentPlayers: 2, maxPlayers: 6, gameMode: .race, difficulty: "Médio", isPrivate: false, inviteCode: nil, createdAt: now.addingTimeInterval(-180)),
            MultiplayerRoom(id: "room3", name: "Cooperação Épica", hostName: "TeamPlayer", currentPlayers: 2, maxPlayers: 4, gameMode: .cooperative, difficulty: "Normal", isPrivate: false, inviteCode: nil, createdAt: now.addingTimeInterval(-120)),
            MultiplayerRoom(id: "room4", name: "Duelo de Titãs", hostName: "BattleMaster", currentPlayers: 2, maxPlayers: 2, gameMode: .versus, difficulty: "Insano", isPrivate: true, inviteCode: "DUEL123", createdAt: now.addingTimeInterval(-60))
        ]
    }
    
    // MARK: - Leaderboard Management
    func getLeaderboard(category: String) -> [LeaderboardEntry] {
        var leaderboard = mockLeaderboards[category] ?? []
        
        // Add current player if they have a score
        let currentPlayerStats = ProgressionManager.shared.getPlayerStats()
        if currentPlayerStats.bestScore > 0 {
            let playerEntry = LeaderboardEntry(
                id: "current_player",
                playerName: playerName,
                score: currentPlayerStats.bestScore,
                level: ProgressionManager.shared.playerLevel,
                world: GameManager.shared.getCurrentWorld().name,
                rank: calculatePlayerRank(score: currentPlayerStats.bestScore, in: leaderboard),
                isCurrentPlayer: true
            )
            
            leaderboard = insertPlayerInLeaderboard(playerEntry, in: leaderboard)
        }
        
        return leaderboard
    }
    
    private func calculatePlayerRank(score: Int, in leaderboard: [LeaderboardEntry]) -> Int {
        let betterScores = leaderboard.filter { $0.score > score }.count
        return betterScores + 1
    }
    
    private func insertPlayerInLeaderboard(_ player: LeaderboardEntry, in leaderboard: [LeaderboardEntry]) -> [LeaderboardEntry] {
        var newLeaderboard = leaderboard
        
        // Remove any existing player entry
        newLeaderboard.removeAll { $0.isCurrentPlayer }
        
        // Add new player entry
        newLeaderboard.append(player)
        
        // Sort by score and update ranks
        newLeaderboard.sort { $0.score > $1.score }
        
        for i in 0..<newLeaderboard.count {
            newLeaderboard[i] = LeaderboardEntry(
                id: newLeaderboard[i].id,
                playerName: newLeaderboard[i].playerName,
                score: newLeaderboard[i].score,
                level: newLeaderboard[i].level,
                world: newLeaderboard[i].world,
                rank: i + 1,
                isCurrentPlayer: newLeaderboard[i].isCurrentPlayer
            )
        }
        
        return newLeaderboard
    }
    
    func updatePlayerScore(_ score: Int) {
        // Update real leaderboard data
        let playerEntry = LeaderboardEntry(
            id: "current_player",
            playerName: playerName,
            score: score,
            level: ProgressionManager.shared.playerLevel,
            world: GameManager.shared.getCurrentWorld().name,
            rank: 1,
            isCurrentPlayer: true
        )
        
        // Update stored leaderboard
        if let index = realLeaderboard.firstIndex(where: { $0.isCurrentPlayer }) {
            realLeaderboard[index] = playerEntry
        } else {
            realLeaderboard.append(playerEntry)
        }
        
        saveLeaderboardData()
    }
    
    // MARK: - Clan Management
    func searchClans(query: String = "") -> [ClanData] {
        if query.isEmpty {
            return Array(mockClans.prefix(10)) // Return top 10 clans
        } else {
            return mockClans.filter { clan in
                clan.name.lowercased().contains(query.lowercased()) ||
                clan.description.lowercased().contains(query.lowercased())
            }
        }
    }
    
    func joinClan(_ clan: ClanData) -> Bool {
        // Simulate joining a clan
        if playerClan == nil && clan.memberCount < clan.maxMembers {
            var updatedClan = clan
            updatedClan = ClanData(
                id: clan.id,
                name: clan.name,
                description: clan.description,
                level: clan.level,
                memberCount: clan.memberCount + 1,
                maxMembers: clan.maxMembers,
                trophies: clan.trophies,
                rank: clan.rank,
                isPublic: clan.isPublic,
                inviteCode: clan.inviteCode
            )
            
            playerClan = updatedClan
            GameManager.shared.showNotification("🏴 Você entrou no clã \(clan.name)!")
            return true
        }
        return false
    }
    
    func leaveClan() -> Bool {
        if playerClan != nil {
            playerClan = nil
            GameManager.shared.showNotification("Você saiu do clã")
            return true
        }
        return false
    }
    
    func createClan(name: String, description: String, isPublic: Bool) -> Bool {
        if playerClan == nil && !name.isEmpty {
            let newClan = ClanData(
                id: UUID().uuidString,
                name: name,
                description: description,
                level: 1,
                memberCount: 1,
                maxMembers: 20,
                trophies: 0,
                rank: 999,
                isPublic: isPublic,
                inviteCode: generateInviteCode()
            )
            
            playerClan = newClan
            GameManager.shared.showNotification("🏴 Clã \(name) criado com sucesso!")
            return true
        }
        return false
    }
    
    func joinClanByCode(_ code: String) -> Bool {
        if let clan = mockClans.first(where: { $0.inviteCode == code.uppercased() }) {
            return joinClan(clan)
        }
        return false
    }
    
    private func generateInviteCode() -> String {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in characters.randomElement()! })
    }
    
    func getClanMembers() -> [ClanMember] {
        // Mock clan members
        return [
            ClanMember(id: "1", name: playerName, level: ProgressionManager.shared.playerLevel, contribution: 5000, rank: .leader, lastActive: Date()),
            ClanMember(id: "2", name: "SpaceVeteran", level: 35, contribution: 4500, rank: .viceLeader, lastActive: Date().addingTimeInterval(-3600)),
            ClanMember(id: "3", name: "StarFighter", level: 28, contribution: 3800, rank: .elder, lastActive: Date().addingTimeInterval(-7200)),
            ClanMember(id: "4", name: "CosmicRider", level: 22, contribution: 2900, rank: .veteran, lastActive: Date().addingTimeInterval(-14400)),
            ClanMember(id: "5", name: "GalaxyGuard", level: 18, contribution: 2100, rank: .member, lastActive: Date().addingTimeInterval(-21600))
        ]
    }
    
    // MARK: - Community Events
    func getActiveEvents() -> [CommunityEvent] {
        let now = Date()
        return mockEvents.filter { event in
            event.startDate <= now && event.endDate >= now
        }
    }
    
    func participateInEvent(_ eventId: String) -> Bool {
        if let index = mockEvents.firstIndex(where: { $0.id == eventId }) {
            mockEvents[index] = CommunityEvent(
                id: mockEvents[index].id,
                name: mockEvents[index].name,
                description: mockEvents[index].description,
                type: mockEvents[index].type,
                startDate: mockEvents[index].startDate,
                endDate: mockEvents[index].endDate,
                currentProgress: mockEvents[index].currentProgress,
                targetProgress: mockEvents[index].targetProgress,
                reward: mockEvents[index].reward,
                isParticipating: true,
                playerContribution: 0
            )
            
            GameManager.shared.showNotification("🌟 Você está participando do evento!")
            return true
        }
        return false
    }
    
    func contributeToEvent(_ eventId: String, contribution: Int) {
        if let index = mockEvents.firstIndex(where: { $0.id == eventId && $0.isParticipating }) {
            let event = mockEvents[index]
            mockEvents[index] = CommunityEvent(
                id: event.id,
                name: event.name,
                description: event.description,
                type: event.type,
                startDate: event.startDate,
                endDate: event.endDate,
                currentProgress: min(event.currentProgress + contribution, event.targetProgress),
                targetProgress: event.targetProgress,
                reward: event.reward,
                isParticipating: event.isParticipating,
                playerContribution: event.playerContribution + contribution
            )
            
            // Check if event is completed
            if mockEvents[index].currentProgress >= mockEvents[index].targetProgress {
                completeEvent(eventId)
            }
        }
    }
    
    private func completeEvent(_ eventId: String) {
        if let event = mockEvents.first(where: { $0.id == eventId && $0.isParticipating }) {
            // Give rewards
            GameManager.shared.coins += event.reward.coins
            ProgressionManager.shared.gems += event.reward.gems
            ProgressionManager.shared.addXP(event.reward.xp)
            
            if let shipId = event.reward.shipUnlock {
                var unlockedShips = GameManager.shared.unlockedShips
                if !unlockedShips.contains(shipId) {
                    unlockedShips.append(shipId)
                    GameManager.shared.unlockedShips = unlockedShips
                }
            }
            
            GameManager.shared.showNotification("🎉 Evento Completo! Recompensas recebidas!")
        }
    }
    
    // MARK: - Multiplayer Rooms
    func getAvailableRooms() -> [MultiplayerRoom] {
        // Filter out old rooms (older than 1 hour)
        let oneHourAgo = Date().addingTimeInterval(-3600)
        return mockRooms.filter { $0.createdAt > oneHourAgo && $0.currentPlayers < $0.maxPlayers }
    }
    
    func createRoom(name: String, gameMode: GameMode, maxPlayers: Int, isPrivate: Bool) -> MultiplayerRoom {
        let room = MultiplayerRoom(
            id: UUID().uuidString,
            name: name,
            hostName: playerName,
            currentPlayers: 1,
            maxPlayers: maxPlayers,
            gameMode: gameMode,
            difficulty: "Normal",
            isPrivate: isPrivate,
            inviteCode: isPrivate ? generateInviteCode() : nil,
            createdAt: Date()
        )
        
        mockRooms.append(room)
        return room
    }
    
    func joinRoom(_ room: MultiplayerRoom) -> Bool {
        if room.currentPlayers < room.maxPlayers {
            GameManager.shared.showNotification("🎮 Entrando na sala \(room.name)")
            return true
        }
        return false
    }
    
    func joinRoomByCode(_ code: String) -> MultiplayerRoom? {
        return mockRooms.first { $0.inviteCode == code.uppercased() }
    }
    
    // MARK: - Social Sharing
    func shareScore(platform: String, score: Int) {
        let message = """
        🚀 WAVESLAYERS - RELATÓRIO DE PONTUAÇÃO 🚀
        Jogador: \(playerName)
        Pontuação: \(score.formattedWithSeparator())
        Nível: \(ProgressionManager.shared.playerLevel)
        Mundo: \(GameManager.shared.getCurrentWorld().name)
        
        Desafie-me! 🌌
        """
        
        // Simulate sharing
        switch platform {
        case "twitter":
            shareToTwitter(message)
        case "facebook":
            shareToFacebook(message)
        case "discord":
            shareToDiscord(message)
        default:
            copyToClipboard(message)
        }
    }
    
    private func shareToTwitter(_ message: String) {
        let encodedMessage = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let twitterURL = "https://twitter.com/intent/tweet?text=\(encodedMessage)"
        
        if let url = URL(string: twitterURL) {
            UIApplication.shared.open(url)
        }
    }
    
    private func shareToFacebook(_ message: String) {
        let encodedMessage = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let facebookURL = "https://www.facebook.com/sharer/sharer.php?u=\(encodedMessage)"
        
        if let url = URL(string: facebookURL) {
            UIApplication.shared.open(url)
        }
    }
    
    private func shareToDiscord(_ message: String) {
        copyToClipboard(message)
        GameManager.shared.showNotification("📋 Mensagem copiada! Cole no Discord")
    }
    
    private func copyToClipboard(_ message: String) {
        UIPasteboard.general.string = message
        GameManager.shared.showNotification("📋 Copiado para área de transferência")
    }
    
    // MARK: - Player Name Management
    func changePlayerName(_ newName: String) -> Bool {
        if !newName.isEmpty && newName.count <= 20 {
            playerName = newName
            GameManager.shared.showNotification("Nome alterado para \(newName)")
            return true
        }
        return false
    }
    
    private func generateRandomPlayerName() -> String {
        let prefixes = ["Space", "Cosmic", "Star", "Galaxy", "Nebula", "Void", "Solar", "Lunar", "Plasma", "Quantum"]
        let suffixes = ["Pilot", "Hunter", "Warrior", "Master", "Slayer", "Guardian", "Rider", "Fighter", "Commander", "Hero"]
        
        let prefix = prefixes.randomElement() ?? "Space"
        let suffix = suffixes.randomElement() ?? "Pilot"
        let number = Int.random(in: 100...9999)
        
        return "\(prefix)\(suffix)\(number)"
    }
    
    // MARK: - Data Persistence
    func saveData() {
        saveLeaderboardData()
        saveEventProgress()
        saveClanData()
        UserDefaults.standard.synchronize()
    }
    
    private func saveLeaderboardData() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(realLeaderboard) {
            UserDefaults.standard.set(data, forKey: "waveslayers_real_leaderboard")
        }
    }
    
    private func saveEventProgress() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(mockEvents) {
            UserDefaults.standard.set(data, forKey: "waveslayers_events")
        }
    }
    
    private func saveClanData() {
        // Clan data is automatically saved via the playerClan property
    }
    
    private func loadSavedData() {
        loadLeaderboardData()
        loadEventProgress()
    }
    
    private func loadLeaderboardData() {
        let decoder = JSONDecoder()
        if let data = UserDefaults.standard.data(forKey: "waveslayers_real_leaderboard"),
           let saved = try? decoder.decode([LeaderboardEntry].self, from: data) {
            realLeaderboard = saved
        }
    }
    
    private func loadEventProgress() {
        let decoder = JSONDecoder()
        if let data = UserDefaults.standard.data(forKey: "waveslayers_events"),
           let saved = try? decoder.decode([CommunityEvent].self, from: data) {
            // Merge with current events, preserving saved progress
            for savedEvent in saved {
                if let index = mockEvents.firstIndex(where: { $0.id == savedEvent.id }) {
                    mockEvents[index] = savedEvent
                }
            }
        }
    }
    
    func resetData() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "waveslayers_player_name")
        defaults.removeObject(forKey: "waveslayers_player_clan")
        defaults.removeObject(forKey: "waveslayers_real_leaderboard")
        defaults.removeObject(forKey: "waveslayers_events")
        
        // Reset to initial values
        playerName = generateRandomPlayerName()
        playerClan = nil
        realLeaderboard = []
        setupMockEvents() // Reset events
        
        defaults.synchronize()
    }
}

// MARK: - Extensions
extension Int {
    func formattedWithSeparator() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

// MARK: - Codable Extensions
extension LeaderboardEntry: Codable {}
extension ClanData: Codable {}
extension ClanMember: Codable {}
extension CommunityEvent: Codable {}
extension EventReward: Codable {}
extension MultiplayerRoom: Codable {}
