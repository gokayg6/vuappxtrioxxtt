-- CreateTable
CREATE TABLE "users" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "username" TEXT NOT NULL,
    "phone" TEXT,
    "email" TEXT,
    "apple_id" TEXT,
    "google_id" TEXT,
    "display_name" TEXT NOT NULL,
    "date_of_birth" DATETIME NOT NULL,
    "gender" TEXT NOT NULL,
    "country" TEXT NOT NULL,
    "city" TEXT NOT NULL,
    "bio" TEXT,
    "profile_photo_url" TEXT NOT NULL,
    "tiktok_username" TEXT,
    "instagram_username" TEXT,
    "snapchat_username" TEXT,
    "show_mode" TEXT NOT NULL DEFAULT 'local',
    "is_premium" BOOLEAN NOT NULL DEFAULT false,
    "premium_expires_at" DATETIME,
    "is_verified" BOOLEAN NOT NULL DEFAULT false,
    "is_banned" BOOLEAN NOT NULL DEFAULT false,
    "ban_reason" TEXT,
    "latitude" REAL,
    "longitude" REAL,
    "device_fingerprint" TEXT,
    "last_active_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" DATETIME NOT NULL
);

-- CreateTable
CREATE TABLE "user_photos" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "user_id" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "thumbnail_url" TEXT,
    "order_index" INTEGER NOT NULL,
    "is_primary" BOOLEAN NOT NULL DEFAULT false,
    "moderation_status" TEXT NOT NULL DEFAULT 'pending',
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "user_photos_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "user_tags" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "user_id" TEXT NOT NULL,
    "tag_code" TEXT NOT NULL,
    "order_index" INTEGER NOT NULL,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "user_tags_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "interests" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "code" TEXT NOT NULL,
    "name_en" TEXT NOT NULL,
    "name_es" TEXT NOT NULL,
    "name_pt" TEXT NOT NULL,
    "name_fr" TEXT NOT NULL,
    "name_tr" TEXT NOT NULL,
    "emoji" TEXT,
    "category" TEXT NOT NULL
);

-- CreateTable
CREATE TABLE "user_interests" (
    "user_id" TEXT NOT NULL,
    "interest_id" TEXT NOT NULL,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY ("user_id", "interest_id"),
    CONSTRAINT "user_interests_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "user_interests_interest_id_fkey" FOREIGN KEY ("interest_id") REFERENCES "interests" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "likes" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "from_user_id" TEXT NOT NULL,
    "to_user_id" TEXT NOT NULL,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "likes_from_user_id_fkey" FOREIGN KEY ("from_user_id") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "likes_to_user_id_fkey" FOREIGN KEY ("to_user_id") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "requests" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "from_user_id" TEXT NOT NULL,
    "to_user_id" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'pending',
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "responded_at" DATETIME,
    CONSTRAINT "requests_from_user_id_fkey" FOREIGN KEY ("from_user_id") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "requests_to_user_id_fkey" FOREIGN KEY ("to_user_id") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "friendships" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "user_a_id" TEXT NOT NULL,
    "user_b_id" TEXT NOT NULL,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "friendships_user_a_id_fkey" FOREIGN KEY ("user_a_id") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "friendships_user_b_id_fkey" FOREIGN KEY ("user_b_id") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "favorites" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "user_id" TEXT NOT NULL,
    "favorited_user_id" TEXT NOT NULL,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "favorites_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "favorites_favorited_user_id_fkey" FOREIGN KEY ("favorited_user_id") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "skipped_users" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "user_id" TEXT NOT NULL,
    "skipped_user_id" TEXT NOT NULL,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expires_at" DATETIME NOT NULL,
    CONSTRAINT "skipped_users_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "skipped_users_skipped_user_id_fkey" FOREIGN KEY ("skipped_user_id") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "reports" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "reporter_id" TEXT NOT NULL,
    "reported_user_id" TEXT NOT NULL,
    "reason" TEXT NOT NULL,
    "description" TEXT,
    "status" TEXT NOT NULL DEFAULT 'pending',
    "admin_notes" TEXT,
    "reviewed_by" TEXT,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "reviewed_at" DATETIME,
    CONSTRAINT "reports_reporter_id_fkey" FOREIGN KEY ("reporter_id") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "reports_reported_user_id_fkey" FOREIGN KEY ("reported_user_id") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "boosts" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "user_id" TEXT NOT NULL,
    "boost_type" TEXT NOT NULL,
    "multiplier" REAL NOT NULL DEFAULT 2.0,
    "started_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expires_at" DATETIME NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    CONSTRAINT "boosts_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "purchases" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "user_id" TEXT NOT NULL,
    "product_id" TEXT NOT NULL,
    "transaction_id" TEXT NOT NULL,
    "original_transaction_id" TEXT,
    "purchase_type" TEXT NOT NULL,
    "amount" REAL,
    "currency" TEXT,
    "status" TEXT NOT NULL DEFAULT 'completed',
    "receipt_data" TEXT,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expires_at" DATETIME,
    CONSTRAINT "purchases_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "notifications" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "user_id" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "title_key" TEXT NOT NULL,
    "body_key" TEXT NOT NULL,
    "data" TEXT,
    "is_read" BOOLEAN NOT NULL DEFAULT false,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "notifications_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "rate_limits" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "visitor_id" TEXT NOT NULL,
    "action_type" TEXT NOT NULL,
    "count" INTEGER NOT NULL DEFAULT 0,
    "window_start" DATETIME NOT NULL,
    "window_end" DATETIME NOT NULL
);

