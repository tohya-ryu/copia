require 'optparse'
require 'bigdecimal'
require 'bigdecimal/util'
require 'fileutils'
require 'rexml/document'
require 'time'

class Copia

  VERSION = "1.0.0"

  def initialize
    @@accounts = []
  end

  def main
    @@accounts = load_accounts
  end

  def accounts
    @@accounts
  end

  private
  
  def load_accounts
  end


end

require 'copia/account.rb'
require 'copia/entry.rb'
require 'copia/transaction.rb'
