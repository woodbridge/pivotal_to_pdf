module PivotalToPdf
  class DiskConfig

    class << self

      def config
        unless @config
          base_dir = ENV["PIVOTAL_TO_PDF_CONFIG_DIR"] || "~"
          @config = YAML.load_file File.expand_path("#{base_dir}/.pivotal.yml")
        end
        @config
      end

    end

  end
end
