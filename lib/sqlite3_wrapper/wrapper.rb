# frozen_string_literal: true

require "sqlite3"
require "fileutils"
require "json"

module Wrapper
  class Sqlite3Wrapper < SQLite3::Database
    attr_reader :name, :options

    def initialize(options = {})
      @options = options
      @name = options[:name]

      @name == ":memory:" if options[:memory]
      directory = @name == ":memory:" ? nil : options[:dir] || "data"

      FileUtils.mkdir_p(directory) unless directory.nil?

      super directory.nil? ? @name : "#{directory}/#{@name}-sqlite3_wrapper.sqlite"
      self.results_as_hash = true if options[:results_as_hash]

      @name = "sqlite" if @name == ":memory:"
      config
    end

    def set(key, value)
      value = value.to_json.to_s
      prepare("INSERT OR REPLACE INTO #{@name}(key, value) VALUES(?, ?)")
        .execute(key, value)
    end

    def get(key, path = nil)
      result = nil
      execute("SELECT * FROM #{@name}") do |row|
        result = row.to_hash if row[0] == key
      end

      unless path.nil?
        case path.class
        when String
          puts "String"
          return result[path] if result[path]
        when Array
          path.each do |p|
            result = result[p] if result[p]
          end
        else return result end
      end

      result
    end

    def config
      prepare("CREATE TABLE IF NOT EXISTS #{@name} (key text PRIMARY KEY, value text)")
        .execute
    end

    private :config
  end
end
