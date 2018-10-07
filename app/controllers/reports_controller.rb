class ReportsController < ApplicationController

  def index
    @reports = Report.page(params[:page]).per(50)
    respond_to do |format|
      format.html
      format.csv { send_data @reports.to_csv(
        ['phone_num', 'rp_offer', 'expiration_date', 'trigger_date', 
        'init_date', 'init_ivr_code']
      )}
    end
  end

  def import
    if params[:file] == nil
      flash[:alert] = "Need to import file"
      redirect_to root_path
    else
      if Report.check_header_name(params[:file])
        Report.import(params[:file])
        redirect_to root_path
        flash[:notice] = "File importd successfully"
      else
        flash[:alert] = "檔案格式錯誤"
        redirect_to root_path
      end
    end
  end

end
