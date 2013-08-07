class Canvas
include Processing::Proxy

  def initialize(lines)
    @lines = lines
  end

  def draw_canvas
    elements = @lines.elements
    elements.each do |str_obj|
        send_if_runnable(str_obj.methode, str_obj.arguments) if str_obj.methode
    end
  end


  private

  def send_if_runnable(methode, args)
    begin
      send(methode, *args)
    rescue Exception => e
      puts "#{ e } (#{ e.class })!"
    end
  end

end