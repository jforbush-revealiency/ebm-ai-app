class Secure::Api::ValidEmissionTestsController < Secure::Api::ApiController
  def index
    #start_date = Date.new(2018, 01, 01)
    #end_date = Date.new(2018, 01, 31)
    start_date = params[:start_date].to_date
    end_date = params[:end_date].to_date
    ValidEmissionTest.analyze_emissions_data(start_date, end_date)
    #vehicle = Vehicle.where(folder_code: "redmond_ht4").first
    #ValidEmissionTest.analyze_emissions_by_date(vehicle, Date.new(2018,01,31), Date.new(2018,01,31).strftime("%Y%m%d%H%M%S"))
  end
end
