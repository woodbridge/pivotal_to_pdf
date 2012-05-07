require 'rubygems'
require 'rainbow'
require 'thor'
require 'active_resource'
require 'pivotal_to_pdf/disk_config'
require 'pivotal_to_pdf/card_format_factory'
require 'pivotal_to_pdf/simple_text_formatter'
require 'pivotal_to_pdf/pivotal'
require 'pivotal_to_pdf/iteration'
require 'pivotal_to_pdf/story'
require 'pivotal_to_pdf/default_card_format'
require 'pivotal_to_pdf/large_text_card_format'

module PivotalToPdf
  class Main < Thor
    class << self

      def card_format
	      CardFormatFactory.card_format_class
      end

      def story(story_id, colored_stripe=true)
        story = Story.find(story_id)
        card_format.new(story, colored_stripe).write_to
      end

      def stories( iteration_token, colored_stripe=true )
        if ['current','backlog', 'current_and_backlog'].include?( iteration_token.to_s )
          iterations = Iteration.find(:all, :params => {:group => iteration_token})
          stories = iterations.map{|i| i.stories }.flatten.compact
        else
          stories = Story.find(:all, :params => {:group => iteration_token})
        end
        card_format.new( stories, colored_stripe ).write_to
      end

      def iteration(iteration_token, colored_stripe=true)
        iteration = Iteration.find(:all, :params => {:group => iteration_token}).first
        card_format.new(iteration, colored_stripe).write_to
      end

      def iterations(iteration_token, colored_stripe=true)
        iterations = Iteration.find(:all, :params => {:group => iteration_token})
        iterations.each do |iteration|
          card_format.new(iteration, colored_stripe).write_to
        end
      end

    end
  end
end

