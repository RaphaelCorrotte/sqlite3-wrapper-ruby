# frozen_string_literal: true

require_relative "../lib/sqlite3_wrapper"

test = Sqlite3Wrapper.new({
                            :name => "test",
                            :memory => true,
                            :results_as_hash => true
                          })

test.set("rr", {
           :value => {
             :test => "test!"
            }
         })

p test.get("rr", %w[value])
