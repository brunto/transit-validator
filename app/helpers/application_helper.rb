module ApplicationHelper
  def active(controller, action = nil)
    ' class="active"'.html_safe if controller.to_sym == controller_name.to_sym && (!action || action.to_sym == action_name.to_sym)
  end

  def get_icon(name)
    return unless name.present?
    case name.to_sym.downcase
    when :error
      'minus-sign'
    when :warning
      'alert'
    when :ignored
      'ban-circle'
    else
      'ok-sign'
    end
  end
end
