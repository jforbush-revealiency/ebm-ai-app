#class Secure::Api::VehicleStatsController < Secure::Api::ApiController
class Secure::Api::VehicleStatsController < ApplicationController
  respond_to :json
  skip_before_action :verify_authenticity_token, only: [:import_stat_file]

  load_and_authorize_resource except: :import_stat_file

  def import_stat_all_files
    #after_datetime = params[:after_datetime].in_time_zone(VehicleStat.import_time_zone)
    after_filename = params[:after_filename]
    VehicleStat.import_stat_files("ebmpros-ftp", "redmond_ht4", after_filename)
  end

  # Test this my loading postman
  # Select POST
  # form-data: bucket = ebmpros-ftp
  # form-data: file_key = redmond_ht4/logs/data/18032719.csv
  def import_stat_file 
    bucket = params[:bucket]
    file_key = params[:file_key]
    import_log = VehicleStat.import_stat_file(bucket, file_key)
    render json: import_log 
  end

  def export
    current_time = Time.zone.now.strftime("%Y%m%d-%H%M%S")
    Time.use_zone(VehicleStat.import_time_zone) do
      current_time = Time.zone.now.strftime("%Y%m%d-%H%M%S")
    end

    start_date = Time.zone.parse(params[:start_date]).beginning_of_day
    end_date = Time.zone.parse(params[:end_date]).end_of_day

    vehicle_stats = VehicleStat.where(datetime: start_date..end_date).order("code, datetime")
    respond_to do |format|
      format.csv {send_data VehicleStat.to_csv(vehicle_stats), filename: "export-vehicle-stats-#{current_time}.csv"}
    end
  end

end
