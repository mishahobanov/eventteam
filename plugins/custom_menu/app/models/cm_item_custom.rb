class CmItemCustom < CmItem

  validates :caption, presence: true

  def item_text(view, opts, *args)
    cl = opts.delete(:class)
    opts = (self.options || {}).merge(opts)
    opts[:class] = [opts[:class]]
    opts[:class] << 'no_line'
    opts[:class] << cl if cl.present?
    opts[:class] << "rm-icon " + self.icon.to_s if self.icon.present?
    opts[:class] = opts[:class].join(' ')

    link = self.custom_url.to_s

    unless link.match('^(http|https)://')
      link = Redmine::Utils.relative_url_root + link
    end

    self.custom_url.present? || !self.leaf? ? view.link_to("<span>#{self.caption}</span>".html_safe, link, opts) : "<span>#{self.caption}</span>".html_safe
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
    return false unless (!self.logged || User.current.logged?) && (self.visibility != CmItem::VISIBILITY_ADMIN || User.current.admin?)

    super(project, from_parent)
  end
end