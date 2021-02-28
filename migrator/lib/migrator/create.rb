module Migrator
  class Create < Command
    def run
      uri   = URI.join(ENV["DATABASE_URL"], "/")
      name  = URI(ENV["DATABASE_URL"]).path.gsub(/\//, "")

      connection = PG.connect(uri.to_s)
      connection.exec("CREATE DATABASE %s" % name)
    end
  end
end
