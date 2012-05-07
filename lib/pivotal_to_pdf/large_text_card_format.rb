#!/usr/bin/env ruby

require 'rubygems'
require 'prawn'
require 'prawn/measurement_extensions'
require 'rainbow'

module PivotalToPdf
  class LargeTextCardFormat

    attr_reader :story_or_iteration, :stories

    def initialize(story_or_iteration, colored_stripe = true)
      case story_or_iteration
      when Array
        @stories  = story_or_iteration
        @pdf_name = 'backlog'
      when Iteration
        @stories  = story_or_iteration.stories
        @pdf_name = "iteration-#{story_or_iteration.id}"
      when Story
        @stories = [story_or_iteration]
        @pdf_name = "story-#{story_or_iteration.id}"
      end
    end

    def draw_card_with( pdf, story, index, opts, overflow = nil)
      
      puts story.formatted_name
      
      if overflow.nil? || overflow.empty?
        title = story.formatted_name
      else
        title = story.formatted_name + " (cont'd)"
      end
            
	    overflow_title = pdf.text_box title, 
	           :at      => [opts[:left_margin], pdf.bounds.top],
	           :size    => opts[:title_size],
	           :height  => opts[:title_height],
	           :kerning => true,
	           :leading => -4.0, 
	           :style   => :bold

	    if overflow_title.nil? || overflow_title.strip.empty?
	      desc = "\n"	    
	    else
	      desc = "<b>#{overflow_title}</b>\n\n"
	    end
	    
      if overflow.nil? || overflow.empty?
        formatted_desc = Prawn::Text::Formatted::Parser.to_array(
          desc + story.formatted_description )
      else
        formatted_desc = Prawn::Text::Formatted::Parser.to_array( desc )
        formatted_desc += overflow
      end
	    
	    overflow_desc = pdf.formatted_text_box formatted_desc,
	           :at     => [opts[:left_margin], opts[:desc_y]],
	           :size   => opts[:desc_size],
	           :height => opts[:desc_height]

	    pdf.text_box "#{story.state}  Rank: #{index+1}  #{story.points}",
	           :at     => [opts[:left_margin], opts[:status_y]],
	           :size   => opts[:status_size] unless story.points.nil?

	    pdf.text_box story.label_text,
	           :at    => [opts[:left_margin], opts[:label_y]],
	           :size  => opts[:label_size],
	           :align => :right

	    pdf.text_box story.story_type.capitalize,
	           :at     => [opts[:left_margin]-4 , pdf.bounds.bottom + opts[:title_size]],
	           :width  => opts[:page_height] - opts[:page_margin] * 2,
	           :size   => opts[:title_size],
	           :style  => :bold,
	           :align  => :center,
	           :rotate => 90,
	           :rotate_around => :lower_left

      if story.respond_to? :other_id
       
	        pdf.text_box story.other_id,
	           :at     => [opts[:left_margin]-4, pdf.bounds.bottom + opts[:title_size]],
	           :width  => opts[:page_height] - opts[:page_margin] * 2,
	           :size   => opts[:title_size],
	           :style  => :bold,
	           :align  => :left,
	           :rotate => 90,
	           :rotate_around => :lower_left
      end
      
	    return overflow_desc       
    end

    def write_to

      opts = {
        :title_size   => 17.0,
        :title_height => 17.0,
        :label_size   =>  9.0,
        :desc_size    =>  9.0,
        :status_size  => 12.5,
        :kind_size    => 12.5,
        :desc_height  =>  3.2.in,
        :page_width   => 11.0.in/2,
        :page_height  =>  8.5.in/2,
        :page_margin  =>  0.2.in,
        :pad_for_type => 16.0
      }
      
      Prawn::Document.generate("#{@pdf_name}.pdf",
                               :page_layout => :landscape,
                               :margin      => 0.2.in,
                               :page_size   => [8.5.in/2, 11.in/2]) do |pdf|

        opts[:left_margin] = pdf.bounds.left   + opts[:pad_for_type]  
        opts[:desc_y]      = pdf.bounds.top    - opts[:title_height]
        opts[:status_y]    = pdf.bounds.bottom + opts[:status_size]
        opts[:label_y]     = opts[:status_y] + opts[:status_size]

        stories.each_with_index do |story, index|
          next if story.story_type == 'release'
          overflow = nil
          loop do
            begin
              overflow = draw_card_with( pdf, story, index, opts, overflow )
            rescue => e
              $stderr.print "Could not print card for story: "
              $stderr.print "#{story.name}." if story.respond_to?(:name)
              $stderr.print e
              overflow = nil
            end
            break if overflow.nil? || overflow.empty? 
            pdf.start_new_page
          end
          pdf.start_new_page unless index == stories.size - 1
        end

        puts "Generated PDF file in '#{@pdf_name}.pdf'".foreground(:green)
      end
    rescue Exception
      puts "[!] There was an error while generating the PDF file... What happened was:".foreground(:red)
      raise
    end
  end
end
