module Orders
  class OrderFormPresenter
    attr_reader :project, :path, :param_key, :context, :fields

    def initialize(project:, path:, context: :edit, param_key: :project, fields: Fields.new)
      @project = project
      @path = path
      @context = context.to_sym
      @param_key = param_key
      @fields = fields
    end

    def title
      case context
      when :new
        fields.new_order_title
      else
        project.draft? ? fields.resume_draft_title : fields.edit_order_title
      end
    end

    def field_name(field)
      "#{param_key}[#{field}]"
    end

    def card_rules
      [
        { id: "visa", name: "Visa", pattern: "^4", lengths: [ 13, 16, 19 ], format: "4-4-4-4", cvc_length: 3 },
        { id: "mastercard", name: "Mastercard", pattern: "^(5[1-5]|2[2-7])", lengths: [ 16 ], format: "4-4-4-4", cvc_length: 3 },
        { id: "amex", name: "American Express", pattern: "^3[47]", lengths: [ 15 ], format: "4-6-5", cvc_length: 4 },
        { id: "discover", name: "Discover", pattern: "^(6011|65|64[4-9]|622)", lengths: [ 16, 19 ], format: "4-4-4-4", cvc_length: 3 },
        { id: "diners", name: "Diners Club", pattern: "^(36|38|30[0-5])", lengths: [ 14, 16 ], format: "4-6-4", cvc_length: 3 },
        { id: "jcb", name: "JCB", pattern: "^35(2[89]|[3-8][0-9])", lengths: [ 16, 19 ], format: "4-4-4-4", cvc_length: 3 },
        { id: "unionpay", name: "UnionPay", pattern: "^62", lengths: [ 16, 19 ], format: "4-4-4-4", cvc_length: 3 },
        { id: "maestro", name: "Maestro", pattern: "^(5018|5020|5038|5893|6304|6759|676[1-3])", lengths: [ 12, 13, 14, 15, 16, 18, 19 ], format: "4-4-4-4", cvc_length: 3 },
        { id: "elo", name: "Elo", pattern: "^(4011|4312|4389|4514|4576|5041|5067|5090|6277|6362|6363)", lengths: [ 16 ], format: "4-4-4-4", cvc_length: 3 }
      ]
    end

    class Fields
      def new_order_title
        "Create a new order"
      end

      def edit_order_title
        "Edit order"
      end

      def resume_draft_title
        "Resume draft"
      end

      def order_details_title
        "Order details"
      end

      def name_label
        "Name"
      end

      def name_placeholder
        "Order name"
      end

      def raw_footage_url_label
        "Raw footage URL"
      end

      def raw_footage_url_placeholder
        "https://..."
      end

      def available_video_types_title
        available_offers_title
      end

      def available_offers_title
        "Available offers"
      end

      def cart_title
        "Cart"
      end

      def empty_cart_text
        "No selections yet."
      end

      def review_button_label
        "Review and pay"
      end

      def payment_modal_title
        "Payment details"
      end

      def payment_modal_description
        "This is a simulated payment step for order checkout."
      end

      def billing_email_label
        "Billing email"
      end

      def cancel_button_label
        "Cancel"
      end

      def finalize_button_label
        "Pay and create order"
      end

      def finalize_spinner_label
        "Creating order..."
      end
    end
  end
end
