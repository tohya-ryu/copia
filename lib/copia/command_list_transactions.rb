class CommandListTransactions

  def initialize
    @options = {}
    @options[:accounts]  = []
    @options[:count]     = 50
    @options[:like]      = nil
    @options[:startdate] = nil
    @options[:enddate]   = nil
    @options[:sum]       = false
    @optparse = parse_options
  end

  def run
  end

  private

  def parse_options
    optparse = OptionParser.new do |opts|
      opts.banner = "Usage: copia ls [options]"
      opts.on_tail("-h", "--help", "Display this screen") do
        puts opts
        exit
      end
      opts.on("-cCOUNT", "--count=COUNT", "Number of lines") do |c|
        if /[0-9]+/.match?(c)
          @options[:count] = c.to_i
        else
          puts "copia: -c requires an integer argument"
          exit
        end
      end
      opts.on("-S", "--sum", "Also print sums") do 
        @options[:sum] = true
      end
      opts.on("-sDATE", "--start-date=DATE",
              "Earliest transaction date") do |date|
        
      end
      opts.on("-eDATE", "--end-date=DATE",
              "Latest transaction date") do |date|
        
      end
      opts.on("-lLIKE", "--comment-like=LIKE",
              "Where comment includes arg") do |arg|
        @options[:like] = arg
      end
      opts.on("-a", "--accounts [x,y,z]", Array,
          "List transactions of requested accounts") do |list|
        unless list.nil?
          list.each do |arg|
            puts arg
            @options[:accounts].push(Account.find(arg))
            unless @options[:accounts][-1]
              puts "copia: Account '#{arg}' not found"
              exit
            end
          end
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

end
