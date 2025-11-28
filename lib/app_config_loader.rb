require "yaml"
require "erb"

module HaiukApplication
  class AppConfigLoader
    class << self
      attr_reader :config_data

      def config(default_config_path, yaml_dir)
        @config_data = load_default_config(default_config_path)
        load_config(yaml_dir)

        yield(@config_data) if block_given?

        @config_data
      end

      def pretty_print_config_data
        puts JSON.pretty_generate(@config_data)
      end

      def load_libs
        system_libs = ["date"]
        system_libs.each { |lib| require lib }

        @loaded_files ||= []

        Dir.glob("lib/**/*.rb").each do |file|
          next if @loaded_files.include?(file)
          require_relative "../#{file}"
          @loaded_files << file
        end
       end

      private

      def load_default_config(path)
        erb = ERB.new(File.read(path))
        YAML.safe_load(erb.result)
      end

      def load_config(directory)
        Dir.glob("#{directory}/*.yaml").each do |file|
          data = YAML.safe_load(File.read(file))
          @config_data.merge!(data)
        end
      end
    end
  end
end

