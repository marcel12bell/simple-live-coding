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