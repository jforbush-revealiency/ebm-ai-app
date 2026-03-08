module Secure
  module Api
    class CompaniesController < ApplicationController
      before_action :authenticate_user!
      before_action :require_admin

      def index
        companies = Company.includes(:locations).all.order(:name)
        render json: companies.map { |company|
          {
            id: company.id,
            code: company.code,
            description: company.description,
            active: company.active,
            locations: company.locations.order(:name).map { |loc|
              {
                id: loc.id,
                code: loc.code,
                description: loc.description,
                active: loc.active,
                company_id: loc.company_id
              }
            }
          }
        }
      end

      def update
        company = Company.find(params[:id])
        if company.update(company_params)
          render json: {
            id: company.id,
            code: company.code,
            description: company.description,
            active: company.active
          }
        else
          render json: { errors: company.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def company_params
        params.require(:company).permit(:description, :active)
      end
    end
  end
end
