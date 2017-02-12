require 'thor'
require 'thor/group'

module HalfMoon
  class ProjectGenerator < Thor::Group
    include Thor::Actions

    argument :name

    # 実行されたディレクトリに作成する
    def self.source_root
      File.expand_path(File.dirname(__FILE__))
    end

    def create_assets
      @current = File.expand_path(File.dirname('.'))
      %w(css img js).each do |dir|
        empty_directory "#{@current}/#{name}/app/assets/#{dir}"
      end
    end

    def create_config
      template './templates/config/config.tt',  "#{@current}/#{name}/app/config/config.tt"
      copy_file './templates/config/routes.rb', "#{@current}/#{name}/app/config/routes.rb"
    end

    def create_mvc
      %w(models views controllers).each do |dir|
        empty_directory "#{@current}/#{name}/app/#{dir}"
      end
    end

    def create_db
      empty_directory "#{@current}/#{name}/app/db/migration"
      copy_file './templates/models/seeds.rb', "#{@current}/#{name}/app/db/seeds.rb"
    end

    def create_exceptions
      copy_file './templates/exceptions/default.erb', "#{@current}/#{name}/app/exceptions/default.erb"
    end

    def create_other_files
      %w(config.ru Rakefile).each do |file|
        copy_file "./templates/#{file}", "#{@current}/#{name}/#{file}"
      end
    end

    def complete_message
      say 'Creation complete!', :green
    end
  end

  class ControllerGenerator < Thor::Group
    include Thor::Actions

    argument :name
    argument :methods

    def self.source_root
      File.expand_path(File.dirname(__FILE__))
    end

    def setting
      require 'halfmoon/config'
      require "#{File.expand_path('.')}/app/config/config.rb"
      @ctrl = Config[:root] + Config[:ctrl_path]
      @view = Config[:root] + Config[:view_path]
    end

    def create_controller
      template './templates/controller.tt', "#{@ctrl}/#{name}_controller.rb"
    end

    def create_view
      methods.each do |m|
        @method = m
        template './templates/view.tt', "#{@view}/#{name}/#{m}.html.erb"
      end
    end

    def complete_message
      say 'Creation complete!', :green
    end
  end

  class ModelGenerator < Thor::Group
    include Thor::Actions

    argument :name
    argument :column

    def self.source_root
      File.expand_path(File.dirname(__FILE__))
    end

    def setting
      require 'halfmoon/config'
      require "#{File.expand_path('.')}/app/config/config.rb"
      require 'active_support/all'
      @model = Config[:root] + Config[:model_path]
      @migrate = Config[:root] + Config[:db_path]
      @c = {}
    end

    def parse_args
      options = %w(default size)
      @column.each do |v|
        name, types = v.split(':')
        type, *opts = types.split('/')
        opts.map! do |opt|
          case opt
          when /^(\w+?)\((.+)\)/i
            "#{Regexp.last_match(1)}: #{Regexp.last_match(2)}" if options.include?(Regexp.last_match(1))
          when /^not_null$/i then 'null: false'
          when /^text$/i then     'text: true'
          when /^primary$/i then  'primary_key: true'
          end
        end
        opts.compact!
        @c.store(name, [type, opts].compact)
      end
    end

    def create_model
      template './templates/models/model.tt', "#{@model}/#{name}.rb"
    end

    def create_migration
      template './templates/models/migration.tt', "#{@migrate}/migration/#{name.pluralize}_migration.rb"
    end

    def complete_message
      say 'Creation complete!', :green
    end
  end
end
