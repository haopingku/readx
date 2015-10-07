require_relative 'objdump'
require_relative 'readelf'
module ReadX
  class Elf
    def initialize file
      @file = file
      @header = ReadElf.header(@file)
      @contents = Objdump.contents(@file)
      @insts, @flows = Objdump.insts(@file)
      # @sio = StringIO.new(File.open(@file,'rb'){|f| f.read})
    end
    def data_js f
      require 'json'
      File.open(f, 'w'){|f|
        f.puts(
          'readx_data =',
          JSON.pretty_generate(
            file: @file,
            header: @header,
            contents: @contents,
            insts: @insts,
            flows: @flows
          )
        )
      }
    end
  end
end
