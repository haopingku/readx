module ReadX
  module Readelf
    begin
      `readelf --version`
      @enable = true
    rescue Errno::ENOENT => e
      @enable = false
    end
    def self.enable?
      @enable
    end
    def self.parse str
      ary = str.split(/\n/)
      h = {}
      case ary.shift
      when 'ELF Header:'
        attr = []
        while (s = ary.shift) && s =~ /^  /
          s =~ /^ +(.+?): +(.+?)$/
          attr << [$1, $2]
        end
        h[:attributes] = attr
      end
      h
    end
  end
end
