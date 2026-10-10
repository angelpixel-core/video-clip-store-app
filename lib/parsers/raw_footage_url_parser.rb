require "uri"

module Parsers
  class RawFootageUrlParser
    INSTAGRAM_HOSTS = %w[instagram.com www.instagram.com instagr.am www.instagr.am].freeze
    TWITCH_HOSTS = %w[twitch.tv www.twitch.tv player.twitch.tv].freeze
    VIMEO_HOSTS = %w[vimeo.com www.vimeo.com player.vimeo.com].freeze

    def self.metadata(url)
      youtube_metadata(url) || instagram_metadata(url) || tiktok_metadata(url) || twitch_metadata(url) || vimeo_metadata(url)
    end

    def self.youtube_metadata(url)
      video_id = Parsers::YoutubeUrlParser.video_id(url)
      return unless video_id

      {
        "provider" => "youtube",
        "video_id" => video_id,
        "aspect_ratio" => youtube_aspect_ratio(url),
        "embed_url" => "https://www.youtube-nocookie.com/embed/#{video_id}",
        "thumbnail_url" => "https://img.youtube.com/vi/#{video_id}/hqdefault.jpg",
        "watch_url" => "https://www.youtube.com/watch?v=#{video_id}"
      }
    end

    def self.vimeo_metadata(url)
      video_id = vimeo_video_id(url)
      return unless video_id

      {
        "provider" => "vimeo",
        "video_id" => video_id,
        "aspect_ratio" => "16 / 9",
        "embed_url" => "https://player.vimeo.com/video/#{video_id}",
        "watch_url" => "https://vimeo.com/#{video_id}"
      }
    end

    def self.twitch_metadata(url)
      video_id = twitch_video_id(url)
      return unless video_id

      {
        "provider" => "twitch",
        "video_id" => video_id,
        "aspect_ratio" => "16 / 9",
        "embed_url" => "https://player.twitch.tv/?video=v#{video_id}&parent={parent}",
        "watch_url" => "https://www.twitch.tv/videos/#{video_id}"
      }
    end

    def self.instagram_metadata(url)
      post_id = instagram_post_id(url)
      return unless post_id

      {
        "provider" => "instagram",
        "video_id" => post_id,
        "aspect_ratio" => "4 / 5",
        "watch_url" => normalize(url)
      }
    end

    def self.tiktok_metadata(url)
      video_id = tiktok_video_id(url)
      return unless video_id

      {
        "provider" => "tiktok",
        "video_id" => video_id,
        "aspect_ratio" => "9 / 16",
        "watch_url" => normalize(url)
      }
    end

    def self.vimeo_video_id(url)
      uri = parse(url)
      return unless uri&.host.present? && VIMEO_HOSTS.include?(uri.host.downcase)

      segments = path_segments(uri.path)

      if uri.host.downcase == "player.vimeo.com"
        return segments.second if segments.first == "video"
      end

      segments.reverse.find { |segment| segment.match?(/\A\d+\z/) }
    end
    private_class_method :vimeo_video_id

    def self.instagram_post_id(url)
      uri = parse(url)
      return unless uri&.host.present? && INSTAGRAM_HOSTS.include?(uri.host.downcase)

      segments = path_segments(uri.path)
      return unless %w[p reel reels tv].include?(segments.first)

      segments.second
    end
    private_class_method :instagram_post_id

    def self.tiktok_video_id(url)
      uri = parse(url)
      return unless uri&.host.present? && %w[tiktok.com www.tiktok.com m.tiktok.com].include?(uri.host.downcase)

      segments = path_segments(uri.path)
      return segments.third if segments.first.start_with?("@") && segments.second == "video"

      segments.find { |segment| segment.match?(/\A\d+\z/) }
    end
    private_class_method :tiktok_video_id

    def self.twitch_video_id(url)
      uri = parse(url)
      return unless uri&.host.present? && TWITCH_HOSTS.include?(uri.host.downcase)

      segments = path_segments(uri.path)
      return segments.second if segments.first == "videos" && segments.second&.match?(/\A\d+\z/)
      return segments.second if segments.first == "video" && segments.second&.match?(/\A\d+\z/)

      segments.find { |segment| segment.match?(/\A\d+\z/) }
    end
    private_class_method :twitch_video_id

    def self.parse(url)
      normalized_url = normalize(url)
      URI.parse(normalized_url) if normalized_url.present?
    rescue URI::InvalidURIError
      nil
    end
    private_class_method :parse

    def self.normalize(url)
      value = url.to_s.strip
      return if value.blank?

      return value if value.match?(/\A[a-z][a-z0-9+.-]*:\/\//i)

      "https://#{value}"
    end
    private_class_method :normalize

    def self.path_segments(path)
      path.to_s.split("/").reject(&:blank?)
    end
    private_class_method :path_segments

    def self.youtube_aspect_ratio(url)
      uri = parse(url)
      return "16 / 9" unless uri&.host.present? && %w[youtube.com www.youtube.com m.youtube.com].include?(uri.host.downcase)

      segments = path_segments(uri.path)
      segments.first == "shorts" ? "9 / 16" : "16 / 9"
    end
    private_class_method :youtube_aspect_ratio
  end
end
