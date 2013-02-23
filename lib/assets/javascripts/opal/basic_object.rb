class BasicObject
  def initialize(*)
  end

  def ==(other)
    `#{self} === other`
  end

  def __send__(symbol, *args, &block)
    %x{
      var func = #{self}['$' + symbol]

      if (func) {
        if (block !== nil) { args.push(block); }
        return func.apply(#{self}, args);
      }

      return #{self}.$method_missing.apply(#{self}, [symbol].concat(args));
    }
  end

  alias eql? ==
  alias equal? ==

  def instance_eval(&block)
    %x{
      if (block === nil) {
        no_block_given();
      }

      var block_self = block._s, result;

      block._s = null;
      result = block.call(#{self}, #{self});
      block._s = block_self;

      return result;
    }
  end

  def instance_exec(*args, &block)
    %x{
      if (block === nil) {
        no_block_given();
      }

      var block_self = block._s, result;

      block._s = null;
      result = block.apply(#{self}, args);
      block._s = block_self;

      return result;
    }
  end

  def method_missing(symbol, *args, &block)
    Kernel.raise NoMethodError, "undefined method `#{symbol}' for BasicObject instance"
  end
end
