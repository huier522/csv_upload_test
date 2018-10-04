class Report < ApplicationRecord

  # Generate a CSV File of All Report Records
  def self.to_csv(fields = column_names, options={})
    CSV.generate(options) do |csv|
      csv << fields
      all.each do |report|
        csv << report.attributes.values_at(*fields)
      end
    end
  end

  # Import CSV, Find or Create Report by its phone number
  # Update the record
  def self.import(file)
    spreadsheet = Roo::Spreadsheet.open(file.path)
    header = spreadsheet.row(1)
    # 以 model命名的欄位 存放到 header2 對應取代原資料的中文 header
    # 就可以省略掉 report.phone_num = row["門號"]等程式碼
    header2 = ["phone_num", "rp_offer", "expiration_date", 
      "trigger_date", "init_date", "init_ivr_code"]
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header2, spreadsheet.row(i)].transpose]
      report = find_by(phone_num: row["phone_num"]) || new
      report.attributes = row
      # report.phone_num = row["門號"]
      # report.rp_offer = row["RP Offer"]
      # report.expiration_date = row["上網期限到期日"]
      # report.trigger_date = row["落地觸發日"]
      # report.init_date = row["啟用日"]
      # report.init_ivr_code = row["啟用IVR CODE"]
      report.save!
    end
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

end
