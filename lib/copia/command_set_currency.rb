class CommandSetCurrency

  def initialize
    @options = {}
    @options[:account] = nil
    @optparse = parse_options
    @doc = Copia.get_doc Copia.accounts_path
  end

  def run
    if ARGV.count != 2
      puts @optparse
      exit
    end
    # copia set-currency USD
    # copia set-currency EUR:right
    input = ARGV[1]
    currency = Currency.find input
    unless currency
      puts "No currency found matching '#{input}'"
      exit
    end
    unless @options[:account]
      set_currencies(@doc.root.elements['accounts'], currency)
      if File.write(Copia.accounts_path, @doc)
        puts "copia: Account currencies changed to #{currency.name}"
      end
    else
      res = set_currency(@doc.root.elements['accounts'], currency,
        @options[:account].id)
      if File.write(Copia.accounts_path, @doc)
        if res
          puts "copia: Updated currency for '#{@options[:account].name}'"+
           " to #{currency.name}"
        else
          puts "copia: Account not found!"
        end
      end
    end
  end

  private

  def parse_options
    optparse = OptionParser.new do |opts|
      opts.banner = "Usage: copia set-currency <currency> [options]\n"+
        "Arguments:\n"+
        "  currency: <code>:<position>\n"+
        "Examples:\n"+
        "  copia set-currency 1\n"+
        "  copia set-currency USD\n"+
        "  copia set-currency EUR:right\n"+
        "Options:"
      opts.on_tail("-h", "--help", "Display this screen") do
        puts opts
        exit
      end
      opts.on("-aACCOUNT", "--account=ACCOUNT",
          "Set currency for {account}") do |input|
        @options[:account] = Account.find input     
        unless @options[:account]
          puts "copia: Account #{input} not found"
          exit
        end
      end
    end
    begin
      optparse.parse!
    rescue OptionParser::InvalidOption => e
      puts e
      puts ""
      puts optparse
      exit
    end
    optparse
  end

  def set_currencies(accounts, currency)
    accounts.each do |acc|
      acc.elements['currency'].text = currency.id
      if acc.elements['children'].count > 0
        set_currencies(acc.elements['children'], currency) 
      end
    end
  end

  def set_currency(accounts, currency, target_id)
    accounts.each do |acc|
      if acc.elements['id'].text.to_i == target_id.to_i
        acc.elements['currency'].text = currency.id
        return true
      elsif acc.elements['children'].count > 0
        if set_currency(acc.elements['children'], currency, target_id)
          return true
        end
      end
    end
    return false
  end
   
end