-- CreateTable
CREATE TABLE "cooldowns" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "user_id" TEXT NOT NULL,
    "target_user_id" TEXT NOT NULL,
    "action_type" TEXT NOT NULL,
    "expires_at" DATETIME NOT NULL,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- CreateTable
CREATE TABLE "app_logs" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "timestamp" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "level" TEXT NOT NULL,
    "category" TEXT NOT NULL,
    "message" TEXT NOT NULL,
    "metadata" TEXT,
    "user_id" TEXT,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- CreateTable
CREATE TABLE "user_settings" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "user_id" TEXT NOT NULL,
    "theme" TEXT NOT NULL DEFAULT 'dark',
    "language" TEXT NOT NULL DEFAULT 'tr',
    "push_notifications" BOOLEAN NOT NULL DEFAULT true,
    "match_notifications" BOOLEAN NOT NULL DEFAULT true,
    "message_notifications" BOOLEAN NOT NULL DEFAULT true,
    "like_notifications" BOOLEAN NOT NULL DEFAULT true,
    "hide_age" BOOLEAN NOT NULL DEFAULT false,
    "hide_distance" BOOLEAN NOT NULL DEFAULT false,
    "hide_online_status" BOOLEAN NOT NULL DEFAULT false,
    "read_receipts" BOOLEAN NOT NULL DEFAULT true,
    "location_enabled" BOOLEAN NOT NULL DEFAULT true,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" DATETIME NOT NULL
);

-- CreateTable
CREATE TABLE "discover_filters" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "user_id" TEXT NOT NULL,
    "min_age" INTEGER NOT NULL DEFAULT 18,
    "max_age" INTEGER NOT NULL DEFAULT 50,
    "max_distance" INTEGER NOT NULL DEFAULT 100,
    "show_men" BOOLEAN NOT NULL DEFAULT true,
    "show_women" BOOLEAN NOT NULL DEFAULT true,
    "show_non_binary" BOOLEAN NOT NULL DEFAULT true,
    "only_active" BOOLEAN NOT NULL DEFAULT false,
    "only_verified" BOOLEAN NOT NULL DEFAULT false,
    "only_with_photos" BOOLEAN NOT NULL DEFAULT true,
    "only_with_bio" BOOLEAN NOT NULL DEFAULT false,
    "hide_already_seen" BOOLEAN NOT NULL DEFAULT false,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" DATETIME NOT NULL
);

-- CreateTable
CREATE TABLE "double_date_teams" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "owner_id" TEXT NOT NULL,
    "name" TEXT,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" DATETIME NOT NULL
);

-- CreateTable
CREATE TABLE "double_date_team_members" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "team_id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "role" TEXT NOT NULL DEFAULT 'member',
    "status" TEXT NOT NULL DEFAULT 'pending',
    "joined_at" DATETIME,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "double_date_team_members_team_id_fkey" FOREIGN KEY ("team_id") REFERENCES "double_date_teams" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "double_date_invites" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "from_user_id" TEXT NOT NULL,
    "to_user_id" TEXT NOT NULL,
    "team_id" TEXT,
    "status" TEXT NOT NULL DEFAULT 'pending',
    "message" TEXT,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "responded_at" DATETIME,
    "expires_at" DATETIME NOT NULL
);

