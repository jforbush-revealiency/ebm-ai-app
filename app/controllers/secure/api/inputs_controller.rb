class Secure::Api::InputsController < Secure::Api::ApiController
  respond_to :json

  load_and_authorize_resource

  def index
    unless params["company_id"].blank?
      data = Input.accessible_by(current_ability).joins(location: :company, vehicle: [engine_config: [engine: :manufacturer]]).
        where("company_id = ?", params["company_id"])
    else
      data = Input.accessible_by(current_ability).
        joins(location: :company, vehicle: [engine_config: [engine: :manufacturer]]).all
    end
    unless params["search"].blank?
      search = params["search"]
      data = data.where(["inputs.id = ? or vehicle_code like ? or companies.code like ? or 
                         location_code like ? or engines.code like ? or manufacturers.code like ?", 
                         search, "#{search}%", "#{search}%", "#{search}%", "#{search}%", "#{search}%"])
    end
    total_records = data.count

    limit = params["limit"] || 10
    offset = params["offset"] || 0

    data = data.select(:id, :output_id, :vehicle_code, :location_code, :location_id, :vehicle_id, :submitted).order("location_code, id").offset(offset).limit(limit)

    if current_user.role != 'site_admin'
      data = data.where("inputs.id < 0")
    end

    render json: {total_records: total_records, data: data}
  end

  def show
    data = Input.accessible_by(current_ability).find(params[:id]) 

    render json: data
  end

  def create
    data = Input.new(data_params)
    location = Location.accessible_by(current_ability).find(data.location_id)

    if data.commit(current_user, location)
      ProcessInputsJob.perform_later data
      render json: data, status: :created
    else
      render json: data.errors, status: :unprocessable_entity
    end
  end

  def update
    data = Input.find(params[:id])
    location = Location.accessible_by(current_ability).find(data.location_id)

    if data.update(data_params) && data.commit(current_user, location)
      ProcessInputsJob.perform_later data
      render json: data
    else
      render json: data.errors, status: :unprocessable_entity
    end
  end

  def destroy
    data = Input.find(params[:id])
    if data.destroy
      head :no_content
    else
      render json: data.errors, status: :unprocessable_entity
    end
  end

  def export
    Time.use_zone("Mountain Time (US & Canada)") do
      start_date = Time.zone.parse(params[:start_date]).beginning_of_day
      end_date = Time.zone.parse(params[:end_date]).end_of_day

      company_id = params[:company_id]

      inputs = Input.accessible_by(current_ability).joins(location: :company, vehicle: [engine_config: [engine: :manufacturer]]).
        where(submitted: start_date..end_date)
      unless company_id.nil?
        inputs = inputs.where("companies.id": company_id)
      end
      inputs = inputs.order("companies.code, locations.code, inputs.submitted")

      current_time = Time.zone.now.strftime("%Y%m%d-%H%M%S")
      respond_to do |format|
        format.csv {send_data Input.to_csv(inputs), filename: "export-#{current_time}.csv"}
      end
    end
  end

  private
  # Never trust parameters from the scary internet, only allow the white list through.
  def data_params
    params.require(:data).permit(attributes: [:id, :location_id, :vehicle_id, 
                                              :engine_hours, :engine_rpm, :alternator_rpm, 
                                              :engine_hp, :alternator_hp, 
                                              :has_engine_codes, :has_latest_configuration_file,
                                              :left_bank_co2_percent, :left_bank_co, :left_bank_nox,
                                              :right_bank_co2_percent, :right_bank_co, :right_bank_nox ])
  end
  
end
