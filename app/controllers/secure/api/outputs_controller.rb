class Secure::Api::OutputsController < Secure::Api::ApiController
  respond_to :json

  load_and_authorize_resource

  def index
    # This resource doesn't exist for anybody --- no matter who you are.
    render json: { error: "You don't have permissions to access this resource." }, status: :unauthorized
  end

  def show
    data = Output.accessible_by(current_ability).find(params[:id]) 

    render json: data
  end

  def create
    # This resource doesn't exist for anybody --- no matter who you are.
    render json: { error: "You don't have permissions to access this resource." }, status: :unauthorized
  end

  def update
    # This resource doesn't exist for anybody --- no matter who you are.
    render json: { error: "You don't have permissions to access this resource." }, status: :unauthorized
  end

  def destroy
    # This resource doesn't exist for anybody --- no matter who you are.
    render json: { error: "You don't have permissions to access this resource." }, status: :unauthorized
  end

  private
  # Never trust parameters from the scary internet, only allow the white list through.
  def data_params
  end
end
