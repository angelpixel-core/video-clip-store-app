require "rails_helper"
require Rails.root.join("lib/parsers/raw_footage_url_parser")

RSpec.describe Parsers::RawFootageUrlParser do
  it "builds youtube metadata" do
    metadata = described_class.metadata("https://www.youtube.com/watch?v=dQw4w9WgXcQ")

    expect(metadata).to include(
      "provider" => "youtube",
      "video_id" => "dQw4w9WgXcQ",
      "aspect_ratio" => "16 / 9",
      "embed_url" => "https://www.youtube-nocookie.com/embed/dQw4w9WgXcQ",
      "thumbnail_url" => "https://img.youtube.com/vi/dQw4w9WgXcQ/hqdefault.jpg"
    )
  end

  it "marks youtube shorts as portrait" do
    metadata = described_class.metadata("https://www.youtube.com/shorts/hkPNAAZJwJs")

    expect(metadata).to include(
      "provider" => "youtube",
      "video_id" => "hkPNAAZJwJs",
      "aspect_ratio" => "9 / 16"
    )
  end

  it "builds twitch metadata" do
    metadata = described_class.metadata("https://www.twitch.tv/videos/2820449804")

    expect(metadata).to include(
      "provider" => "twitch",
      "video_id" => "2820449804",
      "aspect_ratio" => "16 / 9",
      "embed_url" => "https://player.twitch.tv/?video=v2820449804&parent={parent}",
      "watch_url" => "https://www.twitch.tv/videos/2820449804"
    )
  end

  it "builds instagram metadata" do
    metadata = described_class.metadata("https://www.instagram.com/p/DbBvSsRtfuB")

    expect(metadata).to include(
      "provider" => "instagram",
      "video_id" => "DbBvSsRtfuB",
      "aspect_ratio" => "4 / 5",
      "watch_url" => "https://www.instagram.com/p/DbBvSsRtfuB"
    )
  end

  it "builds tiktok metadata" do
    metadata = described_class.metadata("https://www.tiktok.com/@demmy_061/video/7638191588631514376")

    expect(metadata).to include(
      "provider" => "tiktok",
      "video_id" => "7638191588631514376",
      "aspect_ratio" => "9 / 16",
      "watch_url" => "https://www.tiktok.com/@demmy_061/video/7638191588631514376"
    )
  end

  it "builds vimeo metadata" do
    metadata = described_class.metadata("https://player.vimeo.com/video/123456789")

    expect(metadata).to include(
      "provider" => "vimeo",
      "video_id" => "123456789",
      "embed_url" => "https://player.vimeo.com/video/123456789"
    )
    expect(metadata["thumbnail_url"]).to be_nil
  end

  it "returns nil for unrecognized urls" do
    expect(described_class.metadata("https://example.com/video")).to be_nil
  end
end
