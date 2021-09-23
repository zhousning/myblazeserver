class DayPdtsController < ApplicationController
  skip_before_action :verify_authenticity_token

  include FormulaLib


  #日运营数据列表
  def verify_index
    results = []
    user = User.find_by_number(params[:openid])
    @factories = user.factories

    #角色代码jd厂区运营数据审核 0 公司运营数据审核 1 厂区运营数据填报 2 
    jd = nil
    if user.has_role?(Setting.roles.day_pdt_verify) 
      jd = 0
    elsif user.has_role?(Setting.roles.day_pdt_cmp_verify) 
      jd = 1
    elsif user.has_role?(Setting.roles.day_pdt) 
      jd = 2 
    end

    
    @factories.each do |factory|
      @day_pdts = factory.day_pdts.where('state != ?', Setting.day_pdts.complete).order('pdt_date DESC')
      @day_pdts.each do |day_pdt|
        results << {
          name: day_pdt.pdt_date.to_s + factory.name,
          state: day_pdt.state,
          fct: idencode(factory.id),
          jd: jd,
          day_pdt: idencode(day_pdt.id)
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
    @day_pdt = @factory.day_pdts.find(iddecode(params[:id]))
    inf = @day_pdt.inf_qlty
    eff = @day_pdt.eff_qlty
    sed = @day_pdt.sed_qlty
    pdt_sum = @day_pdt.pdt_sum
    chemicals = []
    @day_pdt.chemicals.each do |chemical|
      chemicals << {
        name: chemicals_hash[chemical.name],
        unprice: chemical.unprice,
        cmptc: chemical.cmptc,
        dosage: chemical.dosage
      }
    end
    tspmuds = []
    @day_pdt.tspmuds.each do |tspmud|
      tspmuds << {
        name: mudfcts_hash(@factory)[tspmud.dealer],
        tspvum: tspmud.tspvum,
        rcpvum: tspmud.rcpvum,
        price: tspmud.price,
        prtmtd: tspmud.prtmtd
      }
    end

	  results = { 
      state: @day_pdt.state,
      cm_inf_cod:  inf.asy_cod,
      cm_inf_bod:  inf.bod,
      cm_inf_nhn:  inf.asy_nhn,
      cm_inf_tn:  inf.asy_tn,
      cm_inf_tp:  inf.asy_tp,
      cm_inf_ss:  inf.ss,
      cm_inf_ph:  inf.ph,
      on_inf_cod:  inf.cod,
      on_inf_nhn:  inf.nhn,
      on_inf_tn:  inf.tn,
      on_inf_tp:  inf.tp,
	    cm_eff_cod:  eff.asy_cod,
      cm_eff_bod:  eff.bod,
      cm_eff_nhn:  eff.asy_nhn,
      cm_eff_tn:  eff.asy_tn,
      cm_eff_tp:  eff.asy_tp,
      cm_eff_ss:  eff.ss,
      cm_eff_ph:  eff.ph,
      on_eff_cod:  eff.cod,
      on_eff_nhn:  eff.nhn,
      on_eff_tn:  eff.tn,
      on_eff_tp:  eff.tp,
	    cm_sed_cod:  sed.cod,
      cm_sed_bod:  sed.bod,
      cm_sed_nhn:  sed.nhn,
      cm_sed_tn:  sed.tn,
      cm_sed_tp:  sed.tp,
      cm_sed_ss:  sed.ss,
      cm_sed_ph:  sed.ph,
	    inflow:  pdt_sum.inflow,
      outflow:  pdt_sum.outflow,
      power:  pdt_sum.power,
      inmud:  pdt_sum.inmud,
      outmud:  pdt_sum.outmud,
      mst:  pdt_sum.mst,
      md:  pdt_sum.mdflow,
      mdrcy:  pdt_sum.mdrcy,
      mdsell:  pdt_sum.mdsell,
      desc:  @day_pdt.desc || '',          
      chemicals:  chemicals,
      tspmuds:  tspmuds
    }

    respond_to do |f|
      f.json{ render :json => {:results => results}.to_json}
    end
  end

  #//厂区运营数据审核
  #- if current_user.has_role?(Setting.roles.day_pdt_verify)
  #//公司运营数据审核
  #- if current_user.has_role?(Setting.roles.day_pdt_cmp_verify)
  #//厂区月报表审核
  #- if current_user.has_role?(Setting.roles.mth_pdt_rpt_verify)
  #//公司月报表审核
  #- if current_user.has_role?(Setting.roles.mth_pdt_rpt_cmp_verify)
  def rejected
    user = User.find_by_number(params[:openid])
    @factory = user.factories.find(iddecode(params[:factory_id]))
    @day_pdt = @factory.day_pdts.find(iddecode(params[:id]))
    if user.has_role?(Setting.roles.day_pdt_verify)
      if @day_pdt.rejected
        result = {:status => 'success', :state => @day_pdt.state}
        respond_to do |f|
          f.json{ render :json => {:result => result}.to_json}
        end
      else
        result = {:status => 'fail'}
        respond_to do |f|
          f.json{ render :json => {:result => result}.to_json}
        end
      end
    elsif user.has_role?(Setting.roles.day_pdt_cmp_verify)
      if @day_pdt.cmp_rejected
        result = {:status => 'success', :state => @day_pdt.state}
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
    @day_pdt = @factory.day_pdts.find(iddecode(params[:id]))
    if user.has_role?(Setting.roles.day_pdt_cmp_verify)
      if @day_pdt.state == Setting.day_pdts.cmp_verifying
        @eff = @day_pdt.eff_qlty
        @inf = @day_pdt.inf_qlty
        @sed = @day_pdt.sed_qlty
        @tspmuds = @day_pdt.tspmuds
        @chemicals = @day_pdt.chemicals
        @pdt_sum = @day_pdt.pdt_sum


        @day_pdt_rpt = DayPdtRpt.new(
          :factory => @factory,
          :day_pdt => @day_pdt,
          :tspmuds => @tspmuds,
          :chemicals => @chemicals,
          :name => @day_pdt.name, :pdt_date => @day_pdt.pdt_date, :weather => @day_pdt.weather, :min_temper => @day_pdt.min_temper,  :max_temper => @day_pdt.max_temper,
          :inf_qlty_bod => @inf.bod, :inf_qlty_cod => @inf.cod, :inf_qlty_ss => @inf.ss, :inf_qlty_nhn => @inf.nhn, :inf_qlty_tn => @inf.tn, :inf_qlty_tp => @inf.tp, :inf_qlty_ph => @inf.ph, 
          :eff_qlty_bod => @eff.bod, :eff_qlty_cod => @eff.cod, :eff_qlty_ss => @eff.ss, :eff_qlty_nhn => @eff.nhn, :eff_qlty_tn => @eff.tn, :eff_qlty_tp => @eff.tp, :eff_qlty_ph => @eff.ph, :eff_qlty_fecal => @eff.fecal,
          :sed_qlty_bod => @sed.bod, :sed_qlty_cod => @sed.cod, :sed_qlty_ss => @sed.ss, :sed_qlty_nhn => @sed.nhn, :sed_qlty_tn => @sed.tn, :sed_qlty_tp => @sed.tp, :sed_qlty_ph => @sed.ph, 
          :inflow => @pdt_sum.inflow, :outflow => @pdt_sum.outflow, :inmud => @pdt_sum.inmud, :outmud => @pdt_sum.outmud, :mst => @pdt_sum.mst, :power => @pdt_sum.power, :mdflow => @pdt_sum.mdflow, :mdrcy => @pdt_sum.mdrcy, :mdsell => @pdt_sum.mdsell, :per_cost => @pdt_sum.per_cost,
         :inf_asy_cod => @inf.asy_cod, :inf_asy_nhn => @inf.asy_nhn, :inf_asy_tp => @inf.asy_tp, :inf_asy_tn => @inf.asy_tn,
         :eff_asy_cod => @eff.asy_cod, :eff_asy_nhn => @eff.asy_nhn, :eff_asy_tp => @eff.asy_tp, :eff_asy_tn => @eff.asy_tn,
         :sed_asy_cod => @sed.asy_cod, :sed_asy_nhn => @sed.asy_nhn, :sed_asy_tp => @sed.asy_tp, :sed_asy_tn => @sed.asy_tn
        )

        if @day_pdt_rpt.save
          @day_pdt.complete
          result = {:status => 'success', :state => @day_pdt.state}
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
  end

  def cmp_verifying
    user = User.find_by_number(params[:openid])
    @factory = user.factories.find(iddecode(params[:factory_id]))
    @day_pdt = @factory.day_pdts.find(iddecode(params[:id]))
    if user.has_role?(Setting.roles.day_pdt_verify)
      if @day_pdt.cmp_verifying
        result = {:status => 'success', :state => @day_pdt.state}
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
  
############################################3
  def cmp_rejected
    user = User.find_by_number(params[:openid])
    @factory = user.factories.find(iddecode(params[:factory_id]))
    @day_pdt = @factory.day_pdts.find(iddecode(params[:id]))
    if @day_pdt.cmp_rejected
      result = {:status => 'success', :state => @day_pdt.state}
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
  def verifying
    @factory = my_factory
    @day_pdt = @factory.day_pdts.find(iddecode(params[:id]))
    @day_pdt.verifying
    redirect_to factory_day_pdt_path(idencode(@factory.id), idencode(@day_pdt.id)) 
  end
  
  
  def cmp_verify_show
    user = User.find_by_number(params[:openid])
    @factory = user.factories.find(iddecode(params[:factory_id]))
    @day_pdt = @factory.day_pdts.find(iddecode(params[:id]))
  end


  def index
    @day_pdt = DayPdt.new
    @factory = my_factory
    @day_pdts = @factory.day_pdts.where(:state => [Setting.day_pdts.ongoing, Setting.day_pdts.verifying, Setting.day_pdts.rejected, Setting.day_pdts.cmp_verifying, Setting.day_pdts.cmp_rejected]).order('pdt_date DESC').page( params[:page]).per( Setting.systems.per_page )  if @factory
  end
   
  def show
    @factory = my_factory
    @day_pdt = @factory.day_pdts.find(iddecode(params[:id]))
  end

  def cmp_verify_index
    @factory = my_factory

    @day_pdts = @factory.day_pdts.where(:state => [Setting.day_pdts.verifying, Setting.day_pdts.rejected, Setting.day_pdts.cmp_verifying, Setting.day_pdts.cmp_rejected]).order("pdt_date DESC").page( params[:page]).per( Setting.systems.per_page ) if @factory
  end

  def new
    @factory = my_factory
    @day_pdt = DayPdt.new
    
    @day_pdt.build_inf_qlty
    @day_pdt.build_eff_qlty
    @day_pdt.build_sed_qlty
    @day_pdt.build_pdt_sum
    
  end
   
  def create
    @factory = my_factory
    day_pdt = @factory.day_pdts.where(:pdt_date => day_pdt_params[:pdt_date]).first
    day_pdt_rpt = @factory.day_pdt_rpts.where(:pdt_date => day_pdt_params[:pdt_date]).first
    @day_pdt = DayPdt.new(day_pdt_params)

    if day_pdt || day_pdt_rpt
      @day_pdt.errors[:date_error] = day_pdt_params[:pdt_date] + "运营数据已存在,请重新填报"
      render :new
    else
      @day_pdt.name = @day_pdt.pdt_date.to_s + @factory.name + "生产运营报表"
      @day_pdt.factory = @factory

      if @day_pdt.save
        cal_per_cost(@day_pdt)
        redirect_to factory_day_pdt_path(idencode(@factory.id), idencode(@day_pdt.id)) 
      else
        render :new
      end
    end
  end

  #1点-00点
  #_start = date.to_s + "00:10:00"
  #_end = (date + 1).to_s + "00:10:00"
  def only_emp_sync
    @factory = my_factory
    date = params[:search_date].to_date
    #00-23点
    _start = date
    _end = date + 1
    #mysql 得取>= ,sqlite >
    @emp_infs = @factory.emp_infs.where(["pdt_time >= ? and pdt_time < ?", _start, _end])
    @emp_effs = @factory.emp_effs.where(["pdt_time >= ? and pdt_time < ?", _start, _end])

    search_str = "
      ifnull(count(id), 0) counts,
      ifnull(ROUND(avg(nullif(cod, 0))   , 2), 0) cod,
      ifnull(ROUND(avg(nullif(nhn, 0))   , 2), 0) nhn,
      ifnull(ROUND(avg(nullif(tp, 0))    , 2), 0) tp,
      ifnull(ROUND(avg(nullif(tn, 0))    , 2), 0) tn,
      ifnull(ROUND(avg(nullif(ph, 0))    , 2), 0) ph,
      ifnull(ROUND(avg(nullif(temp, 0))  , 2), 0) temp,
      ifnull(ROUND(sum(nullif(flow, 0))  , 2), 0) flow
    "
    emp_inf_stc = @emp_infs.select(search_str) 
    emp_eff_stc = @emp_effs.select(search_str) 
    inf = emp_inf_stc[0]
    eff = emp_eff_stc[0]

    state = 'success'
    info = ''

    if inf.counts > 0
      inf_avg_cod  = inf.cod
      inf_avg_nhn  = inf.nhn
      inf_avg_tp   = inf.tp
      inf_avg_tn   = inf.tn
      inf_avg_ph   = inf.ph
      inf_avg_temp = inf.temp
      inf_sum_flow = inf.flow
      @inf_qlty = {
        :cod => inf_avg_cod, 
        :nhn => inf_avg_nhn, 
        :tp  => inf_avg_tp , 
        :tn  => inf_avg_tn , 
        :ph  => inf_avg_ph , 
        :inflow => inf_sum_flow
      }
    else
      state = "error"
      info = "进水口数据 "
    end

    if eff.counts > 0
      eff_avg_cod  = eff.cod
      eff_avg_nhn  = eff.nhn
      eff_avg_tp   = eff.tp
      eff_avg_tn   = eff.tn
      eff_avg_ph   = eff.ph
      eff_avg_temp = eff.temp
      eff_sum_flow = eff.flow
      @eff_qlty = {
        :cod => eff_avg_cod, 
        :nhn => eff_avg_nhn, 
        :tp  => eff_avg_tp , 
        :tn  => eff_avg_tn , 
        :ph  => eff_avg_ph ,
        :outflow => eff_sum_flow 
      }
    else
      state = "error"
      info += "出水口数据 "
    end
    result = {
      :inf => @inf_qlty,
      :eff => @eff_qlty,
      :state => state,
      :info => info
    }

    respond_to do |f|
      f.json{ render :json => result.to_json}
    end
  end

  def emp_sync
    @factory = my_factory
    @day_pdt = @factory.day_pdts.find(iddecode(params[:id]))
    @inf_qlty = @day_pdt.inf_qlty
    @eff_qlty = @day_pdt.eff_qlty
    @pdt_sum  = @day_pdt.pdt_sum

    date = @day_pdt.pdt_date
    _start = date.to_s + "00:10:00"
    _end = (date + 1).to_s + "00:10:00"
    @emp_infs = @factory.emp_infs.where(["pdt_time >= ? and pdt_time < ?", _start, _end])
    @emp_effs = @factory.emp_effs.where(["pdt_time >= ? and pdt_time < ?", _start, _end])

    search_str = "
      ifnull(count(id), 0) counts,
      ifnull(ROUND(avg(nullif(cod, 0))   , 2), 0) cod,
      ifnull(ROUND(avg(nullif(nhn, 0))   , 2), 0) nhn,
      ifnull(ROUND(avg(nullif(tp, 0))    , 2), 0) tp,
      ifnull(ROUND(avg(nullif(tn, 0))    , 2), 0) tn,
      ifnull(ROUND(avg(nullif(ph, 0))    , 2), 0) ph,
      ifnull(ROUND(avg(nullif(temp, 0))  , 2), 0) temp,
      ifnull(ROUND(avg(nullif(flow, 0))  , 2), 0) flow
    "
    emp_inf_stc = @emp_infs.select(search_str) 
    emp_eff_stc = @emp_effs.select(search_str) 
    inf = emp_inf_stc[0]
    eff = emp_eff_stc[0]

    state = 'success'
    info = ''

    if inf.counts > 0
      inf_avg_cod  = inf.cod
      inf_avg_nhn  = inf.nhn
      inf_avg_tp   = inf.tp
      inf_avg_tn   = inf.tn
      inf_avg_ph   = inf.ph
      inf_avg_temp = inf.temp
      inf_sum_flow = inf.flow
      inf_qlty = {
        :cod => inf_avg_cod, 
        :nhn => inf_avg_nhn, 
        :tp  => inf_avg_tp , 
        :tn  => inf_avg_tn , 
        :ph  => inf_avg_ph , 
        :inflow => inf_sum_flow
      }
      @inf_qlty.update_attributes(inf_qlty)
      @pdt_sum.update_attributes(:inflow => inf_sum_flow)
    end

    if eff.counts > 0
      eff_avg_cod  = eff.cod
      eff_avg_nhn  = eff.nhn
      eff_avg_tp   = eff.tp
      eff_avg_tn   = eff.tn
      eff_avg_ph   = eff.ph
      eff_avg_temp = eff.temp
      eff_sum_flow = eff.flow
      eff_qlty = {
        :cod => eff_avg_cod, 
        :nhn => eff_avg_nhn, 
        :tp  => eff_avg_tp , 
        :tn  => eff_avg_tn , 
        :ph  => inf_avg_ph , 
        :inflow => inf_sum_flow
      }
      @eff_qlty.update_attributes(eff_qlty)
      @pdt_sum.update_attributes(:outflow => eff_sum_flow)
    end

    redirect_to edit_factory_day_pdt_path(idencode(@factory.id), idencode(@day_pdt.id)) 
  end
   
  def edit
    @factory = my_factory
    @day_pdt = @factory.day_pdts.find(iddecode(params[:id]))
  end

  def update
    @factory = my_factory
    @day_pdt = @factory.day_pdts.find(iddecode(params[:id]))
    day_pdt = @factory.day_pdts.where(['id != ? and pdt_date = ?', @day_pdt.id, day_pdt_params[:pdt_date]]).first
    day_pdt_rpt = @factory.day_pdt_rpts.where(:pdt_date => day_pdt_params[:pdt_date]).first

    if day_pdt || day_pdt_rpt
      @day_pdt.errors[:date_error] = day_pdt_params[:pdt_date] + "运营数据已存在,请重新填报"
      render :edit
    else
      @day_pdt.name = day_pdt_params[:pdt_date].to_s + @factory.name + "生产运营报表"

      if @day_pdt.update(day_pdt_params)
        cal_per_cost(@day_pdt)
        redirect_to factory_day_pdt_path(idencode(@factory.id), idencode(@day_pdt.id)) 
      else
        render :edit
      end
    end
  end

  def cal_per_cost(day_pdt)
    inflow = day_pdt.pdt_sum.inflow
    per_cost = 0
    day_pdt.chemicals.each do |c|
      per_cost += c.update_ptc(inflow)
    end
    day_pdt.pdt_sum.update_per_cost(per_cost)
  end
   
  #def destroy
  #  @factory = my_factory
  #  @day_pdt = @factory.day_pdts.find(iddecode(params[:id]))
  # 
  #  @day_pdt.destroy
  #  redirect_to :action => :index
  #end
  

  private
    def day_pdt_params
      params.require(:day_pdt).permit( :pdt_date, :name, :signer, :weather, :min_temper, :max_temper, :desc , enclosures_attributes: enclosure_params, inf_qlty_attributes: inf_qlty_params, eff_qlty_attributes: eff_qlty_params, sed_qlty_attributes: sed_qlty_params, pdt_sum_attributes: pdt_sum_params, tspmuds_attributes: tspmud_params, chemicals_attributes: chemical_params)
    end
  
    def enclosure_params
      [:id, :file, :_destroy]
    end

    def inf_qlty_params
      [:id, :bod, :cod, :ss, :nhn, :tn, :tp, :ph , :asy_cod, :asy_nhn, :asy_tp, :asy_tn, :_destroy]
    end
  
    def eff_qlty_params
      [:id, :bod, :cod, :ss, :nhn, :tn, :tp, :ph, :fecal , :asy_cod, :asy_nhn, :asy_tp, :asy_tn, :_destroy]
    end
  
    def sed_qlty_params
      [:id, :bod, :cod, :ss, :nhn, :tn, :tp, :ph , :asy_cod, :asy_nhn, :asy_tp, :asy_tn, :_destroy]
    end
  
    def pdt_sum_params
      [:id, :inflow, :outflow, :inmud, :outmud, :mst, :power, :mdflow, :mdrcy, :mdsell ,:_destroy]
    end
    def tspmud_params
      [:id, :tspvum, :dealer, :rcpvum, :price, :prtmtd, :goort ,:_destroy]
    end
  
    def chemical_params
      [:id, :name, :unprice, :cmptc, :dosage , :dosptc, :per_cost, :_destroy]
    end

end

