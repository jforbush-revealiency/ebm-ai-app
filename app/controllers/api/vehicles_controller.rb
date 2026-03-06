module Api
  class VehiclesController < BaseController
    def index
      vehicles = Vehicle.all.map do |v|
        test_count = ValidEmissionTest.joins(:vehicle_stat)
                                      .where(vehicle_stats: { vehicle_id: v.id })
                                      .count
        {
          id: v.id,
          code: v.code,
          name: v.name,
          emission_test_count: test_count
        }
      end
      render json: vehicles
    end

    def emission_tests
      vehicle = Vehicle.find_by(code: params[:id]) || Vehicle.find(params[:id])
      tests = ValidEmissionTest.joins(:vehicle_stat)
                               .where(vehicle_stats: { vehicle_id: vehicle.id })
                               .order(:datetime)
                               .map do |t|
        {
          id: t.id,
          recorded_at: t.datetime,
          nox_ppm: t.nox_ppm&.round(2),
          co2_percent: t.co2_percent&.round(2),
          rpm: t.rpm,
          percent_load: t.percent_load
        }
      end
      render json: { vehicle: vehicle.code, tests: tests }
    rescue ActiveRecord::RecordNotFound
      render_error("Vehicle not found", :not_found)
    end

    def daily_reports
      vehicle = Vehicle.find_by(code: params[:id]) || Vehicle.find(params[:id])
      reports = Input.where(vehicle: vehicle, auto_generated: true)
                     .order(:submitted)
                     .map do |r|
        avg_nox = [r.left_bank_nox, r.right_bank_nox].compact
        avg_co2 = [r.left_bank_co2_percent, r.right_bank_co2_percent].compact
        {
          id: r.id,
          date: r.submitted&.to_date,
          avg_nox_ppm: avg_nox.any? ? (avg_nox.sum / avg_nox.size).round(2) : nil,
          avg_co2_percent: avg_co2.any? ? (avg_co2.sum / avg_co2.size).round(2) : nil,
          avg_rpm: r.engine_rpm&.round(0),
          engine_hours: r.engine_hours
        }
      end
      render json: { vehicle: vehicle.code, reports: reports }
    rescue ActiveRecord::RecordNotFound
      render_error("Vehicle not found", :not_found)
    end
  end
end