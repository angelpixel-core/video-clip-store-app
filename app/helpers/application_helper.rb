module ApplicationHelper
  def money_to_currency(cents)
    number_to_currency(cents.to_i / 100.0)
  end

  def youtube_video_id(url)
    Parsers::YoutubeUrlParser.video_id(url)
  end

  def youtube_embed_url(url)
    Parsers::YoutubeUrlParser.embed_url(url)
  end

  def youtube_thumbnail_url(url)
    Parsers::YoutubeUrlParser.thumbnail_url(url)
  end

  def youtube_watch_url(url)
    video_id = youtube_video_id(url)
    video_id.present? ? "https://www.youtube.com/watch?v=#{video_id}" : url
  end

  def raw_footage_embed_script_tag(project)
    @raw_footage_embed_scripts_loaded ||= {}

    case project.raw_footage_provider
    when "instagram"
      return if @raw_footage_embed_scripts_loaded["instagram"]

      @raw_footage_embed_scripts_loaded["instagram"] = true
      tag.script("", src: "https://www.instagram.com/embed.js", async: true, defer: true)
    when "tiktok"
      return if @raw_footage_embed_scripts_loaded["tiktok"]

      @raw_footage_embed_scripts_loaded["tiktok"] = true
      tag.script("", src: "https://www.tiktok.com/embed.js", async: true, defer: true)
    end
  end
end
