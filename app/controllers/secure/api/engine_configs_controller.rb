class Secure::Api::EngineConfigsController < Secure::Api::ApiController
  respond_to :json

  load_and_authorize_resource

  def index
    data = EngineConfig.includes(engine: :manufacturer).all.order("code")
    render json: data
  end

  def show
    data = EngineConfig.find(params[:id]) 
    render json: data
  end

  def create
    data = EngineConfig.new(data_params)
    if data.save
      render json: data, status: :created
    else
      render json: data.errors, status: :unprocessable_entity
    end
  end

  def update
    data = EngineConfig.find(params[:id])
    if data.update(data_params)
      render json: data
    else
      render json: data.errors, status: :unprocessable_entity
    end
  end

  def destroy
    data = EngineConfig.find(params[:id])
    if data.destroy
      head :no_content
    else
      render json: data.errors, status: :unprocessable_entity
    end
  end

  private
  # Never trust parameters from the scary internet, only allow the white list through.
  def data_params
    params.require(:data).permit(:id, attributes: [:code, :description, :co2_percent, 
                                              :co, :nox, :is_real_values, :engine_id, 
                                              :co2_plus_o2_percent, :test_percent_load, 
                                              :test_rpm, :test_boost_psi, :test_fuel_gallons_per_hour, 
                                              :rated_rpm, :rated_hp])
  end
  
end
