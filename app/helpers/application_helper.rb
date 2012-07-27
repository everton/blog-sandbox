module ApplicationHelper
  def action_title(title)
    content_for :page_title, title
    content_tag  :h1, title
  end
end
