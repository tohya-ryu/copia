class Credit
  attr_reader :transaction, :amount, :account, :datetime

  def initialize(transaction, amount, account, datetime)
    @transaction = transaction
    @amount      = amount
    @account     = account
    @datetime    = datetime
  end

  def value
    value = ''
    if account.type == 'asset'
      value << '-' << @amount
    else
      value << @amount
    end
    BigDecimal value
  end

end
