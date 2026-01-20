import Foundation

// MARK: - Double Date Models

struct DoubleDateTeam: Codable, Identifiable {
    let id: String
    let ownerId: String
    let name: String?
    let isActive: Bool
    let members: [DoubleDateMember]
    let pendingMembers: [DoubleDateMember]?
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case ownerId = "owner_id"
        case name
        case isActive = "is_active"
        case members
        case pendingMembers = "pending_members"
        case createdAt = "created_at"
    }
}

struct DoubleDateMember: Codable, Identifiable {
    let id: String
    let userId: String
    let role: String
    let status: String
    let joinedAt: String?
    let user: DoubleDateUser?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case role
        case status
        case joinedAt = "joined_at"
        case user
    }
}

struct DoubleDateUser: Codable, Identifiable {
    let id: String
    let displayName: String
    let profilePhotoUrl: String?
    let isOnline: Bool?
    let city: String?
    let age: Int?
    let bio: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case profilePhotoUrl = "profile_photo_url"
        case isOnline = "is_online"
        case city
        case age
        case bio
    }
}

struct DoubleDateInvite: Codable, Identifiable {
    let id: String
    let fromUser: DoubleDateUser?
    let toUser: DoubleDateUser?
    let message: String?
    let status: String?
    let createdAt: String
    let expiresAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case fromUser = "from_user"
        case toUser = "to_user"
        case message
        case status
        case createdAt = "created_at"
        case expiresAt = "expires_at"
    }
}

struct DoubleDateDiscoverTeam: Codable, Identifiable {
    let id: String
    let name: String?
    let members: [DoubleDateDiscoverMember]
}

struct DoubleDateDiscoverMember: Codable, Identifiable {
    let id: String
    let user: DoubleDateUser?
}

struct DoubleDateMatch: Codable, Identifiable {
    let id: String
    let otherTeam: DoubleDateMatchTeam
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case otherTeam = "other_team"
        case createdAt = "created_at"
    }
}

struct DoubleDateMatchTeam: Codable, Identifiable {
    let id: String
    let members: [DoubleDateDiscoverMember]
}

// MARK: - Double Date Service

actor DoubleDateService {
    static let shared = DoubleDateService()
    
    private init() {}
    
    // MARK: - Team Management
    
    func getMyTeam() async throws -> DoubleDateTeam {
        struct Response: Codable {
            let team: DoubleDateTeam
        }
        let response: Response = try await APIClient.shared.request(
            endpoint: "/doubledate/team",
            method: .get
        )
        return response.team
    }
    
    // MARK: - Invites
    
    struct SendInviteBody: Codable {
        let friendId: String
        let message: String?
        
        enum CodingKeys: String, CodingKey {
            case friendId = "friend_id"
            case message
        }
    }
    
    struct SendInviteResponse: Codable {
        let success: Bool
        let inviteId: String
        
        enum CodingKeys: String, CodingKey {
            case success
            case inviteId = "invite_id"
        }
    }
    
    func sendInvite(toFriendId: String, message: String? = nil) async throws -> SendInviteResponse {
        return try await APIClient.shared.request(
            endpoint: "/doubledate/invites",
            method: .post,
            body: SendInviteBody(friendId: toFriendId, message: message)
        )
    }
    
    func getReceivedInvites() async throws -> [DoubleDateInvite] {
        struct Response: Codable {
            let invites: [DoubleDateInvite]
        }
        let response: Response = try await APIClient.shared.request(
            endpoint: "/doubledate/invites/received",
            method: .get
        )
        return response.invites
    }
    
    func getSentInvites() async throws -> [DoubleDateInvite] {
        struct Response: Codable {
            let invites: [DoubleDateInvite]
        }
        let response: Response = try await APIClient.shared.request(
            endpoint: "/doubledate/invites/sent",
            method: .get
        )
        return response.invites
    }
    
    func acceptInvite(inviteId: String) async throws {
        struct Response: Codable {
            let success: Bool
        }
        let _: Response = try await APIClient.shared.request(
            endpoint: "/doubledate/invites/\(inviteId)/accept",
            method: .post
        )
    }
    
    func rejectInvite(inviteId: String) async throws {
        struct Response: Codable {
            let success: Bool
        }
        let _: Response = try await APIClient.shared.request(
            endpoint: "/doubledate/invites/\(inviteId)/reject",
            method: .post
        )
    }
    
    // MARK: - Discover Teams
    
    func discoverTeams(limit: Int = 10, offset: Int = 0) async throws -> [DoubleDateDiscoverTeam] {
        struct Response: Codable {
            let teams: [DoubleDateDiscoverTeam]
            let message: String?
        }
        let response: Response = try await APIClient.shared.request(
            endpoint: "/doubledate/discover?limit=\(limit)&offset=\(offset)",
            method: .get
        )
        return response.teams
    }
    
    // MARK: - Likes & Matches
    
    struct LikeTeamBody: Codable {
        let teamId: String
        
        enum CodingKeys: String, CodingKey {
            case teamId = "team_id"
        }
    }
    
    struct LikeTeamResponse: Codable {
        let success: Bool
        let isMatch: Bool
        let matchId: String?
        
        enum CodingKeys: String, CodingKey {
            case success
            case isMatch = "is_match"
            case matchId = "match_id"
        }
    }
    
    func likeTeam(teamId: String) async throws -> LikeTeamResponse {
        return try await APIClient.shared.request(
            endpoint: "/doubledate/likes",
            method: .post,
            body: LikeTeamBody(teamId: teamId)
        )
    }
    
    func skipTeam(teamId: String) async throws {
        struct Response: Codable {
            let success: Bool
        }
        let _: Response = try await APIClient.shared.request(
            endpoint: "/doubledate/skip",
            method: .post,
            body: LikeTeamBody(teamId: teamId)
        )
    }
    
    func getMatches() async throws -> [DoubleDateMatch] {
        struct Response: Codable {
            let matches: [DoubleDateMatch]
        }
        let response: Response = try await APIClient.shared.request(
            endpoint: "/doubledate/matches",
            method: .get
        )
        return response.matches
    }
    
    // MARK: - Team Member Management
    
    func removeTeamMember(userId: String) async throws {
        struct Response: Codable {
            let success: Bool
        }
        let _: Response = try await APIClient.shared.request(
            endpoint: "/doubledate/team/members/\(userId)",
            method: .delete
        )
    }
    
    // MARK: - Team Management
    
    func leaveTeam() async throws {
        struct Response: Codable {
            let success: Bool
        }
        let _: Response = try await APIClient.shared.request(
            endpoint: "/doubledate/team/leave",
            method: .post
        )
    }
    
    func deactivateTeam() async throws {
        struct Response: Codable {
            let success: Bool
        }
        let _: Response = try await APIClient.shared.request(
            endpoint: "/doubledate/team/deactivate",
            method: .post
        )
    }
}
