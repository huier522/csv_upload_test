class Report < ApplicationRecord

  validates_presence_of :phone_num, :rp_offer, :expiration_date, 
      :trigger_date, :init_date, :init_ivr_code

  validates_format_of :phone_num, :with => /\A\d{9}\Z/
  validates_format_of :expiration_date, :trigger_date, :init_date, 
  :with => /\A[((20)?[0-9]{2}[-\/.](0?[1-9]|1[012])[-\/.](0?[1-9]|[12][0-9]|3[01]))]*\Z/

  # Generate a CSV File of All Report Records
  def self.to_csv(fields = column_names, options={})
    CSV.generate(options) do |csv|
      csv << fields
      all.each do |report|
        csv << report.attributes.values_at(*fields)
      end
    end
  end

  # Import CSV & Excel, Find or Create Report by its phone number
  # Update the record
  def self.import(file)
    spreadsheet = Roo::Spreadsheet.open(file.path)
    ary = Array.new
    result = {status: "success", error_reports: ary}
    # header = spreadsheet.row(1)
    # 以 model命名的欄位 存放到 header2 對應取代原資料的中文 header 就可以省略掉 report.phone_num = row["門號"]等程式碼
    header = ["phone_num", "rp_offer", "expiration_date", 
      "trigger_date", "init_date", "init_ivr_code"]
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      report = find_by(phone_num: row["phone_num"]) || new
      report.attributes = row
      if !report.save
        result[:status] = "failure"
        ary.push(report)
      end
    end
    return result
  end

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
    when ".csv" then 
      Roo::CSV.new(file.path, nil, :ignore)
    when ".xls" then 
      Roo::Excel.new(file.path, nil, :ignore)
    when ".xlsx" then 
      Roo::Excelx.new(file.path, nil, :ignore)
    else 
      raise "Unknow file type: #{file.original_filename}"
    end  
  end

  def self.check_header_name(file)
    spreadsheet = Roo::Spreadsheet.open(file.path)
    header1 = spreadsheet.row(1).to_ary
    header2 = ["門號", "RP Offer", "上網期限到期日", "落地觸發日", "啟用日", "啟用IVR CODE"]
    (0...header1.size).each do |h|
      if header1[h] != header2[h]
        return false
      end
    end
    return true
  end

end
