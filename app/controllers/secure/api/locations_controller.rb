class Secure::Api::LocationsController < Secure::Api::ApiController
  respond_to :json

  load_and_authorize_resource

  def index
    unless params["company_id"].blank?
      data = Location.accessible_by(current_ability).includes(:company).
        where("company_id = ?", params["company_id"]).order("companies.code, locations.code")
    else
      data = Location.accessible_by(current_ability).includes(:company).all.order("companies.code, locations.code")
    end
    render json: data
  end

  def show
    data = Location.accessible_by(current_ability).find(params[:id]) 
    render json: data
  end

  def create
    data = Location.new(data_params)
    if data.save       
      render json: data, status: :created
    else
      render json: data.errors, status: :unprocessable_entity
    end
  end

  def update
    data = Location.find(params[:id])
    if data.update(data_params)
      render json: data
    else
      render json: data.errors, status: :unprocessable_entity
    end
  end

  def destroy
    data = Location.find(params[:id])
    if data.destroy
      head :no_content
    else
      render json: data.errors, status: :unprocessable_entity
    end
  end

  private
  # Never trust parameters from the scary internet, only allow the white list through.
  def data_params
    params.require(:data).permit(attributes: [:code, :description, :company_id, :attainment])
  end
end
