class CmItemQuery < CmItem
  validates :caption, presence: true
  validates :query_id, presence: true

  belongs_to :issue_query, foreign_key: :query_id

  def item_text(view, opts, *args)
    cl = opts.delete(:class)
    opts = (self.options || {}).merge(opts)
    opts[:class] = [opts[:class]]
    opts[:class] << 'no_line'
    opts[:class] << cl if cl.present?
    opts[:class] << "rm-icon " + self.icon.to_s if self.icon.present?
    opts[:class] = opts[:class].join(' ')

    span = "<span>#{self.caption}</span>".html_safe

    if self.issue_query

      if Redmine::Plugin.installed?(:extra_queries) && self.issue_query.try(:eq_counter)
        span << User.current.acl_ajax_counter('eq_issues_count', { period: 300, params: { query_id: self.query_id }}).html_safe
        span << User.current.acl_ajax_counter('eq_issues_count', { period: 300, css: 'unread', params: { query_id: self.query_id, only: :unread }}).html_safe
        span << User.current.acl_ajax_counter('eq_issues_count', { period: 300, css: 'updated', params: { query_id: self.query_id, only: :updated }}).html_safe
      end

      view.link_to(span, { controller: :issues, action: :index, project_id: self.issue_query.project_id, query_id: self.query_id }, opts)
    else
      span
    end
  end

  def self.item_label(code)
    ''
  end

  def item_label
    self.caption
  end

  def can_edit?
    User.current.admin?
  end

  def visible?(project=nil, from_parent=false)
    self.issue_query.present? && self.issue_query.visible?(User.current) && super(project, from_parent)
  end

end