-- CreateTable
CREATE TABLE "double_date_likes" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "from_team_id" TEXT NOT NULL,
    "to_team_id" TEXT NOT NULL,
    "liked_by_user_id" TEXT NOT NULL,
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "double_date_likes_from_team_id_fkey" FOREIGN KEY ("from_team_id") REFERENCES "double_date_teams" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "double_date_likes_to_team_id_fkey" FOREIGN KEY ("to_team_id") REFERENCES "double_date_teams" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "double_date_matches" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "team_a_id" TEXT NOT NULL,
    "team_b_id" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'active',
    "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "double_date_matches_team_a_id_fkey" FOREIGN KEY ("team_a_id") REFERENCES "double_date_teams" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "double_date_matches_team_b_id_fkey" FOREIGN KEY ("team_b_id") REFERENCES "double_date_teams" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateIndex
CREATE UNIQUE INDEX "users_username_key" ON "users"("username");

-- CreateIndex
CREATE UNIQUE INDEX "users_phone_key" ON "users"("phone");

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE UNIQUE INDEX "users_apple_id_key" ON "users"("apple_id");

-- CreateIndex
CREATE UNIQUE INDEX "users_google_id_key" ON "users"("google_id");

-- CreateIndex
CREATE INDEX "users_country_city_idx" ON "users"("country", "city");

-- CreateIndex
CREATE UNIQUE INDEX "user_photos_user_id_order_index_key" ON "user_photos"("user_id", "order_index");

-- CreateIndex
CREATE UNIQUE INDEX "user_tags_user_id_tag_code_key" ON "user_tags"("user_id", "tag_code");

-- CreateIndex
CREATE UNIQUE INDEX "user_tags_user_id_order_index_key" ON "user_tags"("user_id", "order_index");

-- CreateIndex
CREATE UNIQUE INDEX "interests_code_key" ON "interests"("code");

-- CreateIndex
CREATE UNIQUE INDEX "likes_from_user_id_to_user_id_key" ON "likes"("from_user_id", "to_user_id");

-- CreateIndex
CREATE UNIQUE INDEX "requests_from_user_id_to_user_id_key" ON "requests"("from_user_id", "to_user_id");

-- CreateIndex
CREATE UNIQUE INDEX "friendships_user_a_id_user_b_id_key" ON "friendships"("user_a_id", "user_b_id");

-- CreateIndex
CREATE UNIQUE INDEX "favorites_user_id_favorited_user_id_key" ON "favorites"("user_id", "favorited_user_id");

-- CreateIndex
CREATE UNIQUE INDEX "skipped_users_user_id_skipped_user_id_key" ON "skipped_users"("user_id", "skipped_user_id");

-- CreateIndex
CREATE UNIQUE INDEX "purchases_transaction_id_key" ON "purchases"("transaction_id");

-- CreateIndex
CREATE UNIQUE INDEX "rate_limits_visitor_id_action_type_window_start_key" ON "rate_limits"("visitor_id", "action_type", "window_start");

-- CreateIndex
CREATE UNIQUE INDEX "cooldowns_user_id_target_user_id_action_type_key" ON "cooldowns"("user_id", "target_user_id", "action_type");

-- CreateIndex
CREATE INDEX "app_logs_level_idx" ON "app_logs"("level");

-- CreateIndex
CREATE INDEX "app_logs_category_idx" ON "app_logs"("category");

-- CreateIndex
CREATE INDEX "app_logs_user_id_idx" ON "app_logs"("user_id");

-- CreateIndex
CREATE INDEX "app_logs_timestamp_idx" ON "app_logs"("timestamp");

-- CreateIndex
CREATE UNIQUE INDEX "user_settings_user_id_key" ON "user_settings"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "discover_filters_user_id_key" ON "discover_filters"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "double_date_team_members_team_id_user_id_key" ON "double_date_team_members"("team_id", "user_id");

-- CreateIndex
CREATE UNIQUE INDEX "double_date_invites_from_user_id_to_user_id_team_id_key" ON "double_date_invites"("from_user_id", "to_user_id", "team_id");

-- CreateIndex
CREATE UNIQUE INDEX "double_date_likes_from_team_id_to_team_id_key" ON "double_date_likes"("from_team_id", "to_team_id");

-- CreateIndex
CREATE UNIQUE INDEX "double_date_matches_team_a_id_team_b_id_key" ON "double_date_matches"("team_a_id", "team_b_id");
