class ApplicationController < ActionController::Base

  # Used to prevent a users using the back button after logging out to access cached web pages.
  # Not working with Internet Explorer 11 for some reason
  before_filter :set_no_cache

  def set_no_cache
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "-1"
  end

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
end
