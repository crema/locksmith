require 'active_record/connection_adapters/abstract_mysql_adapter'

module Locksmith
  module AbstractMysqlAdapter
    def execute(sql, name = nil)
      Locksmith::TransactionLogger.execute(sql, name)
      super
    end
  end
end

ActiveRecord::ConnectionAdapters::AbstractMysqlAdapter.send(:prepend, Locksmith::AbstractMysqlAdapter)