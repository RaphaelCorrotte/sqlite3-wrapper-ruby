# frozen_string_literal: true

require_relative "sqlite3_wrapper/version"
require_relative "sqlite3_wrapper/wrapper"

module Sqlite3Wrapper
  def self.new(options)
    Wrapper::Sqlite3Wrapper.new(options)
  end
end
