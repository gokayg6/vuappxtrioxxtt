import { Router } from 'express';
import { prisma } from '../lib/prisma';
import { AppError } from '../middleware/errorHandler';

export const doubleDateRouter = Router();

// =====================================================
// TEAM MANAGEMENT
// =====================================================

// Kullanıcının aktif takımını getir veya oluştur
doubleDateRouter.get('/team', async (req, res, next) => {
  try {
    const userId = req.user!.id;
    
    // Kullanıcının aktif takımını bul
    let team = await prisma.doubleDateTeam.findFirst({
      where: {
        ownerId: userId,
        isActive: true,
      },
      include: {
        members: {
          include: {
            // User bilgilerini manuel olarak çekeceğiz
          },
        },
      },
    });
    
    // Takım yoksa oluştur
    if (!team) {
      team = await prisma.doubleDateTeam.create({
        data: {
          ownerId: userId,
          members: {
            create: {
              userId: userId,
              role: 'owner',
              status: 'accepted',
              joinedAt: new Date(),
            },
          },
        },
        include: {
          members: true,
        },
      });
    }
    
    // Üye bilgilerini çek
    const memberUserIds = team.members.map(m => m.userId);
    const users = await prisma.user.findMany({
      where: { id: { in: memberUserIds } },
      select: {
        id: true,
        displayName: true,
        profilePhotoUrl: true,
        lastActiveAt: true,
      },
    });
    
    const membersWithUsers = team.members.map(member => {
      const user = users.find(u => u.id === member.userId);
      return {
        id: member.id,
        user_id: member.userId,
        role: member.role,
        status: member.status,
        joined_at: member.joinedAt?.toISOString(),
        user: user ? {
          id: user.id,
          display_name: user.displayName,
          profile_photo_url: user.profilePhotoUrl,
          is_online: new Date().getTime() - user.lastActiveAt.getTime() < 300000,
        } : null,
      };
    });
    
    res.json({
      team: {
        id: team.id,
        owner_id: team.ownerId,
        name: team.name,
        is_active: team.isActive,
        members: membersWithUsers.filter(m => m.status === 'accepted'),
        pending_members: membersWithUsers.filter(m => m.status === 'pending'),
        created_at: team.createdAt.toISOString(),
      },
    });
  } catch (error) {
    next(error);
  }
});

// =====================================================
// INVITES
// =====================================================

// Arkadaşa davet gönder
doubleDateRouter.post('/invites', async (req, res, next) => {
  try {
    const userId = req.user!.id;
    const { friend_id, message } = req.body;
    
    if (!friend_id) {
      throw new AppError('Friend ID required', 400, 'FRIEND_ID_REQUIRED');
    }
    
    // Arkadaşlık kontrolü
    const friendship = await prisma.friendship.findFirst({
      where: {
        OR: [
          { userAId: userId, userBId: friend_id },
          { userAId: friend_id, userBId: userId },
        ],
      },
    });
    
    if (!friendship) {
      throw new AppError('You can only invite friends', 400, 'NOT_FRIENDS');
    }
    
    // Kullanıcının aktif takımını bul
    let team = await prisma.doubleDateTeam.findFirst({
      where: { ownerId: userId, isActive: true },
      include: { members: true },
    });
    
    if (!team) {
      // Takım oluştur
      team = await prisma.doubleDateTeam.create({
        data: {
          ownerId: userId,
          members: {
            create: {
              userId: userId,
              role: 'owner',
              status: 'accepted',
              joinedAt: new Date(),
            },
          },
        },
        include: { members: true },
      });
    }
    
    // Takımda max 3 kişi olabilir (owner dahil)
    const acceptedMembers = team.members.filter(m => m.status === 'accepted');
    if (acceptedMembers.length >= 3) {
      throw new AppError('Team is full (max 3 members)', 400, 'TEAM_FULL');
    }
    
    // Zaten takımda mı kontrol et
    const existingMember = team.members.find(m => m.userId === friend_id);
    if (existingMember) {
      if (existingMember.status === 'accepted') {
        throw new AppError('Already in team', 400, 'ALREADY_IN_TEAM');
      }
      if (existingMember.status === 'pending') {
        throw new AppError('Invite already sent', 400, 'INVITE_PENDING');
      }
    }
    
    // Mevcut davet var mı kontrol et
    const existingInvite = await prisma.doubleDateInvite.findFirst({
      where: {
        fromUserId: userId,
        toUserId: friend_id,
        status: 'pending',
      },
    });
    
    if (existingInvite) {
      throw new AppError('Invite already sent', 400, 'INVITE_EXISTS');
    }
    
    // Davet oluştur
    const invite = await prisma.doubleDateInvite.create({
      data: {
        fromUserId: userId,
        toUserId: friend_id,
        teamId: team.id,
        message: message,
        expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 gün
      },
    });
    
    // Takıma pending üye olarak ekle
    await prisma.doubleDateTeamMember.create({
      data: {
        teamId: team.id,
        userId: friend_id,
        role: 'member',
        status: 'pending',
      },
    });
    
    // Bildirim gönder
    await prisma.notification.create({
      data: {
        userId: friend_id,
        type: 'double_date_invite',
        titleKey: 'notification_double_date_invite_title',
        bodyKey: 'notification_double_date_invite_body',
        data: JSON.stringify({
          invite_id: invite.id,
          from_user_id: userId,
          team_id: team.id,
        }),
      },
    });
    
    res.json({
      success: true,
      invite_id: invite.id,
    });
  } catch (error) {
    next(error);
  }
});

