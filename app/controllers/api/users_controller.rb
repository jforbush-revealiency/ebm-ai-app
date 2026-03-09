module Api
  class UsersController < ApplicationController
    def index
      render json: User.includes(:company, :location).all.order(:email).as_json(include: { company: { only: [:id, :description, :code] }, location: { only: [:id, :description, :code] } })
    end

    def create
      user = User.new(params.require(:user).permit!)
      if user.save
        render json: user.as_json, status: :created
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      user = User.find(params[:id])
      if user.update(params.require(:user).permit!)
        render json: user.as_json
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end
end
