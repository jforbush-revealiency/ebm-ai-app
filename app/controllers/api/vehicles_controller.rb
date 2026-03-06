module Api
  class VehiclesController < BaseController
    def index
      vehicles = Vehicle.all.map do |v|
        {
          id: v.id,
          code: v.code,
          name: v.name,
          emission_test_count: v.valid_emission_tests.count,
          last_test_at: v.valid_emission_tests.order(:recorded_at).last&.recorded_at
        }
      end
      render json: vehicles
    end

    def emission_tests
      vehicle = Vehicle.find_by(code: params[:id]) || Vehicle.find(params[:id])
      tests = vehicle.valid_emission_tests.order(:recorded_at).map do |t|
        {
          id: t.id,
          recorded_at: t.recorded_at,
          avg_nox_ppm: t.avg_nox_ppm.round(2),
          avg_co2_percent: t.avg_co2_percent.round(2),
          avg_rpm: t.avg_rpm.round(0),
          avg_load_percent: t.avg_load_percent.round(1)
        }
      end
      render json: { vehicle: vehicle.code, tests: tests }
    rescue ActiveRecord::RecordNotFound
      render_error("Vehicle not found", :not_found)
    end

    def daily_reports
      vehicle = Vehicle.find_by(code: params[:id]) || Vehicle.find(params[:id])
      reports = Input.where(vehicle: vehicle, auto_generated: true)
                     .order(:created_at)
                     .map do |r|
        {
          id: r.id,
          date: r.created_at.to_date,
          avg_nox_ppm: r.avg_nox_ppm&.round(2),
          avg_co2_percent: r.avg_co2_percent&.round(2),
          avg_rpm: r.avg_rpm&.round(0),
          engine_hours: r.engine_hours
        }
      end
      render json: { vehicle: vehicle.code, reports: reports }
    rescue ActiveRecord::RecordNotFound
      render_error("Vehicle not found", :not_found)
    end
  end
end