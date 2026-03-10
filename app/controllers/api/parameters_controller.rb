module Api
  class ParametersController < ApplicationController
    skip_before_action :verify_authenticity_token

    def index
      parameters = Parameter.all.order(:id)
      render json: parameters
    end

    def show
      parameter = Parameter.find(params[:id])
      render json: parameter
    end

    def update
      parameter = Parameter.find(params[:id])
      if parameter.update(parameter_params)
        render json: parameter
      else
        render json: { errors: parameter.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def parameter_params
      params.require(:parameter).permit(:value, :name, :code, :description, :unit)
    end
  end
end
