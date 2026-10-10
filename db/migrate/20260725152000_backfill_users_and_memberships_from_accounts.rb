class BackfillUsersAndMembershipsFromAccounts < ActiveRecord::Migration[8.1]
  class BackfillAccount < ActiveRecord::Base
    self.table_name = "accounts"
  end

  class BackfillUser < ActiveRecord::Base
    self.table_name = "users"
  end

  class BackfillMembership < ActiveRecord::Base
    self.table_name = "memberships"
  end

  def up
    validate_preconditions!
    backfill_users
    backfill_memberships
    validate_backfill!
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Identity backfill cannot be safely reversed"
  end

  private

  def validate_preconditions!
    invalid_accounts = BackfillAccount.where(email: [ nil, "" ]).or(BackfillAccount.where(role: [ nil, "" ]))
    return if invalid_accounts.none?

    raise "Cannot backfill identity: accounts contain blank email or role values"
  end

  def backfill_users
    user_rows = accounts_grouped_by_email.map do |email, accounts|
      latest = accounts.max_by { |account| [ account.updated_at, account.id ] }
      earliest = accounts.min_by { |account| [ account.created_at, account.id ] }

      {
        email: normalized_email(email),
        name: latest.name,
        access_state: "active",
        preferred_locale: nil,
        timezone: nil,
        notification_settings: {},
        invited_at: nil,
        verified_at: nil,
        suspended_at: nil,
        deactivated_at: nil,
        created_at: earliest.created_at,
        updated_at: latest.updated_at
      }
    end

    BackfillUser.upsert_all(user_rows) if user_rows.any?
  end

  def backfill_memberships
    user_by_email = BackfillUser.where(email: accounts_grouped_by_email.keys.map { |email| normalized_email(email) }).pluck(:email, :id).to_h

    membership_rows = BackfillAccount.find_each.map do |account|
      {
        user_id: user_by_email.fetch(normalized_email(account.email)),
        account_id: account.id,
        role: account.role,
        created_at: account.created_at,
        updated_at: account.updated_at
      }
    end

    BackfillMembership.upsert_all(membership_rows) if membership_rows.any?
  end

  def validate_backfill!
    expected_users = BackfillAccount.distinct.count(:email)
    expected_memberships = BackfillAccount.count

    raise "users backfill mismatch" unless BackfillUser.count == expected_users
    raise "memberships backfill mismatch" unless BackfillMembership.count == expected_memberships
  end

  def accounts_grouped_by_email
    @accounts_grouped_by_email ||= BackfillAccount.order(:id).to_a.group_by { |account| normalized_email(account.email) }
  end

  def normalized_email(email)
    email.to_s.strip.downcase
  end
end
