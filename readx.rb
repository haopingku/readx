module ReadX
  def self.file_exist file
    File.file?(file) || STDERR.puts("readx: file \"#{file}\" not exist.")
  end
  def self.create_html
    require 'json'
    fname = "readx_#{@data[:file].gsub(/\W/,'_')}.html"
    File.open(fname, 'w'){|f|
      dir = File.dirname(__FILE__)
      f.puts(
        IO.read("#{dir}/readx.html")
          .gsub(/(script|link) +(href|src)="\.\//, "\\1 \\2=\"#{dir}/"),
        '<script>',
        'readx_data = '+JSON.pretty_generate(@data),
        '</script>'
      )
    }
    puts("readx: #{fname} created.")
  end
  def self.dumpfile str
    t = str[0...128]
    if t.ascii_only?
      case t
      when /^\n?(.+?): +file format .+\n/
        Objdump.parse(str)
      when /^ELF Header:/
        Readelf.parse(str)
      end
    end
  end
  def self.readx args
    require_relative 'lib/readelf'
    require_relative 'lib/objdump'
    @data = {
      valid: false,
      file: 'unknown',
      attributes: [],
      contents: [],
      instructions: [],
      flows: []
    }
    case arg = args.shift
    when '-v', '--version'
      puts('readx 1.0.1')
    when '-h', '--help', nil
      puts(
        'usage: readx <file>',
        '       readx --dumpfile <file> [file [...]]',
        '       readx [-h|--help] [-v|--version]'
      )
    when /^--dumpfile$/
      args.map{|f|
        if h = dumpfile(IO.read(f))
          @data.merge!(h)
          @create_html = true
        else
          STDERR.puts("readx: unknown dumpfile #{f}.")
        end
      }
    else
      if file_exist(arg)
        @data[:file] = arg
        case File.open(arg,'rb'){|f| f.read(8)}
        when /^\x7fELF/
          Objdump.enable? &&
            @data.merge!(Objdump.parse(`objdump -fsd #{@data[:file]}`))
          Readelf.enable? &&
            @data.merge!(Readelf.parse(`readelf -h #{@data[:file]}`))
          @create_html = true
        when /^MZ/
          Objdump.enable? &&
            @data.merge!(Objdump.parse(`objdump -fsd #{@data[:file]}`))
          @create_html = true
        else
          STDERR.puts(
            "readx: not support this type of executable file (#{@data[:file]})."
          )
        end
      end
    end
    @create_html && create_html
  end
end

ReadX.readx(ARGV)

# data structure:
# {
#   file: "elf32",
#   attributes: [
#     ["Machine", "Intel 80386"],
#     ...
#   ],
#   contents: [
#     [
#       ".interp",
#       [
#         ["8048154", "5f00474c 4942435f 322e3000", "_.GLIBC_2.0."],
#         ...
#       ]
#     ],
#     ...
#   ],
#   instructions: [
#     {
#       id: 134513332,
#       sec: ".init",
#       sym: "_init",
#       code: [
#         [134513333, [131, 236, 8], "sub", "$0x8,%esp"],
#         ...
#       ]
#     },
#     ...
#   ],
#   flows: [
#     [134513332, 134513362, "jmp_succ"],
#     ...
#   ]
# }
