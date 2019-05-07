module CustomMenu
  module MenuHelperPatch
    def self.included(base)
      base.send(:include, InstanceMethods)

      base.class_eval do
        alias_method_chain :render_menu, :custom_menu
      end
    end

    module InstanceMethods
      def render_menu_with_custom_menu(menu, project=nil)
        settings = Setting.plugin_custom_menu || {}
        if settings['use_custom_menu'] && %w(top_menu account_menu).include?(menu.to_s)
          if settings['use_cache']
            Rails.cache.fetch("custom_menu/#{User.current.id}/#{menu}/#{project.try(:identifier) || 'wholeprojects'}/user_menu", expires_in: 5.minutes) do
              render_custom_menu(menu, project)
            end
          else
            render_custom_menu(menu, project)
          end
        else
          render_menu_without_custom_menu(menu, project)
        end
      end
    end
  end
end

unless Redmine::MenuManager::MenuHelper.included_modules.include?(CustomMenu::MenuHelperPatch)
  Redmine::MenuManager::MenuHelper.send(:include, CustomMenu::MenuHelperPatch)
end