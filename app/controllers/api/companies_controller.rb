module Api
  class CompaniesController < ApplicationController
    def index
      render json: Company.includes(:locations).all.order(:code).as_json(include: :locations)
    end

    def create
      company = Company.new(params.require(:company).permit!)
      if company.save
        render json: company.as_json(include: :locations), status: :created
      else
        render json: { errors: company.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      company = Company.find(params[:id])
      if company.update(params.require(:company).permit!)
        render json: company.as_json(include: :locations)
      else
        render json: { errors: company.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      company = Company.find(params[:id])
      if company.locations.any?
        render json: { errors: ["Cannot delete a company that has sites. Remove all sites first."] }, status: :unprocessable_entity
      else
        company.destroy
        render json: { success: true }
      end
    end
  end
end
