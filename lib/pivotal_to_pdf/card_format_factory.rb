require 'active_support/inflector'
module PivotalToPdf
  class CardFormatFactory
    class << self
      def card_format_class
        class_name = DiskConfig.config['card_format_class']
        class_name ? class_name.constantize : PivotalToPdf::DefaultCardFormat
      end
    end
  end
end

