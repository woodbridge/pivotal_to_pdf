require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))

module PivotalToPdf

  class SampleCardFormat; end

  describe CardFormatFactory do
    
    context "when configuration specifies a class" do
      it "returns the specified class" do

        DiskConfig.should_receive(:config).and_return(
          {'card_format_class' => 'PivotalToPdf::SampleCardFormat'})

        CardFormatFactory.card_format_class.should == SampleCardFormat

      end
    end 
     
    context "when configuration does not specify a class" do
      it "returns the default" do

        DiskConfig.should_receive(:config).and_return({})
        CardFormatFactory.card_format_class.should == DefaultCardFormat

      end
    end 

  end

end
