module Enumerable
  def all?(&block)
    %x{
      var result = true, proc;

      if (block !== nil) {
        proc = function(obj) {
          var value;

          if ((value = block(obj)) === __breaker) {
            return __breaker.$v;
          }

          if (value === false || value === nil) {
            result = false;
            __breaker.$v = nil;

            return __breaker;
          }
        }
      }
      else {
        proc = function(obj) {
          if (obj === false || obj === nil) {
            result = false;
            __breaker.$v = nil;

            return __breaker;
          }
        }
      }

      #{self}.$each(proc);

      return result;
    }
  end

  def any?(&block)
    %x{
      var result = false, proc;

      if (block !== nil) {
        proc = function(obj) {
          var value;

          if ((value = block(obj)) === __breaker) {
            return __breaker.$v;
          }

          if (value !== false && value !== nil) {
            result       = true;
            __breaker.$v = nil;

            return __breaker;
          }
        }
      }
      else {
        proc = function(obj) {
          if (obj !== false && obj !== nil) {
            result      = true;
            __breaker.$v = nil;

            return __breaker;
          }
        }
      }

      #{self}.$each(proc);

      return result;
    }
  end

  def collect(&block)
    %x{
      var result = [];

      var proc = function() {
        var obj = __slice.call(arguments), value;

        if ((value = block.apply(null, obj)) === __breaker) {
          return __breaker.$v;
        }

        result.push(value);
      };

      #{self}.$each(proc);

      return result;
    }
  end

  def reduce(object = undefined, &block)
    %x{
      var result = #{object} == undefined ? 0 : #{object};

      var proc = function() {
        var obj = __slice.call(arguments), value;

        if ((value = block.apply(null, [result].concat(obj))) === __breaker) {
          result = __breaker.$v;
          __breaker.$v = nil;

          return __breaker;
        }

        result = value;
      };

      #{self}.$each(proc);

      return result;
    }
  end

  def count(object = undefined, &block)
    %x{
      var result = 0;

      if (object != null) {
        block = function(obj) { return #{ `obj` == `object` }; };
      }
      else if (block === nil) {
        block = function() { return true; };
      }

      var proc = function(obj) {
        var value;

        if ((value = block(obj)) === __breaker) {
          return __breaker.$v;
        }

        if (value !== false && value !== nil) {
          result++;
        }
      }

      #{self}.$each(proc);

      return result;
    }
  end

  def detect(ifnone = undefined, &block)
    %x{
      var result = nil;

      #{self}.$each(function(obj) {
        var value;

        if ((value = block(obj)) === __breaker) {
          return __breaker.$v;
        }

        if (value !== false && value !== nil) {
          result      = obj;
          __breaker.$v = nil;

          return __breaker;
        }
      });

      if (result !== nil) {
        return result;
      }

      if (typeof(ifnone) === 'function') {
        return #{ ifnone.call };
      }

      return ifnone == null ? nil : ifnone;
    }
  end

  def drop(number)
    %x{
      var result  = [],
          current = 0;

      #{self}.$each(function(obj) {
        if (number < current) {
          result.push(e);
        }

        current++;
      });

      return result;
    }
  end

  def drop_while(&block)
    %x{
      var result = [];

      #{self}.$each(function(obj) {
        var value;

        if ((value = block(obj)) === __breaker) {
          return __breaker;
        }

        if (value === false || value === nil) {
          result.push(obj);
          return value;
        }

        return __breaker;
      });

      return result;
    }
  end

  def each_slice(n, &block)
    %x{
      var all = [];

      #{self}.$each(function(obj) {
        all.push(obj);

        if (all.length == n) {
          block(all.slice(0));
          all = [];
        }
      });

      // our "last" group, if smaller than n then wont have been yielded
      if (all.length > 0) {
        block(all.slice(0));
      }

      return nil;
    }
  end

  def each_with_index(&block)
    %x{
      var index = 0;

      #{self}.$each(function(obj) {
        var value;

        if ((value = block(obj, index)) === __breaker) {
          return __breaker.$v;
        }

        index++;
      });

      return nil;
    }
  end

  def each_with_object(object, &block)
    %x{
      #{self}.$each(function(obj) {
        var value;

        if ((value = block(obj, object)) === __breaker) {
          return __breaker.$v;
        }
      });

      return object;
    }
  end

  def entries
    %x{
      var result = [];

      #{self}.$each(function(obj) {
        result.push(obj);
      });

      return result;
    }
  end

  alias find detect

  def find_all(&block)
    %x{
      var result = [];

      #{self}.$each(function(obj) {
        var value;

        if ((value = block(obj)) === __breaker) {
          return __breaker.$v;
        }

        if (value !== false && value !== nil) {
          result.push(obj);
        }
      });

      return result;
    }
  end

  def find_index(object = undefined, &block)
    %x{
      var proc, result = nil, index = 0;

      if (object != null) {
        proc = function (obj) {
          if (#{ `obj` == `object` }) {
            result = index;
            return __breaker;
          }
          index += 1;
        };
      }
      else {
        proc = function(obj) {
          var value;

          if ((value = block(obj)) === __breaker) {
            return __breaker.$v;
          }

          if (value !== false && value !== nil) {
            result     = index;
            __breaker.$v = index;

            return __breaker;
          }
          index += 1;
        };
      }

      #{self}.$each(proc);

      return result;
    }
  end

  def first(number = undefined)
    %x{
      var result = [],
          current = 0,
          proc;

      if (number == null) {
        result = nil;
        proc = function(obj) {
            result = obj; return __breaker;
          };
      } else {
        proc = function(obj) {
            if (number <= current) {
              return __breaker;
            }

            result.push(obj);

            current++;
          };
      }

      #{self}.$each(proc);

      return result;
    }
  end

  def grep(pattern, &block)
    %x{
      var result = [];

      #{self}.$each(block !== nil
        ? function(obj) {
            var value = #{pattern === `obj`};

            if (value !== false && value !== nil) {
              if ((value = block(obj)) === __breaker) {
                return __breaker.$v;
              }

              result.push(value);
            }
          }
        : function(obj) {
            var value = #{pattern === `obj`};

            if (value !== false && value !== nil) {
              result.push(obj);
            }
          });

      return result;
    }
  end

  def group_by(&block)
    hash = Hash.new { |h, k| h[k] = [] }

    each do |el|
      hash[block.call(el)] << el
    end

    hash
  end

  alias map collect

  alias select find_all

  alias take first

  alias to_a entries

  alias inject reduce
end
