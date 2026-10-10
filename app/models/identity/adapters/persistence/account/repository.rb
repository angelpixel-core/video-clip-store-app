module Identity
  module Adapters
    module Persistence
      module Account
        class Repository < Identity::Domain::Repositories::Account::Contract
          def initialize(mapper: Mapper.new)
            @mapper = mapper
          end

          def find_by_email(email)
            record = AccountRecord.find_by(email: normalize_email(email))
            return unless record

            mapper.to_domain(record)
          end

          def find_by_email_and_role(email, role)
            record = mapper.scope_for(role).find_by(email: normalize_email(email))
            return unless record

            mapper.to_domain(record)
          end

          def find_by_role(role)
            mapper.scope_for(role)
          end

          def find_by_user(user)
            records_to_domain(
              AccountRecord.joins(:memberships).where(memberships: { user_id: user.id }).distinct
            )
          end

          def find_by_user_and_role(user, role)
            records_to_domain(
              AccountRecord.joins(:memberships).where(
                memberships: {
                  user_id: user.id,
                  role: normalize_role(role)
                }
              ).distinct
            )
          end

          private

          attr_reader :mapper

          def normalize_email(email)
            email.to_s.strip.downcase
          end

          def normalize_role(role)
            role.to_s.strip.downcase
          end

          def records_to_domain(records)
            records.map { |record| mapper.to_domain(record) }.compact
          end
        end
      end
    end
  end
end
