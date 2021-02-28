require "active_support"
require "pg"
require "fileutils"

module Migrator
  DB_DIR          = File.expand_path("./../../db", __FILE__)
  SCHEMA_PATH     = File.join(DB_DIR, "schema.sql")
  MIGRATIONS_DIR  = File.join(DB_DIR, "migrations")

  class << self
    def connection
      PG.connect(ENV["DATABASE_URL"])
    end
  end
end

require "migrator/cli"
require "migrator/command"

require "migrator/util"

require "migrator/create"
require "migrator/drop"
require "migrator/generate"
require "migrator/load"
require "migrator/migrate"
