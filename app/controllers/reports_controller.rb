class ReportsController < ApplicationController

  def index
    @reports = Report.all
    respond_to do |format|
      format.html
      format.csv { send_data @reports.to_csv(
        ['phone_num', 'rp_offer', 'expiration_date', 'trigger_date', 
        'init_date', 'init_ivr_code']
      )}
    end
  end

  def import
    Report.import(params[:file])
    redirect_to root_path, notice: 'CSV uploaded successfully'
  end

end
