module Api
  class LocationsController < ApplicationController
    def index
      render json: Location.includes(:company).all.order(:code).as_json
    end

    def create
      location = Location.new(params.require(:location).permit!)
      if location.save
        render json: location.as_json, status: :created
      else
        render json: { errors: location.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      Rails.logger.info "=== LOCATION UPDATE === params: #{params.inspect}"
      location = Location.find(params[:id])
      location_params = params.require(:location).permit!
      Rails.logger.info "=== LOCATION UPDATE === location_params: #{location_params.inspect}"
      if location.update(location_params)
        render json: location.as_json
      else
        Rails.logger.info "=== LOCATION UPDATE === errors: #{location.errors.full_messages.inspect}"
        render json: { errors: location.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end
end
