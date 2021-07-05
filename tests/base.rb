# frozen_string_literal: true

require_relative "../lib/sqlite3_wrapper"

test = Sqlite3Wrapper.new({
                            :name => "test",
                            :memory => true,
                            :results_as_hash => true
                          })

test.set("rr", {
           :aa => {
             :test => {
               :test2 => "Salut"
             }
           }
         })


puts test.get("rr", %w[aa test])
