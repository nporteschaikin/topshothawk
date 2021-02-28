module Migrator
  class CLI
    include ActiveSupport::Inflector

    def initialize(args)
      @args = args
    end

    def run
      cmd     = args.first
      klass   = constantize("Migrator::%s" % classify(cmd))

      klass.new(args[1..]).run
    end

    private

    attr_reader :args
  end
end
