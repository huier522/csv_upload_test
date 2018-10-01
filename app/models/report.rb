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
    CSV.foreach(file.path, headers: true) do |row|
      reports_hash = row.to_hash
      report = find_or_create_by!(phone_num: reports_hash['phone_num'], 
        rp_offer: reports_hash['rp_offer'], 
        expiration_date: reports_hash['expiration_date'], 
        trigger_date: reports_hash['trigger_date'], 
        init_date: reports_hash['init_date'], 
        init_ivr_code: reports_hash['init_ivr_code'])
      report.update_attributes(reports_hash)
    end
  end

end