// Gelen davetleri listele
doubleDateRouter.get('/invites/received', async (req, res, next) => {
  try {
    const userId = req.user!.id;
    
    const invites = await prisma.doubleDateInvite.findMany({
      where: {
        toUserId: userId,
        status: 'pending',
        expiresAt: { gt: new Date() },
      },
      orderBy: { createdAt: 'desc' },
    });
    
    // Gönderen kullanıcı bilgilerini çek
    const fromUserIds = invites.map(i => i.fromUserId);
    const users = await prisma.user.findMany({
      where: { id: { in: fromUserIds } },
      select: {
        id: true,
        displayName: true,
        profilePhotoUrl: true,
        lastActiveAt: true,
      },
    });
    
    res.json({
      invites: invites.map(invite => {
        const fromUser = users.find(u => u.id === invite.fromUserId);
        return {
          id: invite.id,
          from_user: fromUser ? {
            id: fromUser.id,
            display_name: fromUser.displayName,
            profile_photo_url: fromUser.profilePhotoUrl,
            is_online: new Date().getTime() - fromUser.lastActiveAt.getTime() < 300000,
          } : null,
          message: invite.message,
          created_at: invite.createdAt.toISOString(),
          expires_at: invite.expiresAt.toISOString(),
        };
      }),
    });
  } catch (error) {
    next(error);
  }
});

// Gönderilen davetleri listele
doubleDateRouter.get('/invites/sent', async (req, res, next) => {
  try {
    const userId = req.user!.id;
    
    const invites = await prisma.doubleDateInvite.findMany({
      where: {
        fromUserId: userId,
        status: 'pending',
      },
      orderBy: { createdAt: 'desc' },
    });
    
    const toUserIds = invites.map(i => i.toUserId);
    const users = await prisma.user.findMany({
      where: { id: { in: toUserIds } },
      select: {
        id: true,
        displayName: true,
        profilePhotoUrl: true,
      },
    });
    
    res.json({
      invites: invites.map(invite => {
        const toUser = users.find(u => u.id === invite.toUserId);
        return {
          id: invite.id,
          to_user: toUser ? {
            id: toUser.id,
            display_name: toUser.displayName,
            profile_photo_url: toUser.profilePhotoUrl,
          } : null,
          status: invite.status,
          created_at: invite.createdAt.toISOString(),
        };
      }),
    });
  } catch (error) {
    next(error);
  }
});

