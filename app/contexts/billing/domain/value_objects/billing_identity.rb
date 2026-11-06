module Billing
  module Domain
    module ValueObjects
      class BillingIdentity
        attr_reader :name, :tax_id, :country_code

        def initialize(name:, tax_id: nil, country_code: "AR")
          @name = name.to_s.strip
          @tax_id = tax_id.to_s.strip.presence
          @country_code = country_code.to_s.strip.upcase.presence || "AR"
        end

        def argentina?
          country_code == "AR"
        end

        def to_h
          {
            name: name,
            tax_id: tax_id,
            country_code: country_code
          }
        end
      end
    end
  end
end
