require 'stringio'

module ReadX
  module NotSupport
    class Cmd < Exception
    end
    class X < Exception
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
        # parse file
        case File.open(arg,'rb'){|f| f.read(8)}
        when /^\x7fELF/
          require_relative 'lib/elf'
          x = Elf.new(arg)
        when /^MZ/
          require_relative 'lib/pe'
          x = PE.new(arg)
        else
          raise NotSupport::X, arg
        end
        # create js and html files
        require 'json'
        File.open('readx.js','w'){|f|
          f.puts('readx_data = '+JSON.pretty_generate(x.data))}
        File.open('readx.html', 'w'){|f|
          dir = File.dirname(__FILE__)
          f.puts(File
            .open("#{dir}/readx.html", 'r'){|f_| f_.read}
            .gsub(/(href|src)="\.\//, "\\1=\"#{dir}/")
          )
        }
      end
    end
  rescue NotSupport::Cmd => e
    puts(
      "readx: not support command \"#{e.message}\", " +
      'please check to be installed and searchable in PATH.'
    )
  rescue NotSupport::X => e
    puts("readx: not support this type of executable file (#{e.message}).")
  end
end

ReadX.readx(ARGV)
