class Secure::Api::CompaniesController < Secure::Api::ApiController
  respond_to :json

  load_and_authorize_resource

  def index
    data = Company.all.order("code")
    render json: data
  end

  def show
    data = Company.find(params[:id]) 
    render json: data
  end

  def create
    data = Company.new(data_params)
    if data.save       
      render json: data, status: :created
    else
      render json: data.errors, status: :unprocessable_entity
    end
  end

  def update
    data = Company.find(params[:id])
    if data.update(data_params)
      render json: data
    else
      render json: data.errors, status: :unprocessable_entity
    end
  end

  def destroy
    data = Company.find(params[:id])
    if data.destroy
      head :no_content
    else
      render json: data.errors, status: :unprocessable_entity
    end
  end

  private
  # Never trust parameters from the scary internet, only allow the white list through.
  def data_params
    params.require(:data).permit(:id, attributes: [:code, :description, :average_diesel_fuel, :location_id, location_attributes: [
                                              :code, :description, :attainment]])
  end
end
