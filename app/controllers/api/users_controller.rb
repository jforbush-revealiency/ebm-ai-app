module Api
  class UsersController < ApplicationController
    def index
      users = User.includes(:company).all.order(:email)
      render json: users.map { |u|
        u.as_json.merge(
          company_name: u.company&.description || u.company&.code
        )
      }
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
