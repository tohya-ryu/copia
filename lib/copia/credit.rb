class Credit
  attr_reader :transaction, :amount, :account, :datetime

  def initialize(transaction, amount, account, datetime)
    @transaction = transaction
    @amount      = amount
    @account     = account
    @datetime    = datetime
  end

end
