class Watch
  def initialize(lines, description, cursor)
    @lines = lines
    @description = description
    @cursor = cursor
  end

  def check_line(x, y)
    if x > ($app.width/2) + $app.editor_left_margin
      if @lines.positiontable(y) == :undefined
        @description.position = [-50] # set it outside the view field
      else
        @description.position = @lines.positiontable(y).get_position
      end
    end
  end


  def check_param(x,y)
    y_position = @cursor.y_position
    string_object = @lines.positiontable(y_position)
    if (string_object.position[0]).include?($app.pressed[1])
      string_object.update_param(x,y) unless string_object == :undefined
    end
  end

  def get_param(x,y)
    y_position = @cursor.y_position
    string_object = @lines.positiontable(y_position)
    string_object.get_param_values unless string_object == :undefined
  end
end