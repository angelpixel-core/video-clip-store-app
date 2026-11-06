module Payments
  module Adapters
    module Outbound
      module Mailers
        class PaymentNotificationMailer < ApplicationMailer
          def payment_status_changed(intent, recipient_role:)
            @intent = intent
            @payment = intent.payment
            @project = intent.project
            @recipient_role = recipient_role.to_s

            mail(to: recipient_email_for(recipient_role), subject: subject_for(intent, recipient_role))
          end

          private

          def recipient_email_for(recipient_role)
            case recipient_role.to_s
            when "pm"
              @project.participant.email
            else
              @project.owner.email
            end
          end

          def subject_for(intent, recipient_role)
            base = "Payment #{intent.to_status.humanize.downcase} for #{@project.name}"

            recipient_role.to_s == "pm" ? "#{base} - PM update" : base
          end
        end
      end
    end
  end
end
