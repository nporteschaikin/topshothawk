module Migrator
  module Util
    def connection
      Migrator.connection
    end

    def connection_exec(stmt)
      logger.info(stmt)
      connection.exec(stmt)
    end

    def connection_exec_params(stmt, params)
      logger.info(stmt)
      connection.exec(stmt, params)
    end

    def run_command(*args)
      logger.info(args.join(" "))
      system(args.join(" "))
    end

    def read_file(path)
      File.open(path).readlines.join("\n")
    end

    def version_dir_for(version)
      File.join(MIGRATIONS_DIR, version)
    end

    def up_path_for(version)
      File.join(version_dir_for(version), "up.sql")
    end

    def down_path_for(version)
      File.join(version_dir_for(version), "down.sql")
    end

    def logger
      @logger ||= Logger.new(STDOUT)
    end
  end
end
