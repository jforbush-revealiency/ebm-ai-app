class Secure::Api::EnginesController < Secure::Api::ApiController
  respond_to :json

  load_and_authorize_resource

  def index
    data = Engine.includes(:manufacturer, :drive_type).all.order("code")
    render json: data
  end

  def show
    data = Engine.find(params[:id]) 
    render json: data
  end

  def create
    data = Engine.new(data_params)
    if data.save
      render json: data, status: :created
    else
      render json: data.errors, status: :unprocessable_entity
    end
  end

  def update
    data = Engine.find(params[:id])
    if data.update(data_params)
      render json: data
    else
      render json: data.errors, status: :unprocessable_entity
    end
  end

  def destroy
    data = Engine.find(params[:id])
    if data.destroy
      head :no_content
    else
      render json: data.errors, status: :unprocessable_entity
    end
  end

  private
  # Never trust parameters from the scary internet, only allow the white list through.
  def data_params
    params.require(:data).permit(attributes: [:code, :description, :is_single_stack, :manufacturer_id, :drive_type_id])
  end
  
end
