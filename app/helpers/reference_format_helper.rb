# frozen_string_literal: true

module ReferenceFormatHelper
  def render_short_reference(value)
    return content_tag(:span, "—", class: "text-body-secondary") if value.blank?

    full_value = value.to_s.strip
    short_text = shorten_reference_string(full_value)

    content_tag(:span, class: "d-inline-flex align-items-center gap-1 font-monospace align-middle", data: { controller: "clipboard-copy" }) do
      concat content_tag(:code, short_text, class: "text-body-secondary bg-body px-1 py-0 rounded border text-decoration-none", title: full_value, style: "font-size: 0.82em; cursor: help;")
      concat(
        content_tag(
          :button,
          type: "button",
          class: "btn btn-link p-0 text-body-secondary text-decoration-none lh-1",
          title: "Copiar: #{full_value}",
          aria: { label: "Copiar #{full_value}" },
          data: { action: "click->clipboard-copy#copy", copy_value: full_value }
        ) do
          content_tag(:span, "📋", style: "font-size: 0.75rem; vertical-align: middle; opacity: 0.75;")
        end
      )
    end
  end

  def shorten_reference_string(val)
    return val if val.length <= 14

    if val.include?("-")
      parts = val.split("-")
      if parts.size >= 2
        "#{parts[0]}-#{parts[1]}…"
      else
        "#{val[0..12]}…"
      end
    elsif val.include?("_")
      parts = val.split("_")
      if parts.size >= 2
        "#{parts[0]}_#{parts[1][0..7]}…"
      else
        "#{val[0..12]}…"
      end
    else
      "#{val[0..12]}…"
    end
  end
end
