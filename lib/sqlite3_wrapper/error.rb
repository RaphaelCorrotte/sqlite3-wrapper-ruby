# frozen_string_literal: true

require "sqlite3"

module Wrapper
  class CustomError < SQLite3::StandardError; end
end
