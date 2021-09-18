class MthPdtRptsController < ApplicationController
  layout "application_control"
  before_filter :authenticate_user!
  authorize_resource :except => [:download_append, :produce_report]

  include MathCube 
  include CreateMthPdtRpt 

  CMS = ['cod', 'bod', 'nhn', 'tn', 'tp', 'ss', 'fecal']
  VARVALUE = ['avg_inf', 'avg_eff', 'emr', 'avg_emq', 'emq', 'end_emq','up_std', 'end_std', 'yoy', 'mom']  
  CMS.each do |c|
    VARVALUE.each do |v|
      define_method "#{c}_#{v}" do |obj|
        obj[v].nil? ? '' : obj[v]
      end
    end
  end

  def index
    @mth_pdt_rpt = MthPdtRpt.new
    @factory = my_factory
   
    @months = months
    @mth_pdt_rpts = @factory.mth_pdt_rpts.where(:state => [Setting.mth_pdt_rpts.ongoing, Setting.mth_pdt_rpts.verifying, Setting.mth_pdt_rpts.rejected, Setting.mth_pdt_rpts.cmp_verifying, Setting.mth_pdt_rpts.cmp_rejected]).order('start_date DESC').page( params[:page]).per( Setting.systems.per_page )  if @factory
   
  end

  def show
    @factory = my_factory
   
    @mth_pdt_rpt = @factory.mth_pdt_rpts.find(iddecode(params[:id]))
   
  end

  def verify_index
    @factory = my_factory

    @mth_pdt_rpts = @factory.mth_pdt_rpts.where(:state => [Setting.mth_pdt_rpts.verifying, Setting.mth_pdt_rpts.rejected, Setting.mth_pdt_rpts.cmp_verifying, Setting.mth_pdt_rpts.cmp_rejected]).order("start_date DESC").page( params[:page]).per( Setting.systems.per_page ) if @factory
  end

  def verify_show
    @factory = my_factory
    @mth_pdt_rpt = @factory.mth_pdt_rpts.find(iddecode(params[:id]))
  end

  def verifying
    @factory = my_factory
    @mth_pdt_rpt = @factory.mth_pdt_rpts.find(iddecode(params[:id]))
    @mth_pdt_rpt.verifying
    redirect_to factory_mth_pdt_rpt_path(idencode(@factory.id), idencode(@mth_pdt_rpt.id)) 
  end
  
  def rejected
    @factory = my_factory
    @mth_pdt_rpt = @factory.mth_pdt_rpts.find(iddecode(params[:id]))
    @mth_pdt_rpt.rejected
    redirect_to verify_show_factory_mth_pdt_rpt_path(idencode(@factory.id), idencode(@mth_pdt_rpt.id)) 
  end

  def cmp_verify_index
    @factory = my_factory

    @mth_pdt_rpts = @factory.mth_pdt_rpts.where(:state => [Setting.mth_pdt_rpts.verifying, Setting.mth_pdt_rpts.rejected, Setting.mth_pdt_rpts.cmp_verifying, Setting.mth_pdt_rpts.cmp_rejected]).order("start_date DESC").page( params[:page]).per( Setting.systems.per_page ) if @factory
    def cal_per_cost(mth_pdt_rpt)
      inflow = mth_pdt_rpt.outflow
      per_cost = 0
      mth_pdt_rpt.mth_chemicals.each do |c|
        per_cost += c.update_ptc(inflow)
      end
      mth_pdt_rpt.update_per_cost(per_cost)
    end

  end
  
  def cmp_verify_show
    @factory = my_factory
    @mth_pdt_rpt = @factory.mth_pdt_rpts.find(iddecode(params[:id]))
  end

  def cmp_verifying
    @factory = my_factory
    @mth_pdt_rpt = @factory.mth_pdt_rpts.find(iddecode(params[:id]))
    @mth_pdt_rpt.cmp_verifying
    redirect_to verify_show_factory_mth_pdt_rpt_path(idencode(@factory.id), idencode(@mth_pdt_rpt.id)) 
  end
  
  def cmp_rejected
    @factory = my_factory
    @mth_pdt_rpt = @factory.mth_pdt_rpts.find(iddecode(params[:id]))
    @mth_pdt_rpt.cmp_rejected
    redirect_to cmp_verify_show_factory_mth_pdt_rpt_path(idencode(@factory.id), idencode(@mth_pdt_rpt.id)) 
  end

  def upreport
    @factory = my_factory
    @mth_pdt_rpt = @factory.mth_pdt_rpts.find(iddecode(params[:id]))

    @mth_pdt_rpt.complete
    redirect_to cmp_verify_show_factory_mth_pdt_rpt_path(idencode(@factory.id), idencode(@mth_pdt_rpt.id)) 
  end

  def mth_report_finish_index
    @factory = my_factory
    @mth_pdt_rpts = @factory.mth_pdt_rpts.where(:state => Setting.mth_pdt_rpts.complete).order('start_date DESC')
  end

  def mth_report_finish_show
    @factory = my_factory
    @mth_pdt_rpt = @factory.mth_pdt_rpts.find(iddecode(params[:id]))
  end
   

  def mth_rpt_create
    @factory = my_factory
    month = params[:month].strip.to_i
    year = params[:year].strip.to_i
    time = Time.new
    now_year = time.year

    search_month = Date.new(year, month)
    now_month = Date.new(now_year, time.month)
    if now_month <= search_month
      redirect_to :action => :index
      return
    end

    _year_start = Date.new(year, 1, 1)
    _start = Date.new(year, month, 1)
    _end = Date.new(year, month, -1)
    @mth_pdt_rpts_cache = @factory.mth_pdt_rpts.where(["start_date = ? and end_date = ?", _start, _end])
    unless @mth_pdt_rpts_cache.blank?
      redirect_to :action => :index
      return
    end

    status = create_mth_pdt_rpt(@factory, year, month, Setting.mth_pdt_rpts.ongoing)

    if status == 'success'
      flash[:info] = "月度报表生成成功"
    elsif status == 'fail'
      flash[:info] = "月度报表生成失败"
    elsif status == 'zero'
      flash[:info] = "选定月份暂无数据"
    end
    redirect_to :action => :index
  end

      
   
  def edit
    @factory = my_factory 
    @mth_pdt_rpt = @factory.mth_pdt_rpts.find(iddecode(params[:id]))
   
  end
   

   
  def update
    @factory = my_factory 
    @mth_pdt_rpt = @factory.mth_pdt_rpts.find(iddecode(params[:id]))
   
    if @mth_pdt_rpt.update(mth_pdt_rpt_params)
      cal_per_cost(@mth_pdt_rpt)
      redirect_to factory_mth_pdt_rpt_path(idencode(@factory.id), idencode(@mth_pdt_rpt.id)) 
    else
      render :edit
    end
  end

  def download_append
   
    @factory = my_factory
    @mth_pdt_rpt = @factory.mth_pdt_rpts.find(iddecode(params[:id]))
   
    @ecm_ans_rpt = @mth_pdt_rpt.ecm_ans_rpt_url

    if @ecm_ans_rpt
      send_file File.join(Rails.root, "public", URI.decode(@ecm_ans_rpt)), :type => "application/force-download", :x_sendfile=>true
    end
  end
  


  def download_report
    @factory = my_factory 
    @mth_pdt_rpt = @factory.mth_pdt_rpts.find(iddecode(params[:id]))

    docWorker = ExportMthDoc.new
    target_word = docWorker.process(@mth_pdt_rpt.id)
    send_file target_word, :filename => "月报表word报告.docx", :type => "application/force-download", :x_sendfile=>true
  end
  
  def xls_mth_download
    @factory = my_factory 
    @mth_pdt_rpt = @factory.mth_pdt_rpts.find(iddecode(params[:id]))
    obj = [@mth_pdt_rpt]

    excel_tool = SpreadSheetTool.new
    target_excel = excel_tool.exportMthPdtRptToExcel(obj)
    send_file target_excel, :filename => "月报表.xls", :type => "application/force-download", :x_sendfile=>true
  end

  def produce_report 
    @factory = my_factory
    @mth_pdt_rpt = @factory.mth_pdt_rpts.find(iddecode(params[:id]))
    header = {
      :name => @mth_pdt_rpt.name
    }

    flow = flow_content(@mth_pdt_rpt) 
    cms = cms_content(@mth_pdt_rpt) 
    chemical = chemical_content(@mth_pdt_rpt) 
    power = power_content(@mth_pdt_rpt) 
    mud = mud_content(@mth_pdt_rpt) 
    md = md_content(@mth_pdt_rpt) 
    
    respond_to do |format|
      format.json{ render :json => 
        {
          :fct_id => idencode(@factory.id),
          :mth_rpt_id => idencode(@mth_pdt_rpt.id),
          :header => header,
          :flow   => flow, 
          :cms    => cms,
          :power => power,
          :mud => mud,
          :md  => md,
          :chemical => chemical
        }.to_json}
    end
  end

  def flow_content(mth_pdt_rpt)
    flow_targets =['design', 'outflow', 'avg_outflow', 'end_outflow']
    flow_arr = []
    flow_title = []
    flow_targets.each_with_index do |t, index|
      flow_title += [Setting.mth_pdt_rpts[t], mth_pdt_rpt[t]]
      if (index+1)%2 == 0
        flow_arr << flow_title
        flow_title = []
      end
    end
    flow_arr
  end

  def md_content(mth_pdt_rpt)
    md = mth_pdt_rpt.month_md
    md_targets =['mdrcy', 'end_mdrcy', 'mdsell', 'end_mdsell', 'yoy_mdrcy', 'mom_mdrcy', 'yoy_mdsell', 'mom_mdsell']
    md_arr = []
    md_title = []
    md_targets.each_with_index do |t, index|
      md_title += [Setting.month_mds[t], md[t]]
      if (index+1)%2 == 0
        md_arr << md_title
        md_title = []
      end
    end
    md_arr
  end

  def mud_content(mth_pdt_rpt)
    mud = mth_pdt_rpt.month_mud
    mud_targets =['inmud', 'end_inmud', 'outmud', 'end_outmud', 'yoy', 'mom']
    mud_arr = []
    mud_title = []
    mud_targets.each_with_index do |t, index|
      mud_title += [Setting.month_muds[t], mud[t]]
      if (index+1)%2 == 0
        mud_arr << mud_title
        mud_title = []
      end
    end
    mud_arr
  end

  def power_content(mth_pdt_rpt)
    power = mth_pdt_rpt.month_power
    power_targets =['power', 'end_power', 'bom', 'bom_power', 'yoy_power', 'mom_power', 'yoy_bom', 'mom_bom' ]
    power_arr = []
    power_title = []
    power_targets.each_with_index do |t, index|
      power_title += [Setting.month_powers[t], power[t]]
      if (index+1)%2 == 0
        power_arr << power_title
        power_title = []
      end
    end
    power_arr
  end

  #[
  #  ['', '', ''],
  #  ['', '', '']
  #]
  def cms_content(mth_pdt_rpt)
    cod = mth_pdt_rpt.month_cod
    bod = mth_pdt_rpt.month_bod
    nhn = mth_pdt_rpt.month_nhn
    tn = mth_pdt_rpt.month_tn
    tp = mth_pdt_rpt.month_tp
    ss = mth_pdt_rpt.month_ss
    fecal = mth_pdt_rpt.month_fecal
  
    cms_arr = []
    cms_title = ['']
    CMS.each do |c|
      cms_title << Setting["month_#{c}".pluralize.to_sym]['label']
    end
    cms_arr << cms_title

    targets = [cod, bod, nhn, tn, tp, ss, fecal]
    result = []
    VARVALUE.each do |v|
      title = Setting.month_cods[v].gsub('COD','')
      result = [title]
      CMS.each_with_index do |c, cms_index|
        mObj = method("#{c}_#{v}".to_sym)
        result << mObj.call(targets[cms_index]) 
      end
      cms_arr << result 
    end
    cms_arr
  end

  #[
  #  ['', '', ''],
  #  ['', '', '']
  #]
  def chemical_content(mth_pdt_rpt)
    chemicals = mth_pdt_rpt.mth_chemicals
    chemical_targets = ['name', 'unprice', 'cmptc', 'dosage', 'act_dosage', 'avg_dosage', 'dosptc', 'per_cost']
    chemical_arr = []
    chemical_title = []
    chemical_targets.each do |t|
      chemical_title << Setting.mth_chemicals[t]
    end
    chemical_arr << chemical_title
    chemicals.each do |chemical|
      arr = []
      chemical_targets.each_with_index do |t, index|
        if index == 0
          arr << chemicals_hash[chemical[t]]
        else
          arr << chemical[t]
        end
      end
      chemical_arr << arr
    end
    chemical_arr
  end

  private
  
    def mth_pdt_rpt_params
      params.require(:mth_pdt_rpt).permit( :cmc_bill , :ecm_ans_rpt, month_cod_attributes: month_cod_params, month_bod_attributes: month_bod_params, month_tp_attributes: month_tp_params, month_tn_attributes: month_tn_params, month_nhn_attributes: month_nhn_params, month_ss_attributes: month_ss_params, month_fecal_attributes: month_fecal_params, month_power_attributes: month_power_params, month_mud_attributes: month_mud_params, month_md_attributes: month_md_params, month_device_attributes: month_device_params, month_stuff_attributes: month_stuff_params,  mth_chemicals_attributes: mth_chemical_params)
    end

    def mth_chemical_params
      #[:id, :name, :unprice, :cmptc, :dosage , :avg_dosage , :act_dosage , :dosptc, :per_cost, :_destroy]
      [:id, :unprice, :cmptc, :act_dosage ]
    end
  
    def month_cod_params
      [:id, :ypdr]
    end
  
    def month_bod_params
      [:id, :ypdr ]
    end
  

    def month_tp_params
      [:id, :ypdr ]
    end
  
    def month_tn_params
      [:id, :ypdr ]
    end
  
    def month_nhn_params
      [:id, :ypdr ]
    end
  
    def month_ss_params
      [:id, :ypdr ]
    end

    def month_fecal_params
      [:id,:ypdr ]
    end
  
    def month_power_params
      [:id, :ypdr_power, :ypdr_bom]
    end
  
    def month_mud_params
      [:id, :ypdr ]
    end
  
    def month_md_params
      [:id, :ypdr_mdsell, :ypdr_mdrcy ]
    end
  
    def month_device_params
      [:id, :wsyxts, :wswdyxts, :sbwhl, :gysbwhl, :wbywhl, :gzwwhl, :yoy, :mom, :ypdr ,:_destroy]
    end
  
    def month_stuff_params
      [:id, :xdjtjl, :end_xdjtjl, :yoy, :mom, :ypdr ,:_destroy]
    end
  
    #def mth_pdt_rpt_params
    #  params.require(:mth_pdt_rpt).permit( :design, :outflow, :avg_outflow, :end_outflow, month_cod_attributes: month_cod_params, month_bod_attributes: month_bod_params, month_tp_attributes: month_tp_params, month_tn_attributes: month_tn_params, month_nhn_attributes: month_nhn_params, month_fecal_attributes: month_fecal_params, month_power_attributes: month_power_params, month_mud_attributes: month_mud_params, month_md_attributes: month_md_params, month_device_attributes: month_device_params, month_stuff_attributes: month_stuff_params)
    #end
  
    #def month_cod_params
    #  [:id, :avg_inf, :avg_eff, :emr, :avg_emq, :emq, :end_emq, :up_std, :end_std, :yoy, :mom, :ypdr ,:_destroy]
    #end
  
    #def month_bod_params
    #  [:id, :avg_inf, :avg_eff, :emr, :avg_emq, :emq, :end_emq, :up_std, :end_std, :yoy, :mom, :ypdr ,:_destroy]
    #end
  
    #def month_tp_params
    #  [:id, :avg_inf, :avg_eff, :emr, :avg_emq, :emq, :end_emq, :up_std, :end_std, :yoy, :mom, :ypdr ,:_destroy]
    #end
  
    #def month_tn_params
    #  [:id, :avg_inf, :avg_eff, :emr, :avg_emq, :emq, :end_emq, :up_std, :end_std, :yoy, :mom, :ypdr ,:_destroy]
    #end
  
    #def month_nhn_params
    #  [:id, :avg_inf, :avg_eff, :emr, :avg_emq, :emq, :end_emq, :up_std, :end_std, :yoy, :mom, :ypdr ,:_destroy]
    #end
  
    #def month_fecal_params
    #  [:id, :up_std, :end_std, :yoy, :mom, :ypdr ,:_destroy]
    #end
  
    #def month_power_params
    #  [:id, :power, :end_power, :bom, :bom_power, :yoy, :mom, :ypdr ,:_destroy]
    #end
  
    #def month_mud_params
    #  [:id, :inmud, :end_inmud, :outmud, :end_outmud, :mst_up, :yoy, :mom, :ypdr ,:_destroy]
    #end
  
    #def month_md_params
    #  [:id, :mdrcy, :end_mdrcy, :mdsell, :end_mdsell, :yoy, :mom, :ypdr ,:_destroy]
    #end
    
    def my_factory
      @factory = current_user.factories.find(iddecode(params[:factory_id]))
    end

    def cal_per_cost(mth_pdt_rpt)
      inflow = mth_pdt_rpt.outflow
      per_cost = 0
      mth_pdt_rpt.mth_chemicals.each do |c|
        per_cost += c.update_ptc(inflow)
      end
      mth_pdt_rpt.update_per_cost(per_cost)
    end

end

