class Secure::Api::ApiController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  # This is also in the SessionsController
  after_action :set_csrf_cookie_for_ng

  rescue_from CanCan::AccessDenied do |exception|
    render json: { error: "You don't have permissions to access this resource." }, status: :unauthorized
  end
  
  private

  # This is also in the SessionsController
  def set_csrf_cookie_for_ng
    cookies['XSRF-TOKEN'] = form_authenticity_token if protect_against_forgery?
  end

  def verified_request?
    super || valid_authenticity_token?(session, request.headers['X-XSRF-TOKEN'])
  end
end
