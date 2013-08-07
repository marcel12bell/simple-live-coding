class Lines

  def initialize
    @elements = []
    @line_height = $app.line_height
    @line_space = $app.line_space
    @positiontable = generate_hashtable
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
    [$app.start_of_editor_text, y]
  end

  def make_new_line(cursor)
      update_positiontable_with_new_line(cursor)
      cursor.go_to_new_line
  end

  def previous_line(cursor)
    cursor.go_to_previous_line unless first_line_of_editor(cursor.y_position)
  end

  def next_line(cursor)
    cursor.go_to_new_line unless last_line_of_editor(cursor.y_position)
  end

  def elements
    @elements
  end

  def current_content(y)
    @positiontable[y].content
  end

  def delete_last_key(cursor)
    y = cursor.y_position
    if @positiontable[y].content.empty?
      cursor.go_to_previous_line unless first_line_of_editor(y)
    else
      @positiontable[y].delete
    end
  end


  private
  def initialize_positiontable
    str_obj = StringObject.new("")
    @elements << str_obj
    begin_of_line = 0
    line_range = [begin_of_line..@line_height + @line_space]
    str_obj.set_position = line_range
    @positiontable.update({ line_range[0] => str_obj })
  end

  def last_line_of_editor(y)
    @positiontable[y] == @elements.last
  end

  def first_line_of_editor(y)
    @positiontable[y] == @elements.first
  end

  def update_positiontable_with_new_line(cursor)
    @new_positiontable = generate_hashtable #make new one becouse of content generated on mouseover
    string_object = StringObject.new("")
    position = line_number(on_position_of(cursor))
    @elements.insert(position, string_object )
    @elements.each_with_index do |e , idx|
      line_range = find_position_range(idx)
      e.set_position = line_range
      @new_positiontable.update({ line_range[0] => e })
    end
    @positiontable = @new_positiontable
  end

  def generate_hashtable
    Hash.new {|this_hash,missing_key|
      found_key = this_hash.keys.find { |this_key|
            this_key.class == Range && this_key.include?(missing_key) }
      found_key ? this_hash[missing_key] = this_hash[found_key] : :undefined
      }#source: http://www.developwithpurpose.com/ruby-hash-awesomeness-part-2/
  end

  def find_position_range(idx)
    begin_of_line = (@line_height + @line_space) * idx
    line_range = [begin_of_line..begin_of_line + @line_height + @line_space]
    return line_range
  end

  def line_number(str_obj) #begins with 0!!
    str_obj.position.first.last/(@line_height + @line_space)
  end
end