// Daveti kabul et
doubleDateRouter.post('/invites/:id/accept', async (req, res, next) => {
  try {
    const userId = req.user!.id;
    const inviteId = req.params.id;
    
    const invite = await prisma.doubleDateInvite.findUnique({
      where: { id: inviteId },
    });
    
    if (!invite) {
      throw new AppError('Invite not found', 404, 'INVITE_NOT_FOUND');
    }
    
    if (invite.toUserId !== userId) {
      throw new AppError('Not authorized', 403, 'NOT_AUTHORIZED');
    }
    
    if (invite.status !== 'pending') {
      throw new AppError('Invite already processed', 400, 'INVITE_PROCESSED');
    }
    
    if (invite.expiresAt < new Date()) {
      throw new AppError('Invite expired', 400, 'INVITE_EXPIRED');
    }
    
    // Daveti güncelle
    await prisma.doubleDateInvite.update({
      where: { id: inviteId },
      data: {
        status: 'accepted',
        respondedAt: new Date(),
      },
    });
    
    // Takım üyeliğini güncelle
    if (invite.teamId) {
      await prisma.doubleDateTeamMember.updateMany({
        where: {
          teamId: invite.teamId,
          userId: userId,
        },
        data: {
          status: 'accepted',
          joinedAt: new Date(),
        },
      });
    }
    
    // Bildirim gönder
    await prisma.notification.create({
      data: {
        userId: invite.fromUserId,
        type: 'double_date_invite_accepted',
        titleKey: 'notification_double_date_accepted_title',
        bodyKey: 'notification_double_date_accepted_body',
        data: JSON.stringify({
          user_id: userId,
          team_id: invite.teamId,
        }),
      },
    });
    
    res.json({ success: true });
  } catch (error) {
    next(error);
  }
});

// Daveti reddet
doubleDateRouter.post('/invites/:id/reject', async (req, res, next) => {
  try {
    const userId = req.user!.id;
    const inviteId = req.params.id;
    
    const invite = await prisma.doubleDateInvite.findUnique({
      where: { id: inviteId },
    });
    
    if (!invite) {
      throw new AppError('Invite not found', 404, 'INVITE_NOT_FOUND');
    }
    
    if (invite.toUserId !== userId) {
      throw new AppError('Not authorized', 403, 'NOT_AUTHORIZED');
    }
    
    // Daveti güncelle
    await prisma.doubleDateInvite.update({
      where: { id: inviteId },
      data: {
        status: 'rejected',
        respondedAt: new Date(),
      },
    });
    
    // Takım üyeliğini sil
    if (invite.teamId) {
      await prisma.doubleDateTeamMember.deleteMany({
        where: {
          teamId: invite.teamId,
          userId: userId,
        },
      });
    }
    
    res.json({ success: true });
  } catch (error) {
    next(error);
  }
});

// =====================================================
// DISCOVER TEAMS
// =====================================================

// Keşfedilecek takımları getir
doubleDateRouter.get('/discover', async (req, res, next) => {
  try {
    const userId = req.user!.id;
    const { limit = '10', offset = '0' } = req.query;
    
    // Kullanıcının takımını bul
    const myTeam = await prisma.doubleDateTeam.findFirst({
      where: { ownerId: userId, isActive: true },
      include: { members: { where: { status: 'accepted' } } },
    });
    
    if (!myTeam || myTeam.members.length < 2) {
      // Takım yok veya tek kişi - keşfet için en az 2 kişi gerekli
      res.json({
        teams: [],
        message: 'You need at least one teammate to discover other teams',
      });
      return;
    }
    
    // Zaten beğenilen veya eşleşilen takımları hariç tut
    const likedTeamIds = await prisma.doubleDateLike.findMany({
      where: { fromTeamId: myTeam.id },
      select: { toTeamId: true },
    });
    
    const matchedTeamIds = await prisma.doubleDateMatch.findMany({
      where: {
        OR: [
          { teamAId: myTeam.id },
          { teamBId: myTeam.id },
        ],
      },
      select: { teamAId: true, teamBId: true },
    });
    
    const excludeTeamIds = [
      myTeam.id,
      ...likedTeamIds.map(l => l.toTeamId),
      ...matchedTeamIds.flatMap(m => [m.teamAId, m.teamBId]),
    ];
    
    // Aktif takımları bul (en az 2 üyeli)
    const teams = await prisma.doubleDateTeam.findMany({
      where: {
        id: { notIn: excludeTeamIds },
        isActive: true,
      },
      include: {
        members: {
          where: { status: 'accepted' },
        },
      },
      take: parseInt(limit as string),
      skip: parseInt(offset as string),
    });
    
    // En az 2 üyeli takımları filtrele
    const validTeams = teams.filter(t => t.members.length >= 2);
    
    // Üye bilgilerini çek
    const allMemberIds = validTeams.flatMap(t => t.members.map(m => m.userId));
    const users = await prisma.user.findMany({
      where: { id: { in: allMemberIds } },
      select: {
        id: true,
        displayName: true,
        profilePhotoUrl: true,
        city: true,
        dateOfBirth: true,
        bio: true,
      },
    });
    
    res.json({
      teams: validTeams.map(team => ({
        id: team.id,
        name: team.name,
        members: team.members.map(member => {
          const user = users.find(u => u.id === member.userId);
          const age = user ? Math.floor((Date.now() - user.dateOfBirth.getTime()) / (365.25 * 24 * 60 * 60 * 1000)) : 0;
          return {
            id: member.id,
            user: user ? {
              id: user.id,
              display_name: user.displayName,
              profile_photo_url: user.profilePhotoUrl,
              city: user.city,
              age: age,
              bio: user.bio,
            } : null,
          };
        }),
      })),
    });
  } catch (error) {
    next(error);
  }
});

