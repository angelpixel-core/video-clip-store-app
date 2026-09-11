class LocaleMiddleware
  LOCALE_ENV_KEY = "video_clip_store_app.locale"
  SUPPORTED_LOCALE_PATTERN = /\A[a-z]{2}(?:-[a-z]{2})?\z/i

  def initialize(app)
    @app = app
  end

  def call(env)
    request = ActionDispatch::Request.new(env)
    locale = resolve_locale(request)
    env[LOCALE_ENV_KEY] = locale.to_s

    I18n.with_locale(locale) { @app.call(env) }
  end

  private

  def resolve_locale(request)
    requested_locale = requested_locale_from_path(request.path_info)

    return I18n.default_locale if requested_locale.blank?
    return requested_locale.to_sym if I18n.available_locales.include?(requested_locale.to_sym)

    Rails.logger.warn("Unsupported locale '#{requested_locale}' for #{request.fullpath}; falling back to #{I18n.default_locale}")
    I18n.default_locale
  end

  def requested_locale_from_path(path_info)
    first_segment = path_info.split("/").reject(&:blank?).first
    return unless first_segment&.match?(SUPPORTED_LOCALE_PATTERN)

    first_segment.downcase
  end
end
