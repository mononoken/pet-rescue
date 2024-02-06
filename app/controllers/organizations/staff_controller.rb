class Organizations::StaffController < Organizations::BaseController
  before_action :set_staff_account, only: [:deactivate, :activate, :update_activation]

  layout "dashboard"

  def index
    authorize! StaffAccount, with: Organizations::StaffPolicy

    @staff_accounts = authorized_scope(
      StaffAccount.all,
      with: Organizations::StaffPolicy
    )
  end

  def deactivate
    @staff_account.deactivate
    respond_to do |format|
      format.html { redirect_to staff_index_path, notice: "Staff account deactivated." }
      format.turbo_stream { render "organizations/staff/update" }
    end
  end

  def activate
    @staff_account.activate
    respond_to do |format|
      format.html { redirect_to staff_index_path, notice: "Staff account activated." }
      format.turbo_stream { render "organizations/staff/update" }
    end
  end

  def update_activation
    if @staff_account.deactivated_at
      activate
    else
      deactivate
    end
  end

  private

  def set_staff_account
    @staff_account = StaffAccount.find(params[:staff_id])

    authorize! @staff_account, with: Organizations::StaffPolicy
  end
end
