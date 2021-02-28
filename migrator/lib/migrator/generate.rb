module Migrator
  class Generate < Command
    include Util

    def run
      version = Time.now.strftime("%Y%m%d%H%M%S")

      FileUtils.mkdir_p(version_dir_for(version))
      FileUtils.touch(up_path_for(version))
      FileUtils.touch(down_path_for(version))
    end
  end
end
