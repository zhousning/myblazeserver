class WxUsersController < ApplicationController
  skip_before_action :verify_authenticity_token

  def get_userid
    resource = User.find_for_database_authentication(phone: params[:username])
    return render :json => {:success => false} unless resource

    if resource.valid_password?(params[:password])
      openid = resource.number
      user_name = resource.name

      #角色代码jd 
      #厂区数据填报 2 
      #厂区数据审核 0 
      #厂区管理者 1 
      #厂区领导 3
      #集团运营集团管理者 4
      jd = nil
      if user.has_role?(Setting.roles.day_pdt_verify) 
        jd = 0
      elsif user.has_role?(Setting.roles.day_pdt_cmp_verify) 
        jd = 1
      elsif user.has_role?(Setting.roles.day_pdt) 
        jd = 2 
      elsif user.has_role?(Setting.roles.role_fct) 
        jd = 3
      elsif user.has_role?(Setting.roles.role_grp) 
        jd = 4
      end
      return render :json => {:success => true, :openid => openid, :user_name => user_name, :jd => jd}
    else
      return render :json => {:success => false}
    end
  end
end
