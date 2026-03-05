class Secure::Api::VehiclesController < Secure::Api::ApiController
  respond_to :json

  load_and_authorize_resource

  def index
    if params[:company_id].blank?
      if params[:location_id].blank?
        data = Vehicle.accessible_by(current_ability).includes(:location, engine_config: [engine: [:manufacturer]]).all.order("code")
      else
        data = Vehicle.accessible_by(current_ability).joins(:location, engine_config: [engine: [:manufacturer]]).
          where(location_id: params[:location_id]).order("code")
      end
    else
      data = Vehicle.accessible_by(current_ability).joins(:location, engine_config: [engine: [:manufacturer]]).
        where(locations: {company_id: params[:company_id]}).order("code")
    end
    render json: data
  end

  def show
    data = Vehicle.accessible_by(current_ability).find(params[:id]) 
    render json: data
  end

  def create
    data = Vehicle.new(data_params)
    if data.save
      render json: data, status: :created
    else
      render json: data.errors, status: :unprocessable_entity
    end
  end

  def update
    data = Vehicle.find(params[:id])
    if data.update(data_params)
      render json: data
    else
      render json: data.errors, status: :unprocessable_entity
    end
  end

  def destroy
    data = Vehicle.find(params[:id])
    if data.destroy
      head :no_content
    else
      render json: data.errors, status: :unprocessable_entity
    end
  end

  private
  # Never trust parameters from the scary internet, only allow the white list through.
  def data_params
    params.require(:data).permit(:id, attributes: [:id, :code, :description, :location_id, 
                                              :engine_config_id, :model_number, :serial_number, 
                                              :folder_code, :estimated_annual_vehicle_hours, 
                                              :telematic ])
  end
  
end
