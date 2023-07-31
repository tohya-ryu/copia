class CommandListAccounts

  def initialize
    @optparse = parse_options
  end

  def run
    puts print_accounts(Copia.accounts, 0, '')
  end

  private

  def print_accounts(accounts, indent, str)
    out = str
    accounts.each do |account|
      str = ""
      (indent*4).times { |n| str << " " }
      str << account.to_s
      out << str << "\n"
      out = print_accounts(account.children, indent+1, out) if account.children
    end
    out
  end

  def parse_options
    optparse = OptionParser.new do |opts|
      opts.banner = "Usage: copia list-accounts [options]"
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
