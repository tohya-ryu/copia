class Account
  attr_accessor :children
  attr_reader   :id, :key, :name

  def initialize(id, key, name)
    @id       = id
    @key      = key
    @name     = name
    @children = nil
  end

end
