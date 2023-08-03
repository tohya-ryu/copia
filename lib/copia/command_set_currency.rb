class CommandSetCurrency

  def initialize
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
    set_currencies(@doc.root.elements['accounts'], currency)
    if File.write(Copia.accounts_path, @doc)
      puts "copia: Account currencies changed to #{currency.name}"
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
   
end
