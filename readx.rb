require 'stringio'

module ReadX
  module NotSupport
    class Cmd < Exception
    end
    class X < Exception
    end
    class NoFile < Exception
    end
  end
  def self.file_exist file
    if !File.file?(file)
      raise NotSupport::NoFile, file
    end
  end
  def self.create_html data
    require 'json'
    File.open('readx.js','w'){|f|
      f.puts('readx_data = '+JSON.pretty_generate(data))}
    File.open('readx.html', 'w'){|f|
      dir = File.dirname(__FILE__)
      f.puts(File
        .open("#{dir}/readx.html", 'r'){|f_| f_.read}
        .gsub(/(script|link) +(href|src)="\.\//, "\\1 \\2=\"#{dir}/")
      )
    }
  end
  def self.readx args
    case arg = args.shift
    when '-v', '--version'
      puts('readx 0.0.1')
    when '-h', 'help', nil
      puts('usage: readx <file> [opt] ...')
    when '--import'
      h = {file: '(import mode)', header: []}
      while arg = args.shift
        case arg
        when /flow=(.+?)/
          f = $1
          file_exist(f)
          require_relative 'lib/objdump'
          insts, flows = Objdump.insts(f, :dump)
          h[:header] << ["flow loaded in file #{f}"]
          h[:insts] = insts
          h[:flows] = flows
        when /contents=(.+?)/
          f = $1
          file_exist(f)
          require_relative 'lib/objdump'
          h[:header] << ["contents loaded in file #{f}"]
          h[:contents] = Objdump.contents(f, :dump)
        end
        create_html(h)
      end
    else
      file_exist(arg)
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
      create_html(x.data)
    end
  rescue NotSupport::NoFile => e
    puts("readx: file \"#{e.message}\" not exist.")
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
