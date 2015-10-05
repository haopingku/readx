require 'stringio'

class ReadX
  def readx args
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
          Elf.new(arg)
            .to_data_js('html/x-data.js')
        end
      end
    end
  end
end

# p `where ruby`

ReadX.new.readx(ARGV)
