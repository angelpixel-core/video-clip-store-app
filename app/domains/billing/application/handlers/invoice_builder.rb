module Billing
  module Application
    module Handlers
      class InvoiceBuilder
        def self.call(payment:)
          new(payment:).call
        end

        def initialize(payment:)
          @payment = payment
        end

        def call
          Billing::Domain::Aggregates::Invoice.new(
            payment_id: payment.id,
            number: invoice_number,
            order_id: payment.project.id,
            order_name: payment.project.name,
            recipient_name: payment.project.owner.name,
            recipient_email: payment.project.owner.email,
            lines: invoice_lines,
            content: render_content,
            content_type: "text/html",
            issued_at: payment.confirmed_at || Time.current
          )
        end

        private

        attr_reader :payment

        def invoice_number
          payment.invoice_number.presence || "INV-#{payment.id.to_s.rjust(7, '0')}"
        end

        def invoice_lines
          payment.project.video_type_selections.includes(:video_type).map do |selection|
            Billing::Domain::Entities::InvoiceLine.from_selection(selection)
          end
        end

        def render_content
          lines_markup = invoice_lines.map do |line|
            "<tr><td>#{line.description}</td><td>#{line.quantity}</td><td>#{format_money(line.unit_amount_cents)}</td><td>#{format_money(line.line_total_cents)}</td></tr>"
          end.join

          <<~HTML
            <html>
              <body>
                <h1>Invoice #{invoice_number}</h1>
                <p>Order: #{payment.project.name}</p>
                <p>Owner: #{payment.project.owner.name}</p>
                <p>Payment ID: #{payment.id}</p>
                <p>Provider reference: #{payment.provider_reference}</p>
                <p>Amount: #{payment.currency} #{format_money(payment.amount_cents)}</p>
                <p>Paid at: #{(payment.confirmed_at || Time.current).utc.iso8601}</p>
                <table>
                  <thead>
                    <tr><th>Description</th><th>Qty</th><th>Unit</th><th>Total</th></tr>
                  </thead>
                  <tbody>
                    #{lines_markup}
                  </tbody>
                </table>
              </body>
            </html>
          HTML
        end

        def format_money(amount_cents)
          format("%.2f", amount_cents.to_f / 100)
        end
      end
    end
  end
end
