require File.dirname(__FILE__) + '/spec_helper'
require 'machinist/object'

module MachinistSpecs
  
  class Person
    attr_accessor :name, :admin
  end

  class Post
    attr_accessor :title, :body, :published
  end

  describe Machinist do
    before(:each) do
      Person.clear_blueprints!
      Post.clear_blueprints!
    end
  
    it "should set an attribute on the constructed object from a constant in the blueprint" do
      Person.blueprint do
        name "Fred"
      end
      Person.make.name.should == "Fred"
    end
  
    it "should set an attribute on the constructed object from a block in the blueprint" do
      Person.blueprint do
        name { "Fred" }
      end
      Person.make.name.should == "Fred"
    end
  
    it "should default to calling Sham for an attribute in the blueprint" do
      Sham.clear
      Sham.name { "Fred" }
      Person.blueprint { name }
      Person.make.name.should == "Fred"
    end
  
    it "should let the blueprint override an attribute with a default value" do
      Post.blueprint do
        published { false }
      end
      Post.make.published.should be_false
    end
  
    it "should override an attribute from the blueprint with a passed-in attribute" do
      Person.blueprint do
        name "Fred"
      end
      Person.make(:name => "Bill").name.should == "Bill"
    end
  
    it "should allow overridden attribute names to be strings" do
      Person.blueprint do
        name "Fred"
      end
      Person.make("name" => "Bill").name.should == "Bill"
    end
  
    it "should not call a block in the blueprint if that attribute is passed in" do
      block_called = false
      Person.blueprint do
        name { block_called = true; "Fred" }
      end
      Person.make(:name => "Bill").name.should == "Bill"
      block_called.should be_false
    end
  
    it "should call a passed-in block with the object being constructed" do
      Person.blueprint { }
      block_called = false
      Person.make do |person|
        block_called = true
        person.class.should == Person
      end
      block_called.should be_true
    end
  
    it "should provide access to the object being constructed from within the blueprint" do
      person = nil
      Person.blueprint { person = object }
      Person.make
      person.class.should == Person
    end
  
    it "should allow reading of a previously assigned attribute from within the blueprint" do
      Post.blueprint do
        title "Test"
        body { title }
      end
      Post.make.body.should == "Test"
    end
  
    describe "named blueprints" do
      before do
        @block_called = false
        Person.blueprint do
          name  { "Fred" }
          admin { @block_called = true; false }
        end
        Person.blueprint(:admin) do
          admin { true }
        end
        @person = Person.make(:admin)
      end
    
      it "should override an attribute from the parent blueprint in the child blueprint" do
        @person.admin.should == true
      end
    
      it "should not call the block for an attribute from the parent blueprint if that attribute is overridden in the child" do
        @block_called.should be_false
      end
    
      it "should set an attribute defined in the parent blueprint" do
        @person.name.should == "Fred"
      end
      
      it "should return the correct list of named blueprints" do
        Person.blueprint(:foo) { }
        Person.blueprint(:bar) { }
        Person.named_blueprints.should == [:admin, :foo, :bar]
      end
    end  

    describe "clear_blueprints! method" do
      it "should clear the list of blueprints" do
        Person.blueprint(:foo){}
        Person.clear_blueprints!
        Person.named_blueprints.should == []
      end
  
      it "should clear master blueprint too" do
        Person.blueprint(:foo) {}
        Person.blueprint {} # master
        Person.clear_blueprints!
        lambda { Person.make }.should raise_error(RuntimeError)
      end
    end
    
  end
end
