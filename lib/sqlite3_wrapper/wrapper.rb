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
      prepare("INSERT OR REPLACE INTO #{@name}(key, value) VALUES(?, ?)")
        .execute(key, value.to_s)
    end

    def get(key, path = nil)
      result = nil
      execute("SELECT * FROM #{@name}") do |row|
        result = row["value"] if row[0] == key
      end

      unless path.nil?
        if path.instance_of? String
          return result[path] if result[path]
        elsif path.instance_of? Array
          path.each do |p|
            result = JSON.parse(result.gsub(/:([a-zA-z\d]+)/, '"\\1"').gsub("=>", ": ")) if result.instance_of?(String)
            if result[p]
              result = result[p]
            else
              result = false
              break
            end
          end
        end
      end

      result
    end

    def has(key, path = nil)
      result = nil
      execute("SELECT * FROM #{@name}") do |row|
        result = row["value"] if row[0] == key
      end

      unless path.nil?
        if path.instance_of? String
          return true if result[path]
        elsif path.instance_of? Array
          path.each do |p|
            result = JSON.parse(result.gsub(/:([a-zA-z\d]+)/, '"\\1"').gsub("=>", ": ")) if result.instance_of?(String)
            if result[p]
              result = result[p]
            else
              result = false
              break
            end
          end
        else false end
      end

      result ? true : false
    rescue
      false
    end

    def config
      prepare("CREATE TABLE IF NOT EXISTS #{@name} (key text PRIMARY KEY, value text)")
        .execute
    end

    private :config
  end
end
