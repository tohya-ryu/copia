class Account
  attr_reader :id, :key, :name, :children

  def initialize(id, key, name)
    @id       = id
    @key      = key
    @name     = name
    @children = nil
  end

end
