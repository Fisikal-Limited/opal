require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes', __FILE__)

# Modifying a collection while the contents are being iterated
# gives undefined behavior. See
# http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-core/23633

describe "Array#rindex" do
  pending "returns the first index backwards from the end where element == to object" do
    key = 3
    uno = mock('one')
    dos = mock('two')
    tres = mock('three')
    tres.should_receive(:==).any_number_of_times.and_return(false)
    dos.should_receive(:==).any_number_of_times.and_return(true)
    uno.should_not_receive(:==)
    ary = [uno, dos, tres]

    ary.rindex(key).should == 1
  end

  it "returns size-1 if last element == to object" do
    [2, 1, 3, 2, 5].rindex(5).should == 4
  end

  it "returns 0 if only first element == to object" do
    [2, 1, 3, 1, 5].rindex(2).should == 0
  end

  it "returns nil if no element == to object" do
    [1, 1, 3, 2, 1, 3].rindex(4).should == nil
  end

  pending "properly handles empty recursive arrays" do
    empty = ArraySpecs.empty_recursive_array
    empty.rindex(empty).should == 0
    empty.rindex(1).should be_nil
  end

  pending "properly handles recursive arrays" do
    array = ArraySpecs.recursive_array
    array.rindex(1).should == 0
    array.rindex(array).should == 7
  end

  ruby_version_is "1.8.7" do
    it "accepts a block instead of an argument" do
      [4, 2, 1, 5, 1, 3].rindex { |x| x < 2 }.should == 4
    end

    it "ignore the block if there is an argument" do
      [4, 2, 1, 5, 1, 3].rindex(5) { |x| x < 2 }.should == 3
    end

    it "rechecks the array size during iteration" do
      ary = [4, 2, 1, 5, 1, 3]
      seen = []
      ary.rindex { |x| seen << x; ary.clear; false }

      seen.should == [3]
    end

    describe "given no argument and no block" do
      it "produces an Enumerator" do
        enum = [4, 2, 1, 5, 1, 3].rindex
        enum.should be_kind_of(enumerator_class)
        enum.each { |x| x < 2 }.should == 4
      end
    end
  end
end
