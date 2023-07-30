class CommandNewAccount

  def initialize
    @optparse = parse_options
  end

  def run
     puts @optparse if ARGV.count != 3

  end

  private 

  def parse_options
    optparse = OptionParser.new do |opts|
      opts.banner = "Usage: copia new-account <name> <key> [options]\n"+
        "Arguments:\n"+
        "  name: <string>\n"+
        "  key: <parent>:<child>:<key>\n"+
        "Examples:\n"+
        "  copia na Moneybox asset:savings:moneybox\n"+
        "  copia na Mastercard liability:mastercard\n"+
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

end
