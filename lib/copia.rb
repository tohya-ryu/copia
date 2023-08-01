require 'optparse'
require 'bigdecimal'
require 'bigdecimal/util'
require 'fileutils'
require 'rexml/document'
require 'time'

class Copia

  VERSION  = '1.0.0'
  PREF_DIR = '.local/share/copia'
  ACC_FILE = 'accounts.xml'
  CURR_FILE = 'currencies.xml'

  def initialize
    @@accounts        = []
    @@currencies      = []
    @@pref_path       = File.join(Dir.home, PREF_DIR)
    @@accounts_path   = File.join(@@pref_path, ACC_FILE)
    @@currencies_path = File.join(@@pref_path, CURR_FILE)
  end

  def main
    setup
    load_accounts
    load_currencies
    case ARGV[0]
    when 'transfer', 't', 'mv'
    when 'new-account', 'na'
      CommandNewAccount.new.run
    when 'list-accounts', 'la'
      CommandListAccounts.new.run
    when 'set-currency'
      CommandSetCurrency.new.run
    else
      puts parse_options
    end
  end

  def self.accounts
    @@accounts
  end

  def self.currencies
    @@currencies
  end

  def self.accounts_path
    @@accounts_path
  end

  def self.get_doc(filename)
    file = File.new filename
    doc = REXML::Document.new file
    file.close
    doc
  end

  private

  def parse_options
    optparse = OptionParser.new do |opts|
      opts.banner = "Usage: copia <cmd> [options]\n"+
        "Commands: transfer (t,mv), new-account (na), list-accounts (la), "+
        "set-currency"
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
    unless File.exists? @@accounts_path
      path = File.join(__dir__, '../stub', ACC_FILE)
      res = system "cp #{path} #{@@accounts_path}"
      unless res
        puts res
        exit
      end
    end
    unless File.exists? @@currencies_path
      path = File.join(__dir__, '../stub', CURR_FILE)
      res = system "cp #{path} #{@@currencies_path}"
      unless res
        puts res
        exit
      end
    end
  end
  
  def load_accounts
    doc = Copia.get_doc @@accounts_path
    @@accounts = Account.load doc.root.elements['accounts']
  end

  def load_currencies
    doc = Copia.get_doc @@currencies_path
    @@currencies = Currency.load doc.root.elements['currencies']
  end

end

require 'copia/account.rb'
require 'copia/currency.rb'
require 'copia/entry.rb'
require 'copia/transaction.rb'
require 'copia/command_new_account.rb'
require 'copia/command_list_accounts.rb'
require 'copia/command_set_currency.rb'
