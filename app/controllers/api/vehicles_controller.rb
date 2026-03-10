class Api::VehiclesController < ApplicationController
  def index
    vehicles = Vehicle.all.order(:description)
    render json: vehicles.map { |v|
      {
        id: v.id,
        code: v.code,
        description: v.description,
        emission_test_count: Input.where(vehicle_id: v.id).count,
        last_diagnostic_status: v.try(:last_diagnostic_status),
        last_test_date: v.try(:last_test_date),
        company: v.try(:company_code),
        location: v.try(:location_code),
        inputs: Input.where(vehicle_id: v.id).order(submitted: :desc).pluck(:id)
      }
    }
  end

  def show
    vehicle = Vehicle.find(params[:id])
    render json: {
      id: vehicle.id,
      code: vehicle.code,
      description: vehicle.description,
      last_diagnostic_status: vehicle.try(:last_diagnostic_status),
      last_test_date: vehicle.try(:last_test_date),
      company: vehicle.try(:company_code),
      location: vehicle.try(:location_code),
      inputs: Input.where(vehicle_id: vehicle.id).order(submitted: :desc).limit(50).map { |i|
        {
          id:                    i.id,
          submitted:             i.submitted&.strftime("%Y-%m-%d"),
          engine_hours:          i.engine_hours,
          engine_rpm:            i.engine_rpm,
          test_type:             i.test_type,
          overall_status:        i.try(:last_diagnostic_status),
          last_diagnostic_status: i.try(:last_diagnostic_status),
          left_bank_co2_percent: i.left_bank_co2_percent,
          right_bank_co2_percent: i.right_bank_co2_percent,
          left_bank_co:          i.left_bank_co,
          right_bank_co:         i.right_bank_co,
          left_bank_nox:         i.left_bank_nox,
          right_bank_nox:        i.right_bank_nox
        }
      }
    }
  end

  def update
    vehicle = Vehicle.find(params[:id])
    attrs = params[:vehicle] || params[:attributes] || {}
    allowed = attrs.permit(:description, :model_number, :location_id, :company_id,
                           :code, :serial_number, :engine_config_id)
    if vehicle.update(allowed)
      render json: { id: vehicle.id, description: vehicle.description, code: vehicle.code }
    else
      render json: { errors: vehicle.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
