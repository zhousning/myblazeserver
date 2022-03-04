class CreateMthPdtRpts < ActiveRecord::Migration
  def change
    create_table :mth_pdt_rpts do |t|

      t.date :start_date

      t.date :end_date
    
      t.string :name,  null: false, default: Setting.systems.default_str

      t.float :design,  null: false, default: Setting.systems.default_num
    
      t.decimal :design, :precision => 10, :scale => 2,  null: false, :default => Setting.systems.default_num

      t.decimal :outflow, :precision => 10, :scale => 2,  null: false, :default => Setting.systems.default_num

      t.decimal :avg_outflow, :precision => 10, :scale => 2,  null: false, :default => Setting.systems.default_num

      t.decimal :end_outflow, :precision => 10, :scale => 2,  null: false, :default => Setting.systems.default_num
    
      t.string :cmc_bill,  null: false, default: Setting.systems.default_str
    
      t.string :ecm_ans_rpt,  null: false, default: Setting.systems.default_str

      t.float :per_cost,  null: false, default: Setting.systems.default_num

      t.integer :state,  null: false, default: Setting.systems.default_num 

      t.references :factory
    

    

    

    

    
      t.timestamps null: false
    end
  end
end
