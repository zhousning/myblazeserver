class MthPdtRptsController < ApplicationController
  skip_before_action :verify_authenticity_token

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
    results = []
    user = User.find_by_number(params[:openid])
    @factories = user.factories

    @factories.each do |factory|
      @mth_pdt_rpts = factory.mth_pdt_rpts.where('state = ?', Setting.mth_pdt_rpts.complete).order('start_date DESC')
      @mth_pdt_rpts.each do |mth_pdt_rpt|
        results << {
          name: mth_pdt_rpt.name,
          fct: idencode(factory.id),
          mth_pdt_rpt: idencode(mth_pdt_rpt.id)
        }
      end
    end
    respond_to do |f|
      f.json{ render :json => {:results => results}.to_json}
    end
  end

  def verify_index
    results = []
    user = User.find_by_number(params[:openid])
    @factories = user.factories

    @factories.each do |factory|
      @mth_pdt_rpts = factory.mth_pdt_rpts.where('state != ?', Setting.mth_pdt_rpts.complete).order('start_date DESC')
      @mth_pdt_rpts.each do |mth_pdt_rpt|
        results << {
          name: mth_pdt_rpt.name,
          state: mth_pdt_rpt.state,
          fct: idencode(factory.id),
          mth_pdt_rpt: idencode(mth_pdt_rpt.id)
        }
      end
    end
    respond_to do |f|
      f.json{ render :json => {:results => results}.to_json}
    end
  end

  def verify_show
    user = User.find_by_number(params[:openid])
    @factory = user.factories.find(iddecode(params[:factory_id]))
    @mth_pdt_rpt = @factory.mth_pdt_rpts.find(iddecode(params[:id]))
    chemicals = []
    @mth_pdt_rpt.mth_chemicals.each do |chemical|
      chemicals << {
        name: chemicals_hash[chemical.name],
        unprice: chemical.unprice,
        cmptc: chemical.cmptc,
        dosage: chemical.dosage,
        act_dos: chemical.act_dosage,
        avg_dos: chemical.avg_dosage,
        dosptc: chemical.dosptc,
        per_cost: chemical.per_cost
      }
    end

    inf = {
      cod: @mth_pdt_rpt.month_cod.avg_inf,
      bod: @mth_pdt_rpt.month_bod.avg_inf,
      nhn: @mth_pdt_rpt.month_nhn.avg_inf,
      tn: @mth_pdt_rpt.month_tn.avg_inf,
      tp: @mth_pdt_rpt.month_tp.avg_inf,
      ss: @mth_pdt_rpt.month_ss.avg_inf
    }
    eff = {
      cod: @mth_pdt_rpt.month_cod.avg_eff,
      bod: @mth_pdt_rpt.month_bod.avg_eff,
      nhn: @mth_pdt_rpt.month_nhn.avg_eff,
      tn: @mth_pdt_rpt.month_tn.avg_eff,
      tp: @mth_pdt_rpt.month_tp.avg_eff,
      ss: @mth_pdt_rpt.month_ss.avg_eff
    }
    emr = {
      cod: @mth_pdt_rpt.month_cod.emr,
      bod: @mth_pdt_rpt.month_bod.emr,
      nhn: @mth_pdt_rpt.month_nhn.emr,
      tn: @mth_pdt_rpt.month_tn.emr,
      tp: @mth_pdt_rpt.month_tp.emr,
      ss: @mth_pdt_rpt.month_ss.emr
    }
    avg_emq = {
      cod: @mth_pdt_rpt.month_cod.avg_emq,
      bod: @mth_pdt_rpt.month_bod.avg_emq,
      nhn: @mth_pdt_rpt.month_nhn.avg_emq,
      tn: @mth_pdt_rpt.month_tn.avg_emq,
      tp: @mth_pdt_rpt.month_tp.avg_emq,
      ss: @mth_pdt_rpt.month_ss.avg_emq
    }
    emq = {
      cod: @mth_pdt_rpt.month_cod.emq,
      bod: @mth_pdt_rpt.month_bod.emq,
      nhn: @mth_pdt_rpt.month_nhn.emq,
      tn: @mth_pdt_rpt.month_tn.emq,
      tp: @mth_pdt_rpt.month_tp.emq,
      ss: @mth_pdt_rpt.month_ss.emq
    }
    end_emq = {
      cod: @mth_pdt_rpt.month_cod.end_emq,
      bod: @mth_pdt_rpt.month_bod.end_emq,
      nhn: @mth_pdt_rpt.month_nhn.end_emq,
      tn: @mth_pdt_rpt.month_tn.end_emq,
      tp: @mth_pdt_rpt.month_tp.end_emq,
      ss: @mth_pdt_rpt.month_ss.end_emq
    }
    yoy = {
      cod: @mth_pdt_rpt.month_cod.yoy,
      bod: @mth_pdt_rpt.month_bod.yoy,
      nhn: @mth_pdt_rpt.month_nhn.yoy,
      tn: @mth_pdt_rpt.month_tn.yoy,
      tp: @mth_pdt_rpt.month_tp.yoy,
      ss: @mth_pdt_rpt.month_ss.yoy
    }
    mom = {
      cod: @mth_pdt_rpt.month_cod.mom,
      bod: @mth_pdt_rpt.month_bod.mom,
      nhn: @mth_pdt_rpt.month_nhn.mom,
      tn: @mth_pdt_rpt.month_tn.mom,
      tp: @mth_pdt_rpt.month_tp.mom,
      ss: @mth_pdt_rpt.month_ss.mom
    }
    power = {
      power: @mth_pdt_rpt.month_power.power,
      end_power: @mth_pdt_rpt.month_power.end_power,
      bom: @mth_pdt_rpt.month_power.bom,
      yoy_power: @mth_pdt_rpt.month_power.yoy_power,
      mom_power: @mth_pdt_rpt.month_power.mom_power,
      yoy_bom: @mth_pdt_rpt.month_power.yoy_bom,
      mom_bom: @mth_pdt_rpt.month_power.mom_bom
    }
    mud = {
      inmud: @mth_pdt_rpt.month_mud.inmud,
      end_inmud: @mth_pdt_rpt.month_mud.end_inmud,
      outmud: @mth_pdt_rpt.month_mud.outmud,
      end_outmud: @mth_pdt_rpt.month_mud.end_outmud,
      yoy: @mth_pdt_rpt.month_mud.yoy,
      mom: @mth_pdt_rpt.month_mud.mom
    }
    md = {
      mdrcy: @mth_pdt_rpt.month_md.mdrcy,
      end_mdrcy: @mth_pdt_rpt.month_md.end_mdrcy,
      mdsell: @mth_pdt_rpt.month_md.mdsell,
      end_mdsell: @mth_pdt_rpt.month_md.end_mdsell,
      yoy_mdrcy: @mth_pdt_rpt.month_md.yoy_mdrcy,
      mom_mdrcy: @mth_pdt_rpt.month_md.mom_mdrcy,
      yoy_mdsell: @mth_pdt_rpt.month_md.yoy_mdsell,
      mom_mdsell: @mth_pdt_rpt.month_md.mom_mdsell
    }

	  results = { 
      state: @mth_pdt_rpt.state,
      outflow: @mth_pdt_rpt.outflow,
      avg_outflow: @mth_pdt_rpt.avg_outflow,
      end_outflow: @mth_pdt_rpt.end_outflow,
      inf: inf,
      eff: eff,
      emr: emr,
      avg_emq: avg_emq,
      emq: emq,
      end_emq: end_emq,
      yoy: yoy,
      mom: mom,
      md: md,
      mud: mud,
      chemicals: chemicals, 
      power: power
    }
    respond_to do |f|
      f.json{ render :json => {:results => results}.to_json}
    end
  end

  def rejected
    user = User.find_by_number(params[:openid])
    @factory = user.factories.find(iddecode(params[:factory_id]))
    @mth_pdt_rpt = @factory.mth_pdt_rpts.find(iddecode(params[:id]))
    if user.has_role?(Setting.roles.mth_pdt_rpt_verify)
      if @mth_pdt_rpt.rejected
        result = {:status => 'success', :state => @mth_pdt_rpt.state}
        respond_to do |f|
          f.json{ render :json => {:result => result}.to_json}
        end
      else
        result = {:status => 'fail'}
        respond_to do |f|
          f.json{ render :json => {:result => result}.to_json}
        end
      end
    elsif user.has_role?(Setting.roles.mth_pdt_rpt_cmp_verify)
      if @mth_pdt_rpt.cmp_rejected
        result = {:status => 'success', :state => @mth_pdt_rpt.state}
        respond_to do |f|
          f.json{ render :json => {:result => result}.to_json}
        end
      else
        result = {:status => 'fail'}
        respond_to do |f|
          f.json{ render :json => {:result => result}.to_json}
        end
      end
    end
  end

  def upreport
    user = User.find_by_number(params[:openid])
    @factory = user.factories.find(iddecode(params[:factory_id]))
    @mth_pdt_rpt = @factory.mth_pdt_rpts.find(iddecode(params[:id]))
    if user.has_role?(Setting.roles.mth_pdt_rpt_cmp_verify)
      if @mth_pdt_rpt.complete
        result = {:status => 'success', :state => @mth_pdt_rpt.state}
        respond_to do |f|
          f.json{ render :json => {:result => result}.to_json}
        end
      else
        result = {:status => 'fail'}
        respond_to do |f|
          f.json{ render :json => {:result => result}.to_json}
        end
      end
    end
  end

  def cmp_verifying
    user = User.find_by_number(params[:openid])
    @factory = user.factories.find(iddecode(params[:factory_id]))
    @mth_pdt_rpt = @factory.mth_pdt_rpts.find(iddecode(params[:id]))
    if user.has_role?(Setting.roles.mth_pdt_rpt_verify)
      if @mth_pdt_rpt.cmp_verifying
        result = {:status => 'success', :state => @mth_pdt_rpt.state}
        respond_to do |f|
          f.json{ render :json => {:result => result}.to_json}
        end
      else
        result = {:status => 'fail'}
        respond_to do |f|
          f.json{ render :json => {:result => result}.to_json}
        end
      end
    end
  end
  
  #######################################
    
  def cmp_rejected
    user = User.find_by_number(params[:openid])
    @factory = user.factories.find(iddecode(params[:factory_id]))
    @mth_pdt_rpt = @factory.mth_pdt_rpts.find(iddecode(params[:id]))
    if @mth_pdt_rpt.cmp_rejected
      result = {:status => 'success', :state => @mth_pdt_rpt.state}
      respond_to do |f|
        f.json{ render :json => {:result => result}.to_json}
      end
    else
      result = {:status => 'fail'}
      respond_to do |f|
        f.json{ render :json => {:result => result}.to_json}
      end
    end
  end

  def cmp_verify_index
    @factory = my_factory

    @mth_pdt_rpts = @factory.mth_pdt_rpts.where(:state => [Setting.mth_pdt_rpts.verifying, Setting.mth_pdt_rpts.rejected, Setting.mth_pdt_rpts.cmp_verifying, Setting.mth_pdt_rpts.cmp_rejected]).order("start_date DESC").page( params[:page]).per( Setting.systems.per_page ) if @factory
  end
  
  def cmp_verify_show
    @factory = my_factory
    @mth_pdt_rpt = @factory.mth_pdt_rpts.find(iddecode(params[:id]))
  end

  def show
    @factory = my_factory
   
    @mth_pdt_rpt = @factory.mth_pdt_rpts.find(iddecode(params[:id]))
   
  end

  def verifying
    @factory = my_factory
    @mth_pdt_rpt = @factory.mth_pdt_rpts.find(iddecode(params[:id]))
    @mth_pdt_rpt.verifying
    redirect_to factory_mth_pdt_rpt_path(idencode(@factory.id), idencode(@mth_pdt_rpt.id)) 
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

