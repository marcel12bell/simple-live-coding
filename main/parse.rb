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
        @lines.make_new_line(@cursor)
      when 8
        @lines.delete_last_key(@cursor)
      when 38 #up
        @lines.previous_line(@cursor)
      when 40 #down
        @lines.next_line(@cursor)

      when 37 #left
      when 39 #right
      when 157 #command
      when 17 #ctrl
      when 18 #alt
        
      else
        string_object = @lines.on_position_of(@cursor)
        #update line key
        string_object.append(key) if string_object
    end
  end
end