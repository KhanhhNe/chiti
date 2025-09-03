class ApplicationController < ActionController::Base
  include Authentication
  include PreprocessParams

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: { ie: false }
end
