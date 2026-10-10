require "uri"

module Parsers
  class YoutubeUrlParser
    HOSTS = %w[youtube.com www.youtube.com m.youtube.com youtu.be www.youtu.be].freeze

    def self.video_id(url)
      uri = parse(url)
      return unless uri&.host.present? && HOSTS.include?(uri.host.downcase)

      case uri.host.downcase
      when "youtu.be", "www.youtu.be"
        path_segments(uri.path).first
      else
        query_video_id(uri) || embed_path_video_id(uri.path) || shorts_path_video_id(uri.path)
      end
    end

    def self.embed_url(url)
      (video_id = self.video_id(url)).present? ? "https://www.youtube-nocookie.com/embed/#{video_id}" : nil
    end

    def self.thumbnail_url(url)
      (video_id = self.video_id(url)).present? ? "https://img.youtube.com/vi/#{video_id}/hqdefault.jpg" : nil
    end

    def self.valid?(url)
      video_id(url).present?
    end

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

    def self.query_video_id(uri)
      params = URI.decode_www_form(uri.query.to_s).to_h
      params["v"].presence
    end
    private_class_method :query_video_id

    def self.embed_path_video_id(path)
      segments = path_segments(path)
      return if segments.first != "embed"

      segments.second
    end
    private_class_method :embed_path_video_id

    def self.shorts_path_video_id(path)
      segments = path_segments(path)
      return if segments.first != "shorts"

      segments.second
    end
    private_class_method :shorts_path_video_id

    def self.path_segments(path)
      path.to_s.split("/").reject(&:blank?)
    end
    private_class_method :path_segments
  end
end
