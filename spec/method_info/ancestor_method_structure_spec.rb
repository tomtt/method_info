require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'method_info/ancestor_method_structure'

module MethodInfo
  describe AncestorMethodStructure do
    describe "#structure" do
      context "without methods passed" do
        it "transforms an object that behaves like an AncestorMethodMapping into the desired structure" do
          amm = {
            :ape => Kernel,
            :bear => Object,
            :cat => Kernel,
            :dog => String
          }
          amm.stub!(:ancestors).and_return [String, Object, Kernel]
          AncestorMethodStructure.new(amm).structure.should ==
            [[String, [:dog]],
             [Object, [:bear]],
             [Kernel, [:ape, :cat]]
            ]
        end

        it "orders the methods alphabetically" do
          amm = {
            :gnu => Object,
            :gnome => Object,
            :goose => Object,
            :geek => Object
          }
          amm.stub!(:ancestors).and_return [Object]
          AncestorMethodStructure.new(amm).structure.should ==
            [[Object, [:geek, :gnome, :gnu, :goose]]]
        end

        it "returns a structure with empty lists for ancestors without methods" do
          amm = {}
          amm.stub!(:ancestors).and_return [Fixnum, Object]
          AncestorMethodStructure.new(amm).structure.should ==
            [[Fixnum, []],
             [Object, []]]
        end

        it "returns a structure with a 'nil' ancestors for methods that do not have an owner that is an ancestor" do
          amm = {
            :ape => Integer,
            :bear => nil,
            :cat => Fixnum
          }
          amm.stub!(:ancestors).and_return [Object]
          AncestorMethodStructure.new(amm).structure.should ==
            [[Object, []],
             [nil, [:ape, :bear, :cat]]
            ]
        end
      end

      context "with methods passed" do
        it "transforms an object that behaves like an AncestorMethodMapping into the desired structure, using only the methods specified" do
          amm = {
            :ape => Kernel,
            :bear => Object,
            :cat => Kernel,
            :dog => String,
            :elk => Kernel,
            :flamingo => Object
          }
          amm.stub!(:ancestors).and_return [String, Object, Kernel]
          AncestorMethodStructure.new(amm, [:ape, :cat, :flamingo]).structure.should ==
            [[String, []],
             [Object, [:flamingo]],
             [Kernel, [:ape, :cat]]
            ]
        end
      end
    end
  end
end
