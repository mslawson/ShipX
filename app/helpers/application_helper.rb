module ApplicationHelper
  def group_class(resource, field_name)
    if resource.errors[field_name].length > 0
      return "has-error".html_safe
    else
      return "".html_safe
    end
  end
end
