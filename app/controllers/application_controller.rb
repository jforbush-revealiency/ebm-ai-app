class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  layout :layout

  private

  def layout
    is_a?(Devise::SessionsController) || is_a?(Devise::PasswordsController) ? 'public' : 'public'
  end

  def after_sign_in_path_for(resource)
    secure_root_path
  end

  def after_sign_out_path_for(resource)
    new_user_session_path
  end
end
