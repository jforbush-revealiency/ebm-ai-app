module Secure
  module Api
    class LocationsController < ApplicationController
      before_action :authenticate_user!
      before_action :require_admin

      def index
        locations = Location.includes(:company).all.order(:name)
        render json: locations.map { |loc|
          {
            id: loc.id,
            code: loc.code,
            description: loc.description,
            active: loc.active,
            company_id: loc.company_id,
            company_name: loc.company&.description
          }
        }
      end

      def create
        location = Location.new(location_params)
        if location.save
          render json: {
            id: location.id,
            code: location.code,
            description: location.description,
            active: location.active,
            company_id: location.company_id
          }, status: :created
        else
          render json: { errors: location.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        location = Location.find(params[:id])
        if location.update(location_params)
          render json: {
            id: location.id,
            code: location.code,
            description: location.description,
            active: location.active,
            company_id: location.company_id
          }
        else
          render json: { errors: location.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        location = Location.find(params[:id])
        location.destroy
        render json: { message: "Location deleted" }
      end

      private

      def location_params
        params.require(:location).permit(:code, :description, :active, :company_id)
      end
    end
  end
end
