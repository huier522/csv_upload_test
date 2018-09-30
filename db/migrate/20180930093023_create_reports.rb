class CreateReports < ActiveRecord::Migration[5.2]
  def change
    create_table :reports do |t|
      t.string :phone_num
      t.text :rp_offer
      t.date :expiration_date
      t.date :trigger_date
      t.date :init_date
      t.string :init_ivr_code
      t.timestamps
    end
  end
end
