module CustomMenu
  class Hooks < Redmine::Hook::ViewListener
    render_on(:view_layouts_base_html_head, partial: 'hooks/custom_menu/html_head')
    render_on(:view_layouts_base_body_bottom, partial: 'hooks/custom_menu/view_layouts_base_body_bottom')
  end
end
