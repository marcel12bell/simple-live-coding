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