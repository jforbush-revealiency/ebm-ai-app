module Api
  class BaseController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :set_default_format
    private
    def set_default_format
      request.format = :json
    end
    def render_error(message, status = :bad_request)
      render json: { error: message }, status: status
    end
  end
end
