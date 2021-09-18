class CreateDayPdts < ActiveRecord::Migration
  def change
    create_table :day_pdts do |t|
    
      t.date :pdt_date
    
      t.string :name,  null: false, default: Setting.systems.default_str
    
      t.string :signer,  null: false, default: Setting.systems.default_str
    
      t.string :weather,  null: false, default: Setting.systems.default_str
    
      t.float :min_temper,  null: false, default: Setting.systems.default_num 

      t.float :max_temper,  null: false, default: Setting.systems.default_num 
    
      t.text :desc
    

      t.integer :state,  null: false, default: Setting.systems.default_num 
    
    
      t.references :factory
    

    
      t.timestamps null: false
    end
  end
end
