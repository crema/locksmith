module Locksmith
  class RecordLockChecker
    RecordLock = Struct.new(:table_name, :primary_key, :mode)
    ForeignKey = Struct.new(:table_name, :foreign_key)

    attr_reader :locks, :foreign_keys_table, :invalid_order_locks

    def initialize
      @locks = []
      @invalid_order_locks = []
      @foreign_keys_table = {}
    end

    def add_record(record)
      add_s_locks_for_foreign_key(record) if record.new_record?
      add_x_lock_for_primary_key(record)
    end

    def after_commit(transaction)
      return if invalid_order_locks.empty?
      Config.config.invalid_order_lock_checker.call(transaction, locks, invalid_order_locks) if Config.config.invalid_order_lock_checker.present?
    end

    private


    def foreign_keys(record)
      table_name = record.class.table_name
      return foreign_keys_table[table_name] if foreign_keys_table.has_key?(table_name)

      associations = record.class.reflect_on_all_associations(:belongs_to)
      associations = associations.reject {|a| a.options[:polymorphic]}
      foreign_keys_table[table_name] = associations.map {|a| ForeignKey.new(a.table_name, a.foreign_key)}
    end

    def add_s_locks_for_foreign_key(record)
      foreign_keys(record).each do |foreign_key|
        foreign_key_value = record[foreign_key.foreign_key]
        add_lock(foreign_key.table_name, foreign_key_value, :s)
      end
    end

    def add_x_lock_for_primary_key(record)
      primary_key = record.class.primary_key
      primary_key_value = record[primary_key]
      add_lock(record.class.table_name, primary_key_value, :x)
    end

    def add_lock(table_name, key, mode)
      if mode == :x && locks.include?(RecordLock.new(table_name, key, :s))
        invalid_order_locks << table_name
      end
      locks << RecordLock.new(table_name, key, mode)
    end
  end
end
