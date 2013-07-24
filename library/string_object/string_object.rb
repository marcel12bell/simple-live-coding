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