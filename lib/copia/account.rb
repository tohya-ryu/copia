class Account
  attr_accessor :children, :balance, :currency
  attr_reader   :id, :key, :name

  @@id_head = 0

  def initialize(id, key, name, balance, currency)
    @id       = id.to_i
    @key      = key
    @name     = name
    @balance  = balance
    @currency = Currency.find(currency)
    @children = nil
  end

  def to_s
    "<#{@id.to_s.rjust(2, '0')}> #{@name} [#{@key}]"
  end

  def self.id_head
    @@id_head
  end

  # accepts raw data from rexml for a set of accounts
  # to recursively built data tree
  def self.load(raw)
    ar = []
    raw.each_element do |acc|
      account = Account.new(
        acc.elements['id'].text,
        acc.elements['key'].text,
        acc.elements['name'].text,
        acc.elements['balance'].text,
        acc.elements['currency'].text)
      @@id_head = account.id if account.id > @@id_head
      if acc.elements['children'].count > 0
        account.children = Account.load acc.elements['children']
      end
      ar.push account
    end
    ar
  end

  def self.find(input)
    unless /[0-9]+/.match? input
      input = input.split ':'
      result = search_key(Copia.accounts, input)
    else
      result = search_index(Copia.accounts, input)
    end
    result
  end

  private

  def self.search_index(accounts, input)
    accounts.each do |acc|
      return acc if acc.id.to_i == input.to_i
      unless acc.children.nil?
        child = search_index(acc.children, input)
        return child if child
      end
    end
    return nil
  end

  def self.search_key(accounts, input)
    out = nil
    found = false
    input.each_with_index do |key, i|
      found = false
      accounts.each do |account|
        if account.key == key
          found = account
          out = found
          accounts = account.children
          accounts = [] if accounts.nil?
        end
      end
    end
    if out and !found
      nil
    else
      out
    end
  end

end
