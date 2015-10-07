require_relative 'objdump'
module ReadX
  class PE
    def initialize file
      @file = file
      @header = Objdump.header(@file)
      @contents = Objdump.contents(@file)
      @insts, @flows = Objdump.insts(@file)
      # @sio = StringIO.new(File.open(@file,'rb'){|f| f.read})
    end
    def data
      {
        file: @file,
        header: @header,
        contents: @contents,
        insts: @insts,
        flows: @flows
      }
    end
  end
end
