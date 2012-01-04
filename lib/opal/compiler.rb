require 'fileutils'

module Opal
  class Compiler
    def initialize(sources, options = {})
      @sources = Array(sources)
      @options = options
    end

    def compile
      @parser     = Parser.new
      @factories  = {}
      @libs       = {}

      @sources.each { |s| compile_path s }

      if @options[:join]
        File.open(@options[:join], 'w+') do |o|
          @factories.each do |file, factory|
            o.write "opal.file('/#{file}', function() {\n#{factory}\n});\n"
          end
          @libs.each do |lib, factory|
            o.write "opal.lib('#{lib}', function() {\n#{factory}\n});\n"
          end
        end
      end
    end

    def compile_path(path)
      if File.directory? path
        Dir.entries(path).each do |e|
          next if e == '.' or e == '..'
          compile_path File.join(path, e)
        end

      elsif File.extname(path) == '.rb'
        compile_file path
      end
    end

    def compile_file(source)
      compiled = @parser.parse File.read(source), source

      if @options[:output]
        output = output_path(source)

        FileUtils.mkdir_p File.dirname(output)
        File.open(output, 'w+') { |o| o.write compiled }

      elsif @options[:join]
        if /^lib.*\.rb/ =~ source
          @libs[source[4..-4]] = compiled
        else
          @factories[source] = compiled
        end
      end
    end

    def output_path(source)
      File.join(@options[:output], source.chomp('.rb')) + '.js'
    end
  end
end
