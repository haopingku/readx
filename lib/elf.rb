class ReadX
  class Elf
    def initialize f
      init_check
      @file = f
      # @sio = StringIO.new(File.open(@file,'rb'){|f| f.read})
      @header = header
      @section_header = section_header
      @instructs = instructs
    end
    def to_data_js f
      require 'json'
      h = {
        filename: @file,
        header: `readelf -h #{@file}`,
        sections: `readelf -S #{@file}`,
        insts: @instructs,
        insts_lines: []
      } 
      File.open(f,'w'){|f|
        f.puts(
          '$(function(){',
          'x_data(',
          JSON.pretty_generate(h),
          ')',
          '});'
        )
      }
    end
    def init_check
      # check readelf
      # check objdump
    end
    def header
      # header = {}
      # s = `readelf -h #{@file}`
      # header[:entry_point] = s.scan(/^\s+Entry point address:\s+0x(\w+)/)[0][0].to_i(16)
      # header
      `readelf -h #{@file}`
    end
    def section_header
      sec_hdr = []
      `readelf -S #{@file}`
        .split(/\n/)
        .map{|s|
          if s =~ /  \[[ \d]+\]/
            s = s.split
            sec_hdr << {
              name: s[1], type: s[2], addr: s[3], off: s[4],
              size: s[5], es: s[6], flg: s[7], lk: s[8], inf: s[9], al: s[10]
            }
          end
        }
      sec_hdr
    end
    def instructs
      ins = []
      sec = ''
      # a = File.open('../testobj','rb'){|f| f.read}
      a = `objdump -d #{@file}`
        .split(/[\r\n]+/)
      i = 0
      sz = a.size
      while i < sz
        case a[i]
        when /^Disassembly of section (.+?):$/
          sec = $1
        when /^[a-f0-9]+ <(.+?)>:$/i
          ins << {id: i, sec: sec, sym: $1, code: []}
        when /^ +([a-f0-9]+):\t/
          _ = a[i].split("\t")
          __ = _[1].strip.split(' ').map{|s| s.to_i(16)}
          if _.size == 3
            # 400440:	01 00                	add    %eax,(%rax)
            # to [0x400440, [1,0], "add", "%eax,(%rax)"]
            ins[-1][:code] << [_[0].to_i(16), __, *_[2].split(' ', 2)]
          else
            # instrcut that is too long to be split by objdump
            # 400452:	69 0d 00 00 03 00 63 	imul   $0x63,0x30000(%rip)
            # 400459:	00 00 00 
            ins[-1][:code][-1][1] += __
          end
        end
        i += 1
      end
      ins
    end
  end
end
