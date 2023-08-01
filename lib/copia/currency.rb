class Currency
  attr_reader :id, :name, :code, :symbol, :position

  def initialize(id, name, code, sym, pos)
    @id       = id
    @name     = name
    @code     = code
    @symbol   = sym
    @position = pos
  end

  def self.load(raw)
    ar = []
    raw.each_element do |curr|
      currency = Currency.new(
        curr.elements['id'].text,
        curr.elements['name'].text,
        curr.elements['code'].text,
        curr.elements['symbol'].text,
        curr.elements['position'].text)
      ar[currency.id] = currency
    end
    ar
  end

end
