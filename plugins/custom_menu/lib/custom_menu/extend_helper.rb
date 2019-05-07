module CustomMenu
  module ExtendHelper
    def render_custom_menu(menu, project=nil)
      menu_items = CmItem.preload(:parent).where(menu: menu.to_s).order("#{CmItem.table_name}.lft").visible(project)

      if menu_items.blank? && menu.to_s == 'top_menu'
        menu_items = [CmItemCustom.new(caption: l(:label_administration), custom_url: url_for(controller: :admin, action: :index))] if User.current.admin?
      else
        menu_items = menu_items.select { |it| it.visible?(project) }
      end

      return nil if menu_items.blank?
      chain = []

      html = '<ul class="cm-menu-header">'

      menu_items.each do |it|
        while chain.size > 0 && !it.is_descendant_of?(chain.last)
          html << '</ul></li>'
          chain.pop
        end

        html << '<li'

        opts = {}
        if it.rgt.to_i - it.lft.to_i > 1
          html << ' class="dropdown"'
          opts = { data: { toggle: 'dropdown' }, class: 'dropdown-toggle in_link' }
        end

        html << '>'

        item = it.item_text(self, opts, project).to_s
        if item.blank?
          html << l(:label_cm_not_available)
        else
          html << item
        end

        if it.rgt.to_i - it.lft.to_i > 1
          html << '<ul data-for-item="' + it.id.to_s + "\" class=\"dropdown-menu #{ 'cm_expand_menu' if it.children.where("icon is not NULL and icon <> ''").any?}\" role=\"menu\" aria-labelledby=\"dLabel\">"
          chain << it
        else
          html << '<ul></ul>' if chain.size == 0
          html << '</li>'
        end
      end

      html << '</ul></li>' * chain.size
      html << '</ul>'
      html.html_safe
    end
  end
end

unless ActionView::Base.included_modules.include?(CustomMenu::ExtendHelper)
  ActionView::Base.send(:include, CustomMenu::ExtendHelper)
end