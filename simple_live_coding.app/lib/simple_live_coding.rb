require 'ruby-processing'

class StringObject
  #Each line is an object
  include Processing::Proxy

  attr_accessor :content, :position

  def initialize(s)
    @content = s
    @object_list = [methode, arguments || [] ]
    @position = [0..0]
   end

  def append(key)
    @content += key.to_s
    @object_list = [methode, arguments]
  end

  def delete #last Char
    @content.chop!
    @object_list = [methode, arguments]
  end

  def methode
    @content.split.to_a[0]
  end

  def arguments
    array = @content.split.to_a
    #splits the string after the methode into arguments array
    (array.count > 2) ? array.map{ |e| e.to_i}[1..-1] : []
  end

  def update_argument(x_mouse, y_mouse)
    update_argument_position
    arg = find_argument($pressed[0])
    if arg
      new_arg_value = -$width/2+x_mouse+$editor_left_margin-length((methode+ " ").to_s)-length(@object_list[1][0..arg].join(" ").to_s)+$initial_arg_value
      @object_list[1][arg] = new_arg_value
      @content = @object_list.first + " " + @object_list[1].join(" ") + "\n" if @object_list.first
    end
  end

  def get_param_value(x,y)
    #get the rigth param of x position and give the value back
    arg = find_argument(x)
    if arg 
      value = @object_list[1][arg]
    else
      value = 0
    end
    return value
  end

  def set_position=(range)
    @position = range
  end

  def get_position
    #get the first nuber of an range x..y
    @position.to_a.first
  end

  private

    def length(s)
      text_width(s.to_s).to_i unless s.nil?
    end

    def update_argument_position
      start_position = $width/2+$editor_left_margin+length((methode).to_s)
      arg_length_new = 0
      space = length(" ")
      @argument_position = Hash.new {|this_hash,missing_key| #set always a new hash to keep track of growing numbers
      found_key = this_hash.keys.find {|this_key| this_key.class == Range && this_key.include?(missing_key) }
      found_key ? this_hash[missing_key] = this_hash[found_key] : :undefined
      } #source: http://www.developwithpurpose.com/ruby-hash-awesomeness-part-2/
      arguments.each_with_index do |value, k|
          arg_length = length(value)
          arg_range = [
            start_position+arg_length_new..
            start_position+arg_length_new+arg_length
          ]
          @argument_position[arg_range[0]] = k
          arg_length_new = arg_length_new + arg_length + space
        end
    end

    def find_argument(x_position)
      #return argument on rigth position
      update_argument_position # first initialisation on mouse down
      arg = @argument_position[x_position]
      arg unless arg == :undefined
    end
end

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


class Cursor
include Processing::Proxy

  def initialize(line)
    @line = line
    @x, @y = $start_of_editor_text, $editor_top_margin
  end

  def set_position(x,y) #on mouse down
    unless @line.positiontable(y) == :undefined
      @x, @y = @line.position(x,y) #returns current line position
    end
  end

  def get_position
    return @x, @y
  end

  def y_position
    return @y
  end

  def draw_line
    if editor_line
    current_content = @line.current_content(@y)
    line @x+text_width(current_content), 
         @y+2, @x+text_width(current_content), @y-12
    end
  end

  def go_to_new_line #after tap enter button
    @y += $line_height+$line_space
  end

  private
  def editor_line
    #return true, if the is a line to edit on
    @line.positiontable(@y) == :undefined ? false : true
  end

end


class Parse

  def initialize(lines, cursor)
    @lines = lines
    @cursor = cursor
  end

  def update_line(key, key_code)
    case key_code
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


class DescriptionList
  include Processing::Proxy
  def initialize(parser)
    @parser = parser
    @explanation = "explain" ## refr to explanList
    @yposition =  [-50]#out ov view
  end



  def set_explanation=(text)
    @explanation = text
  end

  def explanation
    @explanation
  end

  def position=(n)
    #get first number of a range the text y position
    @yposition = n
  end

  def position
    #get first number of a range the text y position
    @yposition.to_a.first
  end

  def explanation_length
    text_width(@explanation.to_s) unless @explanation.nil?
  end

end


class Editor
  include Processing::Proxy

  def initialize(lines, description)
    @lines = lines
    @description = description
  end

  def draw_content
    draw_text
    fill color(14, 13, 0)
    draw_explanation
    fill color(104, 153, 0)
  end

  def draw_text
    @lines.elements.each do |e|
        e.each_pair do |key, string_object| 
            eval("text '#{string_object.content}',
                         #{$width/2},
                         #{string_object.get_position.to_a.last}")
        end
    end
  end

  def draw_explanation
      return eval("text '#{@description.explanation}', 
                         #{$width-@description.explanation_length-$editor_right_margin}, 
                         #{@description.position+$editor_top_margin}")

  end
end


class Canvas
include Processing::Proxy

  def initialize(lines)
    @lines = lines
  end

  def draw_canvas
    elements = @lines.elements
    elements.each do |e|
      e.each_pair{|key, line| 
        send_if_runnable(line.methode, line.arguments) if line.methode
      }
    end
  end


  private

  def send_if_runnable(methode, args)
    begin
      send(methode.to_s, *args)
    rescue Exception => e
      puts "#{ e } (#{ e.class })!"
    end
  end

end


class Watch
  def initialize(lines, description, cursor)
    @lines = lines
    @description = description
    @cursor = cursor
  end

  def check_line(x, y)
    if x > ($width/2) + $editor_left_margin
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
    if (string_object.position[0]).include?($pressed[1])
      string_object.update_argument(x,y) unless string_object == :undefined
    end
  end

  def get_param(x,y)
    y_position = @cursor.y_position
    string_object = @lines.positiontable(y_position)
    string_object.get_param_value(x,y_position) unless string_object == :undefined
  end

end


class RubyDraw < Processing::App

#load_library 'string_object', 'lines', 'cursor', 'parse', 'description_list', 'editor', 'canvas', 'watch'

  def setup
    $width = 700
    $height = 600
    $editor_left_margin = 10
    $editor_right_margin = 15
    $editor_top_margin = 15
    $start_of_editor_text = $width/2
    $line_height = 13
    $line_space = 2


    size 700, 600 # needs to be hardcoded
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
  end
  
  def draw
    background 55
    @canvas.draw_canvas
    fill color 304, 353, 300
    rect ($width/2)-10,0,($width/2)+10,height
    fill color 104, 153, 0
    @editor.draw_content


    text "this is a DEMO app", $width/2, $height-40
    text "write 'rect 20 20 200 200' and drag the values...", $width/2, $height-20

    fill color(14, 13, 0)
    @cursor.draw_line
    fill color(104, 153, 0)

    if mouse_pressed?
      loop
      @watcher.check_param(mouse_x, mouse_y)
    else
      $pressed = false
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
    $pressed = [mouse_x, mouse_y]
    $initial_arg_value = @watcher.get_param(mouse_x, mouse_y) #get the initial value from watcher
    @cursor.set_position(mouse_x, mouse_y)
    redraw
  end

end

RubyDraw.new :title => "simple_live_coding"
