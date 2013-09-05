class StringObject
  #Each line is an object
  include Processing::Proxy

  attr_accessor :content, :position

  def initialize(s)
    @content = s
  end

  def append(key)
    @content += key.to_s
  end

  def delete #last Char
    @content.chop!
  end

  def methode
    @content.split.to_a[0]
  end

  def update_param(x_mouse, y_mouse)
    #Try to find beginn of param and set this as the char_position to prevent unintendet param change!!!
    char_position = find_char($app.pressed[0]) 
    found_number = find_number(char_position) unless char_position.nil?
    if found_number and found_number != [0..0]
      new_param_value = -$app.width/2+x_mouse-length($app.initial_param[:string])+$app.initial_param[:value]
      begin_of_param = found_number[0].first
      current_param_length = @content[found_number[0]].to_s.length
      @content[begin_of_param, current_param_length] = new_param_value.to_s
    end
  end

  def get_param_values
    #get the rigth param of x position and give the value back
    char_position = find_char($app.pressed[0])
    if char_position
      found_number = find_number(char_position)[0]
      unless found_number == [0..0]
        number = @content[found_number].to_i
        #return string without begin of number (because it will change):
        string = @content[0..found_number.first-1]
        return { :value => number, :string => string }
      end
    end
  end

  def set_position=(range)
    #of the string in the editor
    @position = range
  end

  def get_position
    #get the first number of an range x..y
    @position.to_a.first
  end

  private

    def length(s)
      text_width(s.to_s).to_i unless s.nil?
    end

    def update_char_position
      start_position = $app.width/2
      char_length_new = 0
      @char_position = Hash.new {|this_hash,missing_key| #set always a new hash to keep track of growing numbers
      found_key = this_hash.keys.find {|this_key| this_key.class == Range && this_key.include?(missing_key) }
      found_key ? this_hash[missing_key] = this_hash[found_key] : :undefined
      } #source: http://www.developwithpurpose.com/ruby-hash-awesomeness-part-2/
      @content.chars.each_with_index  do |value, k|
          char_length = length(value)
          char_range = [
            start_position+char_length_new..
            start_position+char_length_new+char_length
          ]
          @char_position[char_range[0]] = k
          char_length_new = char_length_new + char_length
      end
    end

    def find_char(x_position)
      update_char_position
      char_position = @char_position[x_position]
      char_position unless char_position == :undefined
    end

    def find_number(start_position)
      #returns the range position of the selected number of the String (refr. to recursion--)
      left_position, right_position = start_position, start_position
      left_search, right_search = true, true
      while (left_search) or (right_search) and left_position > 0
        if @content[left_position].match(/^-?[0-9]?(\.[0-9]+)?$+/)
          left_position -=1
        else
          left_search = false
        end
        if !@content[right_position].nil? and @content[right_position].match(/^-?[0-9]?(\.[0-9]+)?$+/)
          right_position +=1
        else
          right_search = false
        end
      end
      if start_position == left_position and right_position
        [0..0]
      else
        [left_position+1..right_position-1]
      end
    end
end