module TableSortingHelper
  def table_query_params(page:, sort: nil, direction: nil)
    { page: page }.tap do |query_params|
      query_params[:sort] = sort if sort.present?
      query_params[:direction] = direction if direction.present?
    end
  end

  def table_sort_link(label, sort_key, current_sort, current_direction, current_page, path:)
    next_sort, next_direction = table_next_sort_state(sort_key, current_sort, current_direction)
    link_classes = [ "text-reset", "text-decoration-none", "table-sort-link" ]
    link_classes << "is-active" if current_sort == sort_key

    link_options = {
      class: link_classes.join(" ")
    }
    link_options[:aria] = { current: "true" } if current_sort == sort_key

    link_to table_sort_path(path, page: current_page, sort: next_sort, direction: next_direction), link_options do
      safe_join([
        tag.span(label, class: "table-sort-label"),
        tag.span(class: "table-sort-arrows", aria: { hidden: true }) do
          safe_join([
            tag.span("↑", class: table_sort_arrow_class(current_sort, sort_key, current_direction, "asc")),
            tag.span("↓", class: table_sort_arrow_class(current_sort, sort_key, current_direction, "desc"))
          ])
        end
      ])
    end
  end

  def table_next_sort_state(sort_key, current_sort, current_direction)
    return [ sort_key, "desc" ] if current_sort != sort_key

    case current_direction
    when "desc"
      [ sort_key, "asc" ]
    else
      [ nil, nil ]
    end
  end

  def table_sort_arrow(direction)
    direction == "asc" ? "↑" : "↓"
  end

  def table_sort_arrow_class(current_sort, sort_key, current_direction, direction)
    classes = [ "table-sort-arrow" ]
    classes << "is-active" if current_sort == sort_key && current_direction == direction
    classes.join(" ")
  end

  def table_sort_path(path, page:, sort: nil, direction: nil)
    query = table_query_params(page:, sort:, direction:).to_query
    query.blank? ? path : "#{path}?#{query}"
  end
end
