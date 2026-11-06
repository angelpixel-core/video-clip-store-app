require "rails_helper"
require Rails.root.join("lib/parsers/youtube_url_parser")

RSpec.describe Parsers::YoutubeUrlParser do
  it "extracts a video id from a standard watch url" do
    url = "https://www.youtube.com/watch?v=dQw4w9WgXcQ"

    expect(described_class.video_id(url)).to eq("dQw4w9WgXcQ")
    expect(described_class.embed_url(url)).to eq("https://www.youtube-nocookie.com/embed/dQw4w9WgXcQ")
    expect(described_class.thumbnail_url(url)).to eq("https://img.youtube.com/vi/dQw4w9WgXcQ/hqdefault.jpg")
  end

  it "extracts a video id from a short url" do
    url = "https://youtu.be/dQw4w9WgXcQ"

    expect(described_class.video_id(url)).to eq("dQw4w9WgXcQ")
  end

  it "extracts a video id from shorts and rejects non youtube urls" do
    shorts_url = "https://www.youtube.com/shorts/dQw4w9WgXcQ"

    expect(described_class.video_id(shorts_url)).to eq("dQw4w9WgXcQ")
    expect(described_class.valid?(shorts_url)).to be(true)
    expect(described_class.video_id("https://example.com/video")).to be_nil
    expect(described_class.valid?("https://example.com/video")).to be(false)
  end
end
