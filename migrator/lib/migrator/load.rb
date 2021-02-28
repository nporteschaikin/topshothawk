module Migrator
  class Load < Command
    include Util

    def run
      connection_exec(read_file(Migrator::SCHEMA_PATH))
    end
  end
end
