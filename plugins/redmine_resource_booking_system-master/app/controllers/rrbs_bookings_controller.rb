class RrbsBookingsController < ApplicationController
  unloadable
  before_action :find_user, :find_project

  def initialize
    super()    #body�ȊO��redmine view���p��
    
    if Rails::VERSION::MAJOR < 3
      @base_url = Redmine::Utils::relative_url_root
    else
      @base_url = config.relative_url_root
    end
  end

  def index
    #�ݒ肳�ꂽ�e�[�u����ǂݍ���
    @rrbs_setting = RrbsSetting.find_by(project_id: @project.id)
    @rrbs_start_time = CustomField.find_by_id(@rrbs_setting.custom_field_id_start).possible_values
    @rrbs_end_time =  CustomField.find_by_id(@rrbs_setting.custom_field_id_end).possible_values
    aaa = CustomFieldEnumeration.where(active: '1').where(custom_field_id: @rrbs_setting.custom_field_id_room)
    @rrbs_resources = aaa.sort_by{|c| c.position }.collect { |c| [c.name, c.id] }
    @issue_status_ids = IssueStatus.where(id: [@rrbs_setting.issue_status_id_book, @rrbs_setting.issue_status_id_progress, @rrbs_setting.issue_status_id_complete]).collect { |c| [c.name, c.id] }
    
    @events = Issue.where("tracker_id = ?", @rrbs_setting.tracker_id)
    @events_book = @events.where("status_id = ?", @rrbs_setting.issue_status_id_book)
    @events_progress = @events.where("status_id = ?", @rrbs_setting.issue_status_id_progress)
    @events_progress = @events_progress.where("project_id = ?", @rrbs_setting.project_id)
    
    @user_is_manager = 0
    if User.current.allowed_to?(:edit_project, @project) 
      @user_is_manager = 1
    end
    
    @assignable_users = @project.assignable_users.collect { |user| [user.name, user.id] }
    
    @api_key = User.current.api_key
    unless User.current.allowed_to?(:view_issues, @project)
      render_403
    end
    
    @user_can_add = User.current.allowed_to?(:add_issues, @project)
    @user_can_edit = User.current.allowed_to?(:edit_issues, @project)
    @user_can_delete = User.current.allowed_to?(:delete_issues, @project)
  end

  private

  def find_user
    @user = User.current
  end

  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  
end
