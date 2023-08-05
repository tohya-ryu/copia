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
      ar[currency.id.to_i] = currency
    end
    ar
  end

  def self.find(input)
    if /[0-9]+/.match? input
      if Copia.currencies.at input.to_i
        return Copia.currencies[input.to_i]
      else
        return false
      end
    else
      ar = input.split ':'
      if ar.count == 2
        Copia.currencies.each do |currency|
          next if currency.nil?
          if currency.code.downcase == ar[0].downcase and
              currency.position.downcase == ar[1].downcase
            return currency
          end
        end
        return false
      else
        Copia.currencies.each do |currency|
          next if currency.nil?
          return currency if currency.code.downcase == ar[0].downcase
        end
        return false
      end
    end
  end

end
