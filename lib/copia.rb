require 'optparse'
require 'bigdecimal'
require 'bigdecimal/util'
require 'fileutils'
require 'rexml/document'
require 'time'

class Copia

  VERSION  = "1.0.0"
  PREF_DIR = ".local/share/copia"
  ACC_FILE = "accounts.xml"

  def initialize
    @@accounts = []
    @@pref_path = File.join(Dir.home, PREF_DIR)
    @accounts_path = File.join(@@pref_path, ACC_FILE)
    @optparse = parse_options
  end

  def main
    setup
    load_accounts
    case ARGV[0]
    when "transfer", "t", "mv"
    when "new-account", "na"
    else
      puts @optparse
    end
  end

  def accounts
    @@accounts
  end

  private

  def parse_options
    optparse = OptionParser.new do |opts|
      opts.banner = "Usage: copia <cmd> [options]\n"+
        "Commands: transfer (t,mv), new-account (na)"
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

  # sets up required directories and files if not existing
  def setup
    FileUtils.mkpath @@pref_path unless Dir.exists? @@pref_path
    unless File.exists? @accounts_path
      path = File.join(__dir__, '../stub', ACC_FILE)
      res = system "cp #{path} #{@accounts_path}"
      unless res
        puts res
        exit
      end
    end
  end
  
  def load_accounts
    file = File.new @accounts_path
    doc = REXML::Document.new file
    file.close
    @@accounts = Account.load doc.root.elements['accounts']
  end

end

require 'copia/account.rb'
require 'copia/entry.rb'
require 'copia/transaction.rb'
