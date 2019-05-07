Redmine::Plugin.register :custom_menu do
  name 'Custom Menu Redmine'
  author 'Kovalevskiy Vasil, Danil Kukhlevskiy'
  description 'This is a plugin for Redmine changable top menu'
  version '1.8.6'
  url 'http://rmplus.pro/redmine/plugins/custom_menu'
  author_url 'http://rmplus.pro/'

  requires_redmine '3.4.1'

  settings partial: 'settings/custom_menu',
           default: {}

  menu :custom_menu, :cm_all_projects, {controller: 'projects', action: 'index'}, caption: :cm_all_projects, if: Proc.new { User.current.logged? }, html: {class: 'no_line'}
  menu :custom_menu, :my_name, '#', caption: Proc.new { ('<span>' + User.current.name + '</span>').html_safe }, if: Proc.new { User.current.logged? }, html: {class: 'in_link'}
  menu :custom_menu, :cm_search, nil, caption: Proc.new { CmItem.cm_search }, if: Proc.new { true }
  menu :custom_menu, :cm_project_tree, nil, caption: Proc.new { CmItem.redner_menu_projects_tree }, if: Proc.new { User.current.logged? }
  menu :custom_menu, :cm_my_activity, nil, caption: Proc.new { CmItem.cm_my_activity }, if: Proc.new { User.current.logged? }


  menu :admin_menu, :cm_menu, { controller: 'cm_menu', action: 'index' }, caption: :label_cm_admin_menu_item, html: { class: 'icon' }
end

Rails.application.config.to_prepare do
  unless ApplicationHelper.included_modules.include?(CustomMenu::ApplicationHelperPatch)
    ApplicationHelper.send :include, CustomMenu::ApplicationHelperPatch
  end

  require 'custom_menu/view_hooks'
  require_dependency 'custom_menu/extend_helper'

  Acl::Settings.append_setting('enable_select2_lib', :custom_menu)
  Acl::Settings.append_setting('enable_bootstrap_lib', :custom_menu)
  Acl::Settings.append_setting('enable_modal_windows', :custom_menu)
  Acl::Settings.append_setting('enable_font_awesome', :custom_menu)
end

Rails.application.config.after_initialize do
  require 'custom_menu/menu_item_patch'
  require 'custom_menu/menu_helper_patch'

  plugins = { a_common_libs: '2.5.3', extra_queries: { require: false, version: '2.3.7' } }
  plugin = Redmine::Plugin.find(:custom_menu)
  plugins.each do |k,v|

    if v.is_a?(Hash)
      version = v[:version]
      require = v[:require]
    else
      version = v
      require = false
    end

    begin
      if require || Redmine::Plugin.installed?(k)
        plugin.requires_redmine_plugin(k, version)
      end
    rescue Redmine::PluginNotFound => ex
      raise(Redmine::PluginNotFound, "Plugin requires #{k} not found")
    end
  end
end