class GroupsController < ApplicationController
  before_action :authenticate_current_user!
  before_action :set_link_presenter, only: [:show]
  
  def index
    @title = 'Your groups'
    @groups = current_user.groups
  end
  
  def new
    @group = Group.new
  end
  
  def edit
    @group = Group.find(params[:id])
  end
  
  def update
    @group = Group.find(params[:id])
    valid_group = @group.update_attributes(group_params)
    return render 'edit' unless valid_group
    
    send_invites
  end
  
  def create
    @group = Group.new(group_params)
    valid_group = @group.save
    return render 'new' unless valid_group
    
    GroupsUser.create(user: current_user, group: @group)
    send_invites
  end

  def show
    @group = Group.find(params[:id])
    @title = @group.name
    @links = Link.where(:group_id => @group.id).order(created_at: :desc).paginate(:page => params[:page])
    @days = @links.group_by { |t| t.created_at.beginning_of_day }
    @invalid_emails = params[:invalid_emails]
    @pending_invites = @group.invites.pending
  end

  private
    def send_invites
      @group.emails = params[:group][:emails]
      request = Invitation::Request.new(referrer: current_user, group: @group)
      request.send(emails: @group.emails) do |on|
        on.invalid_email do |email|
          flash[:alert] = "Could not send an email to #{email} : invalid email address. Please check this email address"
          return render 'edit'
        end
        
        on.on_invite_already_exist do |email|
          flash[:alert] = "Could not send an email to #{email} : invitation already sent. You can resend the invite within the pending invitation list"
          return render 'edit'
        end
        
        on.valid_emails do
          flash[:info] = "Group #{@group.name} was created"
          return redirect_to groups_url
        end
      end
    end
  
    def group_params
      params.require(:group).permit(:name)
    end

  private

  def set_link_presenter
    @link_presenter = LinkPresenter.new
  end
end
