class Parse

  def initialize(lines, cursor)
    @lines = lines
    @cursor = cursor
  end

  def update_line(key, key_code)
    case key_code
      when 16
        #do nothing because shift was pressed
      when 10 #after return ad a new line
        #check cursor for new line position
        @lines.new_or_next_line(@cursor)
      when 8
        @lines.delete_last_key(@cursor.y_position)
      else
        string_object = @lines.on_position_of(@cursor)
        #update line key
        string_object.append(key) if string_object
    end
  end
end