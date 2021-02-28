module Migrator
  class Migrate < Command
    include Util

    UP   = "up".freeze
    DOWN = "down".freeze

    DIRECTIONS        = [UP, DOWN].freeze
    DEFAULT_DIRECTION = UP

    def run
      create_schema_migrations
      run_migrations
      dump_schema
    end

    private

    def run_migrations
      Dir.entries(Migrator::MIGRATIONS_DIR).each do |entry|
        path = File.join(Migrator::MIGRATIONS_DIR, entry)

        if File.directory?(path) && entry.to_i > 0 && # dumb check to ensure the directory is a number
          direction = DIRECTIONS.include?(args.first) ? args.first : DEFAULT_DIRECTION

          case direction
          when UP
            execute_up(entry)
          else
            execute_down(entry)
          end

          # for now, only let one `down` run at a time.
          break if direction == DOWN
        end
      end
    end

    def execute_up(version)
      unless existing_versions.include?(version)
        connection_exec(read_file(up_path_for(version)))

        connection_exec_params(
          "INSERT INTO schema_migrations (version) VALUES ($1)",
          [version],
        )
      end
    end

    def execute_down(version)
      if existing_versions.include?(version)
        connection_exec(read_file(down_path_for(version)))

        connection_exec_params(
          "DELETE FROM schema_migrations WHERE version = $1",
          [version],
        )
      end
    end

    def dump_schema
      run_command("pg_dump", ENV["DATABASE_URL"], "--schema-only", ">", Migrator::SCHEMA_PATH)
    end

    def existing_versions
      @existing_versions ||=
        begin
          response = connection_exec("SELECT * FROM schema_migrations")
          response.values.map(&:first)
        end
    end

    def create_schema_migrations
      connection_exec(<<~SQL)
        CREATE TABLE IF NOT EXISTS schema_migrations (
          version character varying NOT NULL
        );

        ALTER TABLE schema_migrations DROP CONSTRAINT IF EXISTS schema_migrations_pkey;
        ALTER TABLE ONLY schema_migrations
          ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);
      SQL
    end
  end
end
