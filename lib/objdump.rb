module ReadX
  module Objdump
    begin
      `objdump --version`
    rescue Errno::ENOENT => e
      e.message =~ /directory - (\S+)/
      raise NotSupportError.new($1)
    end
    def self.contents file
      contents = []
      `objdump -s #{file}`.split(/\n+/).map do |s|
        case s
        when /^Contents of section (.+?):$/
          contents << [$1, []]
        when /^ +([a-f0-9]+) +((?:[a-f0-9]+ )+) (.+?)$/
          contents[-1][1] << [$1, $2.strip, $3.strip]
        end
      end
      contents
    end
    def self.insts file
      id, sec, sym = 0, '', ''
      jmp_srcs, jmp_dsts = [], []
      jmp = nil
      new_sym = nil
      last = []
      insts = []
      flows = []
      
      dumps = `objdump -d #{file}`.split(/[\r\n]+/)
      dumps.map do |s| # check all jmp dsts (for backward jmp)
        if s =~ /^ +([a-f0-9]+):\t(.+?)\t(.+?)$/i
          addr, hexs, asms = $1, $2, $3
          case asms
          when /^j.+? +([^* ].+?)$/
            jmp_srcs << addr.to_i(16)
            jmp_dsts << $1.to_i(16)
          end
        end
      end
      dumps.map do |s|
        case s
        when /^Disassembly of section (.+?):$/
          sec = $1
        when /^([a-f0-9]+) <(.+?)>:$/i
          id = $1.to_i(16)
          sym = $2
          insts << {id: id, sec: sec, sym: sym, code: []}
          jmp = nil # avoid jmp followed with new symbol
          new_sym = true
        when /^ +([a-f0-9]+):\t/i
          s = s.split("\t")
          addr = s[0].to_i(16)
          hexs = s[1].strip.split(' ').map{|s| s.to_i(16)}
          if s.size == 2
            # instrcution too long to be splited, the second line
            # 400452:	69 0d 00 00 03 00 63 	imul   $0x63,0x30000(%rip)
            # 400459:	00 00 00 
            insts[-1][:code][-1][1] += hexs
          elsif s.size == 3
            # # "400440:	01 00     	add    %eax,(%rax)"
            # # to [0x400440, [1,0], "add", "%eax,(%rax)"]
            asm = s[2].split(' ', 2)
            if asm[0][0] == 'j' # deal with jmps
              insts[-1][:code] << [addr, hexs, *asm]
              if asm[1][0] == '*' # jmp *0xXXXX, can't deal this type, all as :jmp
                jmp = :jmp
              else
                asm[1] =~ /^([xa-f0-9]+)/
                flows << [id, $1.to_i(16), :jmp_succ]
                if asm[0] == 'jmp' # jmp doesn't line to next addr
                  jmp = :jmp
                else
                  jmp = "jx_#{flows.size}".to_sym
                  flows << [id, 0, :jmp_fail]
                end
              end
            elsif jmp
              id = addr
              insts << {id: id, sec: sec, sym: sym, code: [[addr, hexs, *asm]]}
              if jmp != :jmp
                flows[jmp[3..-1].to_i][1] = addr
              end
              jmp = nil
            elsif jmp_dsts.include?(addr) && !new_sym # jmp destination
              if !['ret', 'leave'].include?(last[2])
                flows << [last[0], addr, :next]
              end
              id = addr
              insts << {id: id, sec: sec, sym: sym, code: [[addr, hexs, *asm]]}
            else
              insts[-1][:code] << [addr, hexs, *asm]
            end
            last = [addr, hexs, *asm]
          end # if s.size == 2
          new_sym = false
        end # case s
      end # dumps.map
      [insts, flows]
    end
  end
end
