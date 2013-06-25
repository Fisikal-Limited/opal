require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes', __FILE__)

describe "Enumerable#drop_while" do
  before :each do
    @enum = EnumerableSpecs::Numerous.new(3, 2, 1, :go)
  end

  it "returns no/all elements for {true/false} block" do
    @enum.drop_while {true}.should == []
    @enum.drop_while {false}.should == @enum.to_a
  end

  it "accepts returns other than true/false" do
    @enum.drop_while{1}.should == []
    @enum.drop_while{nil}.should == @enum.to_a
  end
end
