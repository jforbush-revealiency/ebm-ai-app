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
      location = Location.find(params[:id])
      if location.update(params.require(:location).permit!)
        render json: location.as_json
      else
        render json: { errors: location.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end
end
