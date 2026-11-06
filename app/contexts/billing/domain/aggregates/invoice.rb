module Billing
  module Domain
    module Aggregates
      class Invoice
        attr_reader :id, :payment_id, :number, :order_id, :order_name, :recipient_name, :recipient_email, :lines, :content, :content_type, :issued_at, :status, :tax_amount_cents, :billing_identity

        def initialize(id: nil, payment_id: nil, number:, order_id:, order_name:, recipient_name:, recipient_email:, lines:, content:, content_type: "text/html", issued_at: Time.current, status: "issued", tax_amount_cents: 0, billing_identity: nil)
          @id = id
          @payment_id = payment_id
          @number = number.to_s.strip
          @order_id = order_id.to_i
          @order_name = order_name.to_s.strip
          @recipient_name = recipient_name.to_s.strip
          @recipient_email = recipient_email.to_s.strip
          @lines = Array(lines).map do |line|
            line.is_a?(Billing::Domain::Entities::InvoiceLine) ? line : Billing::Domain::Entities::InvoiceLine.new(**line)
          end
          @content = content.to_s
          @content_type = content_type.to_s.strip.presence || "text/html"
          @issued_at = issued_at
          @status = status.to_s.strip.presence || "issued"
          @tax_amount_cents = tax_amount_cents.to_i
          @billing_identity = billing_identity
        end

        def filename(extension = nil)
          "#{number}.#{extension.presence || default_extension}"
        end

        def total_cents
          lines.sum(&:line_total_cents)
        end

        def html?
          content_type == "text/html"
        end

        def with_tax_amount(tax_amount_cents)
          self.class.new(**to_h.merge(tax_amount_cents: tax_amount_cents))
        end

        def with_billing_identity(billing_identity)
          self.class.new(**to_h.merge(billing_identity: billing_identity))
        end

        def paid?
          status == "paid"
        end

        def issued?
          status == "issued"
        end

        def to_h
          {
            id: id,
            payment_id: payment_id,
            number: number,
            order_id: order_id,
            order_name: order_name,
            recipient_name: recipient_name,
            recipient_email: recipient_email,
            lines: lines.map(&:to_h),
            content: content,
            content_type: content_type,
            issued_at: issued_at,
            status: status,
            tax_amount_cents: tax_amount_cents,
            billing_identity: billing_identity
          }
        end

        private

        def default_extension
          html? ? "html" : "pdf"
        end
      end
    end
  end
end
