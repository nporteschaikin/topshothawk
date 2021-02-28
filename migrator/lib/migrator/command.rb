module Migrator
  class Command
    def initialize(args)
      @args = args
    end

    # Inheriting classes should implement `run`.

    protected

    attr_reader :args
  end
end