// =====================================================
// LIKES & MATCHES
// =====================================================

// Takımı beğen
doubleDateRouter.post('/likes', async (req, res, next) => {
  try {
    const userId = req.user!.id;
    const { team_id } = req.body;
    
    if (!team_id) {
      throw new AppError('Team ID required', 400, 'TEAM_ID_REQUIRED');
    }
    
    // Kullanıcının takımını bul
    const myTeam = await prisma.doubleDateTeam.findFirst({
      where: { ownerId: userId, isActive: true },
    });
    
    if (!myTeam) {
      throw new AppError('You need a team first', 400, 'NO_TEAM');
    }
    
    // Hedef takımı kontrol et
    const targetTeam = await prisma.doubleDateTeam.findUnique({
      where: { id: team_id },
    });
    
    if (!targetTeam) {
      throw new AppError('Team not found', 404, 'TEAM_NOT_FOUND');
    }
    
    // Zaten beğenilmiş mi kontrol et
    const existingLike = await prisma.doubleDateLike.findUnique({
      where: {
        fromTeamId_toTeamId: {
          fromTeamId: myTeam.id,
          toTeamId: team_id,
        },
      },
    });
    
    if (existingLike) {
      throw new AppError('Already liked', 400, 'ALREADY_LIKED');
    }
    
    // Beğeni oluştur
    await prisma.doubleDateLike.create({
      data: {
        fromTeamId: myTeam.id,
        toTeamId: team_id,
        likedByUserId: userId,
      },
    });
    
    // Karşılıklı beğeni var mı kontrol et (MATCH!)
    const mutualLike = await prisma.doubleDateLike.findUnique({
      where: {
        fromTeamId_toTeamId: {
          fromTeamId: team_id,
          toTeamId: myTeam.id,
        },
      },
    });
    
    let isMatch = false;
    let matchId: string | null = null;
    
    if (mutualLike) {
      // EŞLEŞME!
      isMatch = true;
      
      // Match oluştur
      const match = await prisma.doubleDateMatch.create({
        data: {
          teamAId: myTeam.id < team_id ? myTeam.id : team_id,
          teamBId: myTeam.id < team_id ? team_id : myTeam.id,
        },
      });
      
      matchId = match.id;
      
      // Her iki takımın üyelerine bildirim gönder
      const allMembers = await prisma.doubleDateTeamMember.findMany({
        where: {
          teamId: { in: [myTeam.id, team_id] },
          status: 'accepted',
        },
      });
      
      for (const member of allMembers) {
        await prisma.notification.create({
          data: {
            userId: member.userId,
            type: 'double_date_match',
            titleKey: 'notification_double_date_match_title',
            bodyKey: 'notification_double_date_match_body',
            data: JSON.stringify({
              match_id: match.id,
            }),
          },
        });
      }
    }
    
    res.json({
      success: true,
      is_match: isMatch,
      match_id: matchId,
    });
  } catch (error) {
    next(error);
  }
});

// Takımı geç (skip)
doubleDateRouter.post('/skip', async (req, res, next) => {
  try {
    const userId = req.user!.id;
    const { team_id } = req.body;
    
    // Şimdilik sadece success dön, ileride skip listesi tutulabilir
    res.json({ success: true });
  } catch (error) {
    next(error);
  }
});

