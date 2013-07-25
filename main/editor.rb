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