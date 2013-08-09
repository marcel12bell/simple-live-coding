class Canvas
include Processing::Proxy

  def initialize(lines)
    @lines = lines
  end

  def draw_canvas
    evaluate(@lines.elements)
  end


  private

  def evaluate(elements)
    #eval all or only line by line
    begin
      code = ""
      elements.each do |str_obj|
        code += str_obj.content  + "\n" if str_obj.methode
      end
      return eval(code)
    rescue Exception => e
      begin
        elements.each do |str_obj|
          send_if_runnable(str_obj.methode, str_obj.arguments) if str_obj.methode
        end
      rescue Exception => e
        puts "#{ e } (#{ e.class })!"
      end
    end
  end

  def send_if_runnable(methode, args)
    begin
      send(methode, *args)
    rescue Exception => e
      puts "#{ e } (#{ e.class })!"
    end
  end

end