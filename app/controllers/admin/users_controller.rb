# frozen_string_literal: true

module Admin
  class UsersController < AdminControllerBase

    def index
      @user = User
      respond_index @user
    end

    protected

    def augment(records)
      return [] if records.blank?

      user_ids = records.map { |r| r["id"] }

      # 1. Active sessions in the last 30 minutes
      active_since = 30.minutes.ago
      active_session_counts = UserSession
                                .where(user_id: user_ids)
                                .where.not(jwt_jti: JwtDenylist.select(:jti))
                                .group(:user_id)
                                .count

      # 2. Journal entry counts
      journal_entry_counts = JournalEntry
                               .where(user_id: user_ids)
                               .group(:user_id)
                               .count

      records.map do |record|
        puts record
        {
          id: record["id"],
          email: record["email"],
          created_at: record["created_at"],
          updated_at: record["updated_at"],
          nickname: record["nickname"],
          sessions_count: active_session_counts[record["id"]] || 0,
          journals_count: journal_entry_counts[record["id"]] || 0,
        }
      end
    end

  end
end
