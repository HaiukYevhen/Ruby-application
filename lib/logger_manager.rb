require "logger"

module HaiukApplication
  class LoggerManager
    class << self
      attr_reader :logger

      def setup(config)
        log_dir = config["logging"]["directory"]
        Dir.mkdir(log_dir) unless Dir.exist?(log_dir)

        log_file = File.join(log_dir, config["logging"]["files"]["application_log"])
        level = config["logging"]["level"]

        @logger = Logger.new(log_file)
        @logger.level = Logger.const_get(level)
      end

      def log_processed_file(message)
        @logger.info(message)
      end

      def log_error(message)
        @logger.error(message)
      end
    end
  end
end