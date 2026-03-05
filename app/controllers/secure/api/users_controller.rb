class Secure::Api::UsersController < Secure::Api::ApiController
  respond_to :json

  load_and_authorize_resource except: :current_change_password

  def index
    data = User.includes(location: [:company]).all.order("companies.code, locations.code, email")
    render json: data
  end

  def show
    data = User.find(params[:id]) 
    render json: data
  end

  def create
    data = User.new(data_params)
    if data.save
      render json: data, status: :created
    else
      render json: data.errors, status: :unprocessable_entity
    end
  end

  def update
    data = User.find(params[:id])
    if data.update(data_params)
      render json: data
    else
      render json: data.errors, status: :unprocessable_entity
    end
  end

  def destroy
    data = User.find(params[:id])
    if data.destroy
      head :no_content
    else
      render json: data.errors, status: :unprocessable_entity
    end
  end

  def current_change_password 
    current_user.password = params[:password]
    current_user.require_password_change = false
    if current_user.save
      render json: current_user, status: :created
    else
      render json: current_user.errors, status: :unprocessable_entity
    end
  end

  private
  # Never trust parameters from the scary internet, only allow the white list through.
  def data_params
    params.require(:data).permit(attributes: [:email, :first_name, :last_name, :location_id, 
                                              :role, :password, :is_active, :require_password_change])
  end
  
end
