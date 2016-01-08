require 'locksmith/record_lock_checker'
require 'locksmith/transaction_checker'

module Locksmith
  class TransactionLogger
    def self.begin
      stack.push(TransactionLogger.new)
      current_transaction.begin
    end

    def self.execute(sql, name)
      current_transaction.execute(sql,name) if current_transaction.present?
    end

    def self.commit
      current_transaction.commit
      stack.pop
    end

    def self.rollback
      current_transaction.rollback
      stack.pop
    end

    def self.add_record(record)
      current_transaction.add_record(record)
    end

    def self.current_transaction
      stack.last
    end

    def self.stack
      @stack ||= []
    end

    attr_reader :checkers, :begin_callstack, :queries

    def initialize
      @checkers = [ RecordLockChecker.new, TransactionChecker.new ]
      @queries = []
    end

    def begin
      @begin_callstack = caller.select{|s| !s.include?('lib/locksmith/')}
      @checkers.each do |checker|
        checker.send(:begin) if checker.respond_to?(:begin)
      end
    end

    def execute(sql, name)
      @queries << sql
    end

    def commit
      @checkers.each do |checker|
        checker.send(:commit) if checker.respond_to?(:commit)
      end
    end

    def after_commit
      @checkers.each do |checker|
        checker.send(:after_commit, self) if checker.respond_to?(:after_commit)
      end
      @queries = []
    end

    def rollback
      @checkers.each do |checker|
        checker.send(:rollback) if checker.respond_to?(:rollback)
      end
    end

    def after_rollback
      @checkers.each do |checker|
        checker.send(:after_rollback, self) if checker.respond_to?(:after_rollback)
      end
      @queries = []
    end

    def add_record(record)
      @checkers.each do |checker|
        checker.send(:add_record, record) if checker.respond_to?(:add_record)
      end
    end
  end
end