module HalfMoon
  module Loader
    def delay_require(path, root = Config[:root])
      path += '.rb' if path =~ /\.rb$/
      location = root + path
      require location
    end

    def hm_autoload(const_name, file)
      location = Config[:root] + file
      autoload const_name, location
    end

    def hm_load(file)
      location = Config[:root] + file + '.rb'
      load location
    end

    def all_autoload(dir_files)
      files = Dir.glob(dir_files)
      files.each do |file|
        const_name = file.split('/').last.capitalize.gsub(/\.rb$/, '')
        autoload const_name, file
      end
    end
  end
end
