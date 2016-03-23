module ApplicationHelper
  def active(current_menu, menu)
    ' class="active"'.html_safe if current_menu == menu
  end

  def active_controller(controller)
    ' class="active"'.html_safe if controller.to_sym == controller_name.to_sym
  end

  def get_icon(name, count_error=nil)
    return 'question-sign' unless name.present?
    case name.to_sym.downcase
    when :error
      (count_error > 0 ? 'minus-sign' : 'alert')
    when :warning
      'alert'
    when :ignored
      'ban-circle'
    else
      'ok-sign'
    end
  end
end
