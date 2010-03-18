require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'method_info/ancestor_filter'

module MethodInfo
  describe AncestorFilter do
    it "picks all ancestors when no options are passed" do
      AncestorFilter.new([Object, Kernel]).picked.should == [Object, Kernel]
    end

    it "has no picked ancestors if all are excluded" do
      AncestorFilter.new([Enumerable, Kernel], :exclude => [Enumerable, Kernel]).picked.should == []
    end

    it "keeps ancestors that were not excluded" do
      AncestorFilter.new([Enumerable, Kernel], :exclude => [Kernel]).picked.should == [Enumerable]
    end

    it "keeps ancestors that are both excluded and included" do
      AncestorFilter.new([Enumerable, Kernel],
                         :exclude => [Enumerable, Kernel],
                         :include => [Kernel]).picked.should == [Kernel]
    end

    it "does not pick an ancestor that is included but not in the original list" do
      AncestorFilter.new([Kernel],
                         :include => [String]).picked.should == [Kernel]
    end

    it "excludes no ancestors when no options are passed" do
      AncestorFilter.new([Object, Kernel]).excluded.should == []
    end

    it "excludes all ancestors if all are excluded" do
      AncestorFilter.new([Enumerable, Kernel], :exclude => [Enumerable, Kernel]).excluded.should == [Enumerable, Kernel]
    end

    it "excludes ancestors that were excluded and present in the original list" do
      AncestorFilter.new([Enumerable, Kernel], :exclude => [Kernel]).excluded.should == [Kernel]
    end

    it "does not exclude ancestors that were excluded but not in the original list" do
      AncestorFilter.new([Enumerable, Kernel], :exclude => [String, Enumerable]).excluded.should == [Enumerable]
    end

    it "does not exclude ancestors that are both excluded and included" do
      AncestorFilter.new([Enumerable, Kernel],
                         :exclude => [Enumerable, Kernel],
                         :include => [Kernel]).excluded.should == [Enumerable]
    end

    describe "with class hierarchy" do
      it "excludes the modules of a class that is excluded" do
        AncestorFilter.new([Fixnum, Integer, Numeric, Comparable, Object, Kernel],
                           :exclude => [Integer, Object]).picked.should ==
          [Fixnum, Numeric, Comparable]
      end

      it "for a class that is both excluded and included it picks the class itself, but not the modules under it" do
        AncestorFilter.new([Object, Kernel],
                           :exclude => [Object],
                           :include => [Object]).picked.should == [Object]
      end

      it "maintains the order of a class that is both excluded and included" do
        AncestorFilter.new([Fixnum, Numeric, Object],
                           :exclude => [Numeric],
                           :include => [Numeric]).picked.should == [Fixnum, Numeric, Object]
      end
    end
  end
end
