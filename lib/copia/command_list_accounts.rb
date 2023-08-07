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
    max_pos_key = 0
    accounts.each do |account|
      str = ""
      #(indent*4).times { |n| str << " " }
      str << account.to_s
      max_pos_key = str.index('[') if str.index('[')> max_pos_key
      out << str << "\n"
      out = print_accounts(account.children, indent+1, out) if account.children
    end
    out2 = ""
    out.each_line do |line|
      diff = max_pos_key - line.index('[')
      padding = ""
      diff.times { |t| padding << " " }
      line.insert(line.index('['), padding)
      out2 << line
    end
    out2
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
