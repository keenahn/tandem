# http://stackoverflow.com/questions/21574900/interpolation-in-i18n-array/25484080#25484080
# Makes interpolation possible for arrays of values in I18n

I18n.backend.instance_eval do
  def interpolate(locale, string, values = {})
    if string.is_a?(::Array) && !values.empty?
      string.map { |el| super(locale, el, values) }
    else
      super
    end
  end
end
