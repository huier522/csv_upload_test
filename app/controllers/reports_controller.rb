class ReportsController < ApplicationController

  before_action :set_report, only: [:index, :import]

  def index
    respond_to do |format|
      format.html
      format.csv { send_data @reports.to_csv(
        ['phone_num', 'rp_offer', 'expiration_date', 'trigger_date', 
        'init_date', 'init_ivr_code']
      )}
    end
  end

  def show
    redirect_to root_path
  end

  def import
    if params[:file] == nil
      flash[:alert] = "請匯入檔案！"
      redirect_to root_path
    else
      if Report.check_header_name(params[:file])
        @results = Report.import(params[:file])
        success_count = Report.all.size
        if @results[:status] == "failure"
          fail_count = @results[:error_reports].size
          flash[:alert] = "上傳資料不完整，有#{success_count}筆上傳成功、#{fail_count}筆上傳失敗"
          render :index
        else
          redirect_to root_path
          flash[:notice] = "檔案匯入成功，共有#{success_count}筆上傳"
        end
      else
        flash[:alert] = "欄位名稱與資料表不符合！"
        redirect_to root_path
      end
    end
  end

  private

  def set_report
    @reports = Report.page(params[:page]).per(50)
  end

  def report_params
    params.require(:report).permit(:phone_num, :rp_offer, :expiration_date, :trigger_date, 
      :init_date, :init_ivr_code)
  end

end
