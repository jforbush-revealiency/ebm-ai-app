module Api
  class CompaniesController < ApplicationController
    def index
      companies = Company.includes(:locations).all.order(:code)
      render json: companies.map { |c|
        c.as_json.merge(locations: c.locations.as_json)
      }
    end

    def update
      company = Company.find(params[:id])
      if company.update(company_params)
        render json: company.as_json
      else
        render json: { errors: company.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def company_params
      params.require(:company).permit!
    end
  end
end
