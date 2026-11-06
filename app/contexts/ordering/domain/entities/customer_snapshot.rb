module Ordering
  module Domain
    module Entities
      class CustomerSnapshot
        attr_reader :account_id, :account_uid, :name, :email, :role

        def self.from_account(account)
          new(account_id: account.id, name: account.name, email: account.email, role: account.role, account_uid: account.try(:uid))
        end

        def initialize(account_id:, name:, email:, role:, account_uid: nil)
          @account_id = account_id&.to_i
          @account_uid = account_uid&.to_s
          @name = name.to_s.strip
          @email = email.to_s.strip.downcase
          @role = role.to_s.strip.downcase
        end

        def to_h
          {
            account_id: account_id,
            account_uid: account_uid,
            name: name,
            email: email,
            role: role
          }.compact
        end

        def ==(other)
          other.respond_to?(:to_h) && other.to_h == to_h
        end
      end
    end
  end
end
