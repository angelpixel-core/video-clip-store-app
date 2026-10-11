# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReferenceFormatHelper, type: :helper do
  describe "#shorten_reference_string" do
    it "keeps short strings intact" do
      expect(helper.shorten_reference_string("evt_123")).to eq("evt_123")
    end

    it "truncates hyphenated references showing first two segments" do
      expect(helper.shorten_reference_string("fake-0b80264d-1db5-4998-ad76-f7065070498d")).to eq("fake-0b80264d…")
      expect(helper.shorten_reference_string("0b80264d-1db5-4998-ad76-f7065070498d")).to eq("0b80264d-1db5…")
    end

    it "truncates long underscore strings" do
      expect(helper.shorten_reference_string("evt_4d3f3297a1b2c3d4e5f6")).to eq("evt_4d3f3297…")
    end
  end

  describe "#render_short_reference" do
    it "renders a dash for blank value" do
      expect(helper.render_short_reference(nil)).to include("—")
    end

    it "renders truncated code with tooltip and clipboard button" do
      html = helper.render_short_reference("fake-0b80264d-1db5-4998-ad76-f7065070498d")
      expect(html).to include("fake-0b80264d…")
      expect(html).to include("title=\"fake-0b80264d-1db5-4998-ad76-f7065070498d\"")
      expect(html).to include("data-action=\"click-&gt;clipboard-copy#copy\"")
      expect(html).to include("data-copy-value=\"fake-0b80264d-1db5-4998-ad76-f7065070498d\"")
    end
  end
end
