class Lines

  def initialize
    @elements = []
    @line_height = $line_height
    @line_space = $line_space
    @positiontable = Hash.new {|this_hash,missing_key| 
      found_key = this_hash.keys.find { |this_key| 
            this_key.class == Range && this_key.include?(missing_key) }
      found_key ? this_hash[missing_key] = this_hash[found_key] : :undefined
      } #source: http://www.developwithpurpose.com/ruby-hash-awesomeness-part-2/
    initialize_positiontable
  end

  def on_position_of(cursor) # refr with y_position??
    #parser position returns line element
    @positiontable[cursor.y_position]
  end

  def positiontable(y) #needed? in watcher.. and Cursor refr
    @positiontable[y]
  end

  def position(x,y)
    #get the linge and extract x, y param
    line_range = @positiontable[y].get_position
    y = line_range.to_a.last
    return $start_of_editor_text, y
  end

  def new_or_next_line(cursor)
    if last_line_of_editor(cursor.y_position)
      update_positiontable_with_new_line
      cursor.go_to_new_line
    else
      cursor.go_to_new_line
    end
  end

  def elements
    @elements
  end

  def current_content(y)
    @positiontable[y].content
  end

  def delete_last_key(y)
    @positiontable[y].delete
  end


  private

  def initialize_positiontable
    begin_of_line = 0
    line_range = [begin_of_line..@line_height + @line_space]
    string_object = StringObject.new("")
    string_object.set_position = line_range
    @elements << { line_range[0] => string_object }
    @elements.each do |e| #should wok with first
      @positiontable.update(e)
    end
  end

  def last_line_of_editor(y)
    @positiontable[y] == @elements.last.to_a.last.last #ugly
  end

  def update_positiontable_with_new_line
    #create_line_element with position range
    begin_of_line = @line_height + @line_space
    begin_of_line *= @elements.count if @elements
    line_range = [begin_of_line..begin_of_line + @line_height + @line_space]
    string_object = StringObject.new("")
    string_object.set_position = line_range
    @elements << { line_range[0] => string_object }
    @elements.each do |e|
      @positiontable.update(e)
    end
  end

end