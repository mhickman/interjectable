require 'spec_helper'

describe Injectable do
  context "when extended" do
    let(:klass) { Class.new { extend Injectable } }
    let(:instance) { klass.new }

    describe "#inject" do
      before do
        klass.inject(:some_dependency) { :service }
      end

      it "adds an instance method getter and setter" do
        instance.some_dependency = 'aaa'
        instance.some_dependency.should == 'aaa' 
      end

      it "lazy-loads the default block" do
        instance.instance_variable_get("@some_dependency").should be_nil
        instance.some_dependency.should == :service
        instance.instance_variable_get("@some_dependency").should_not be_nil
      end

      context "with a dependency on another class" do
        before do
          defined?(SomeOtherClass).should be_false

          klass.inject(:some_other_class) { SomeOtherClass.new }
        end

        it "does not need to load that class (can be stubbed away)" do
          instance.some_other_class = :fake_other_class

          instance.some_other_class.should == :fake_other_class
        end
      end
    end
  end
end