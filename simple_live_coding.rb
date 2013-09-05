require 'ruby-processing'

class RubyDraw < Processing::App

  require_relative 'main/string_object'
  require_relative 'main/lines'
  require_relative 'main/cursor'
  require_relative 'main/parse'
  require_relative 'main/description_list'
  require_relative 'main/editor'
  require_relative 'main/canvas'
  require_relative 'main/watch'

  attr_reader :editor_left_margin, :editor_right_margin, :editor_top_margin, :start_of_editor_text, :line_height, :line_space, :pressed, :initial_param

  def setup
    size 700, 600 # access with $app.width
    @editor_left_margin = 10
    @editor_right_margin = 15
    @editor_top_margin = 15
    @start_of_editor_text = 350
    @line_height = 13
    @line_space = 2
    @pressed = false #check if mouse pressed

    @lines = Lines.new
    @cursor = Cursor.new(@lines)
    @parser = Parse.new(@lines, @cursor)
    @description = DescriptionList.new(@parser)
    @editor = Editor.new(@lines, @description)
    @canvas = Canvas.new(@lines)
    @watcher = Watch.new(@lines, @description, @cursor)
    no_loop
    #smooth
    #frameRate 25

    #initial drawing for testing:
    "rect 20, 30, 30, 40".chars.each{ |c| @parser.update_line(c, 0) }
  end
  
  def draw
    background 55
    @canvas.draw_canvas
    fill color 304, 353, 300
    rect ($app.width/2)-10,0,($app.width/2)+10,height
    fill color 104, 153, 0
    @editor.draw_content

    text mouse_x.to_s, $app.width/2, $app.height-60
    text "this is a DEMO app", $app.width/2, $app.height-40
    text "write 'rect 20, 20, 200, 200' and drag the values...", $app.width/2, $app.height-20

    fill color 14, 13, 0
    @cursor.draw_line #we need a line marking the text position
    fill color 104, 153, 0

    if mouse_pressed?
      sleep(0.12) #needed because of unintented param change line selection 
      loop
      @watcher.check_param(mouse_x, mouse_y)
    else
      @pressed = false
      no_loop
    end
      
  end

  def key_pressed
    @parser.update_line(key, key_code)
    redraw
  end

  def mouse_moved
    @watcher.check_line(mouse_x, mouse_y) #explanation feature
    redraw
  end

  def mouse_pressed
    @pressed = [mouse_x, mouse_y]
    @cursor.set_position(mouse_x, mouse_y)
    @initial_param = @watcher.get_param(mouse_x, mouse_y) #get the initial value from watcher
    redraw
  end

end

RubyDraw.new :title => "simple_live_coding"