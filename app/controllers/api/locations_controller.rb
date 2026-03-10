module Api
  class LocationsController < ApplicationController
    def index
      render json: Location.includes(:company).all.order(:code).as_json
    end

    def show
      location = Location.find(params[:id])
      render json: location.as_json
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
      location = Location.find(params[:id])
      incoming = params.require(:location).permit!
      # Preserve the existing code if the update payload doesn't include one.
      # The Location model validates code presence/uniqueness — omitting it causes 422.
      merged_params = { code: location.code }.merge(incoming.to_h)
      if location.update(merged_params)
        render json: location.as_json
      else
        render json: { errors: location.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end
end
