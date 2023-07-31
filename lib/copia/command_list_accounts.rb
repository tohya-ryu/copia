class CommandListAccounts

  def initialize
    @optparse = parse_options
  end

  def run
    print_accounts(Copia.accounts, 0)
  end

  private

  def print_accounts(accounts, indent)
    accounts.each do |account|
      str = ""
      (indent*4).times { |n| str << " " }
      str << account.to_s
      puts str
      print_accounts(account.children, indent+1) if account.children
    end
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
