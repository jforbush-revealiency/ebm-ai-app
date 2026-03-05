class Users::SessionsController < Devise::SessionsController
  respond_to :json

  # This is also in the ApiController
  after_action :set_csrf_cookie_for_ng

  def show_current_user
    reject_if_not_authorized_request!
    render status: 200,
      json: {
        success: true,
        info: "Current user",
        user: current_user
      }
  end
  def failure
    render status: 401,
      json: {
        success: false,
        info: "Unauthorized"
      }
  end

  private

  # This is also in the ApiController
  def set_csrf_cookie_for_ng
    cookies['XSRF-TOKEN'] = form_authenticity_token if protect_against_forgery?
  end

  # This is also in the SessionsController
  def verified_request?
    super || valid_authenticity_token?(session, request.headers['X-XSRF-TOKEN'])
  end

  def reject_if_not_authorized_request!
    warden.authenticate!(
      scope: resource_name,
      recall: "#{controller_path}#failure")
  end
end
