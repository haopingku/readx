require 'stringio'

module ReadX
  class NotSupportError < Exception
    attr_reader :not_support
    def initialize not_support 
      @not_support = not_support
    end
  end
  def self.readx args
    case arg = args.shift
    when '--version'
      puts('readx 0.0.1')
    when nil
      puts('usage: readx <file> [opt] ...')
    else
      if !File.file?(arg)
        puts("readx: file \"#{arg}\" not exist.")
      else
        case File.open(arg,'rb'){|f| f.read(16)}
        when /^\x7fELF/
          require_relative 'lib/elf'
          Elf.new(arg).data_js('readx.js')
          d = File.dirname(__FILE__)
          s = File.open("#{d}/readx.html", 'r'){|f| f.read}
                  .gsub(/(href|src)="\.\//, "\\1=\"#{d}/")
          File.open('readx.html', 'w'){|f| f.puts(s)}
        end
      end
    end
  rescue NotSupportError => e
    puts(
      "readx: not support \"#{e.not_support}\", " +
      'please check that it is installed and searchable in $PATH.'
    )
  end
end

ReadX.readx(ARGV)