// Eşleşmeleri getir
doubleDateRouter.get('/matches', async (req, res, next) => {
  try {
    const userId = req.user!.id;
    
    // Kullanıcının takımını bul
    const myTeam = await prisma.doubleDateTeam.findFirst({
      where: { ownerId: userId, isActive: true },
    });
    
    if (!myTeam) {
      res.json({ matches: [] });
      return;
    }
    
    // Eşleşmeleri bul
    const matches = await prisma.doubleDateMatch.findMany({
      where: {
        OR: [
          { teamAId: myTeam.id },
          { teamBId: myTeam.id },
        ],
        status: 'active',
      },
      include: {
        teamA: { include: { members: { where: { status: 'accepted' } } } },
        teamB: { include: { members: { where: { status: 'accepted' } } } },
      },
      orderBy: { createdAt: 'desc' },
    });
    
    // Tüm üyelerin user bilgilerini çek
    const allMemberIds = matches.flatMap(m => [
      ...m.teamA.members.map(mem => mem.userId),
      ...m.teamB.members.map(mem => mem.userId),
    ]);
    
    const users = await prisma.user.findMany({
      where: { id: { in: allMemberIds } },
      select: {
        id: true,
        displayName: true,
        profilePhotoUrl: true,
      },
    });
    
    res.json({
      matches: matches.map(match => {
        const otherTeam = match.teamAId === myTeam.id ? match.teamB : match.teamA;
        return {
          id: match.id,
          other_team: {
            id: otherTeam.id,
            members: otherTeam.members.map(member => {
              const user = users.find(u => u.id === member.userId);
              return {
                id: member.id,
                user: user ? {
                  id: user.id,
                  display_name: user.displayName,
                  profile_photo_url: user.profilePhotoUrl,
                } : null,
              };
            }),
          },
          created_at: match.createdAt.toISOString(),
        };
      }),
    });
  } catch (error) {
    next(error);
  }
});

// Takımdan üye çıkar
doubleDateRouter.delete('/team/members/:userId', async (req, res, next) => {
  try {
    const currentUserId = req.user!.id;
    const memberUserId = req.params.userId;
    
    // Kullanıcının takımını bul
    const myTeam = await prisma.doubleDateTeam.findFirst({
      where: { ownerId: currentUserId, isActive: true },
    });
    
    if (!myTeam) {
      throw new AppError('Team not found', 404, 'TEAM_NOT_FOUND');
    }
    
    // Owner kendini çıkaramaz
    if (memberUserId === currentUserId) {
      throw new AppError('Cannot remove yourself', 400, 'CANNOT_REMOVE_SELF');
    }
    
    // Üyeyi sil
    await prisma.doubleDateTeamMember.deleteMany({
      where: {
        teamId: myTeam.id,
        userId: memberUserId,
      },
    });
    
    res.json({ success: true });
  } catch (error) {
    next(error);
  }
});

// Takımdan ayrıl (owner değilse)
doubleDateRouter.post('/team/leave', async (req, res, next) => {
  try {
    const userId = req.user!.id;
    
    // Kullanıcının üye olduğu takımı bul
    const membership = await prisma.doubleDateTeamMember.findFirst({
      where: {
        userId: userId,
        status: 'accepted',
      },
      include: {
        team: true,
      },
    });
    
    if (!membership) {
      throw new AppError('Not in any team', 404, 'NOT_IN_TEAM');
    }
    
    // Owner takımdan ayrılamaz, takımı silmeli
    if (membership.team.ownerId === userId) {
      throw new AppError('Owner cannot leave team, deactivate instead', 400, 'OWNER_CANNOT_LEAVE');
    }
    
    // Üyeliği sil
    await prisma.doubleDateTeamMember.delete({
      where: { id: membership.id },
    });
    
    res.json({ success: true });
  } catch (error) {
    next(error);
  }
});

// Takımı deaktif et (sadece owner)
doubleDateRouter.post('/team/deactivate', async (req, res, next) => {
  try {
    const userId = req.user!.id;
    
    // Kullanıcının sahip olduğu takımı bul
    const team = await prisma.doubleDateTeam.findFirst({
      where: {
        ownerId: userId,
        isActive: true,
      },
    });
    
    if (!team) {
      throw new AppError('Team not found or not owner', 404, 'TEAM_NOT_FOUND');
    }
    
    // Takımı deaktif et
    await prisma.doubleDateTeam.update({
      where: { id: team.id },
      data: { isActive: false },
    });
    
    // Tüm üyeleri sil
    await prisma.doubleDateTeamMember.deleteMany({
      where: { teamId: team.id },
    });
    
    // İlgili eşleşmeleri deaktif et
    await prisma.doubleDateMatch.updateMany({
      where: {
        OR: [
          { teamAId: team.id },
          { teamBId: team.id },
        ],
      },
      data: { status: 'ended' },
    });
    
    res.json({ success: true });
  } catch (error) {
    next(error);
  }
});
