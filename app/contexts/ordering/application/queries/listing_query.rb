module Ordering
  module Application
    module Queries
      class ListingQuery
        SORTS = {
          "id" => "orders.id",
          "created_at" => "orders.created_at",
          "total_budget" => "total_budget_cents"
        }.freeze
        VALID_SORTS = SORTS.keys.freeze
        VALID_DIRECTIONS = %w[asc desc].freeze
        DEFAULT_SORT = "created_at"
        DEFAULT_DIRECTION = "desc"

        def initialize(params)
          @params = params
        end

        def call
          relation
            .order(Arel.sql("#{order_column} #{order_direction}"))
            .limit(per_page)
            .offset((page - 1) * per_page)
        end

        def total_pages
          (total_count.to_f / per_page).ceil
        end

        def total_count
          Ordering::Adapters::Persistence::Order::OrderRecord.where.not(status: :draft).count
        end

        def sort
          VALID_SORTS.include?(params[:sort]) ? params[:sort] : nil
        end

        def direction
          VALID_DIRECTIONS.include?(params[:direction]) ? params[:direction] : nil
        end

        def page
          value = params[:page].to_i
          value.positive? ? value : 1
        end

        private

        attr_reader :params

        def per_page
          10
        end

        def relation
          order_scope.includes(:owner, :participant, payments: :refunds)
        end

        def order_scope
          Ordering::Adapters::Persistence::Order::OrderRecord
            .left_outer_joins(:order_line_records)
            .select(<<~SQL.squish)
              orders.*,
              COALESCE(SUM(order_lines.line_total_cents), 0) AS total_budget_cents
            SQL
            .group("orders.id")
            .where.not(status: :draft)
        end

        def order_column
          SORTS.fetch(sort.presence, SORTS[DEFAULT_SORT])
        end

        def order_direction
          normalized_direction = direction.presence || DEFAULT_DIRECTION
          normalized_direction == "asc" ? "ASC" : "DESC"
        end
      end
    end
  end
end
