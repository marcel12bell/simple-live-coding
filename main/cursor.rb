class Cursor
include Processing::Proxy

  def initialize(line)
    @line = line
    @x = $app.start_of_editor_text
    @y = $app.editor_top_margin
  end

  def set_position(x,y) #on mouse down
    unless @line.positiontable(y) == :undefined
      @x, @y = @line.position(x,y) #returns current line position
    end
  end

  def get_position
    [@x, @y]
  end

  def y_position
    @y
  end

  def draw_line
    if editor_line
    current_content = @line.current_content(@y)
    line @x+text_width(current_content), 
         @y+2, @x+text_width(current_content), @y-12
    end
  end

  def go_to_new_line #after tap enter button
    @y += $app.line_height+$app.line_space
  end

  private
  def editor_line
    #return true, if the is a line to edit on
    @line.positiontable(@y) == :undefined ? false : true
  end

end