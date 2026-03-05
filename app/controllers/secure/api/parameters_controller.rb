class Secure::Api::ParametersController < Secure::Api::ApiController
  respond_to :json

  load_and_authorize_resource

  def index
    data = Parameter.all.order("code")
    render json: data
  end

  def show
    data = Parameter.find(params[:id]) 
    render json: data
  end

  def create
    data = Parameter.new(data_params)
    if data.save
      render json: data, status: :created
    else
      render json: data.errors, status: :unprocessable_entity
    end
  end

  def update
    data = Parameter.find(params[:id])
    if data.update(data_params)
      render json: data
    else
      render json: data.errors, status: :unprocessable_entity
    end
  end

  def destroy
    data = Parameter.find(params[:id])
    if data.destroy
      head :no_content
    else
      render json: data.errors, status: :unprocessable_entity
    end
  end

  private
  # Never trust parameters from the scary internet, only allow the white list through.
  def data_params
    params.require(:data).permit(attributes: [:code, :description, :value])
  end
  
end
