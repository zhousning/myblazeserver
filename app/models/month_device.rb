class MonthDevice < ActiveRecord::Base






  belongs_to :mth_pdt_rpt



end

# == Schema Information
#
# Table name: month_devices
#
#  id             :integer         not null, primary key
#  wsyxts         :float           default("0.0"), not null
#  wswdyxts       :float           default("0.0"), not null
#  sbwhl          :float           default("0.0"), not null
#  gysbwhl        :float           default("0.0"), not null
#  wbywhl         :float           default("0.0"), not null
#  gzwwhl         :float           default("0.0"), not null
#  yoy            :float           default("0.0"), not null
#  mom            :float           default("0.0"), not null
#  ypdr           :float           default("0.0"), not null
#  mth_pdt_rpt_id :integer
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#

