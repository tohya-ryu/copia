class Config
  attr_reader :pref_dir

  def initialize(raw)
    @pref_dir = raw.elements['pref_dir'].text
  end

end
