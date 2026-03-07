class Api::VehiclesController < ApplicationController
  def index
    vehicles = Vehicle.all.order(:description)
    render json: vehicles.map { |v|
      {
        id: v.id,
        code: v.code,
        description: v.description,
        emission_test_count: Input.where(vehicle_id: v.id).count,
        last_diagnostic_status: v.last_diagnostic_status,
        last_test_date: v.last_test_date,
        company: v.company&.name,
        location: v.location&.description
      }
    }
  end

  def show
    vehicle = Vehicle.find(params[:id])
    render json: {
      id: vehicle.id,
      code: vehicle.code,
      description: vehicle.description,
      last_diagnostic_status: vehicle.last_diagnostic_status,
      last_test_date: vehicle.last_test_date,
      company: vehicle.company&.name,
      inputs: Input.where(vehicle_id: vehicle.id).order(submitted: :desc).limit(10).map { |i|
        { id: i.id, submitted: i.submitted, engine_hours: i.engine_hours }
      }
    }
  end
end
