require 'stringio'

class ReadX
  class NotSupportError < Exception
    attr_reader :not_support
    def initialize not_support 
      @not_support = not_support 
    end
  end
  def readx args
    case arg = args.shift
    when '--version'
      puts('readx 0.0.1')
    when nil
      puts('usage: readx <file> [opt] ...')
    else
      if !File.file?(arg)
        raise Errno::ENOENT.new(arg)
      end
      case File.open(arg,'rb'){|f| f.read(16)}
      when /^\x7fELF/
        require_relative 'lib/elf'
        Elf.new(arg)
          .to_data_js('../x-test-data.js')
      end
    end
  rescue Errno::ENOENT => e
    puts("readx: file \"#{arg}\" not exist.")
  rescue NotSupportError => e
    puts(
      "readx: not support \"#{e.not_support}\", " +
      'please check that it is installed and searchable in $PATH.'
    )
  end
end

ReadX.new.readx(ARGV)
