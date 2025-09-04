class ApplicationController < ActionController::Base
  include Authentication
  include PreprocessParams

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: { ie: false }

  helper_method :format_monetary

  def format_monetary(amount)
    return '' if amount.nil?
    return '0' if amount <= 0

    decimal = amount % 1.0
    value = amount.floor
    result = ''

    while value > 0
      result = ',' + (value % 1000).to_s.rjust(3, '0') + result
      value = (value / 1000).floor
    end

    result = result.sub(/^[,0]+/, '')
    result += decimal.to_s.sub(/^0/, '') if decimal > 0
    result
  end
end
