module ReadX
  module Objdump
    begin
      `objdump --version`
      @enable = true
    rescue Errno::ENOENT => e
      @enable = false
    end
    def self.enable?
      @enable
    end
    def self.parse str
      h = {}
      ary = str.split(/\n/)
      while s = ary.shift
        case s
        when /^(.+?): +file format (.+?)$/
          h[:file] = $1
          h[:attributes] ||= []
          h[:attributes] << ['file format', $2]
        when /architecture: (.+?), flags (0x.+?):/
          h[:attributes] << ['architecture', $1]
          flags = $2
          ary.shift =~ /^(.+)$/
          h[:attributes] << ['flags', "#{flags}: #{$1}"]
          ary.shift =~ /^start address (.+?)$/
          h[:attributes] << ['start address', $1]
        when /^Contents of section (.+?):$/
          h[:contents] ||= []
          h[:contents] << [$1, []]
          while s = ary.shift
            if s =~ /^ +([a-f0-9]+) +((?:[a-f0-9]+ )+) +(.{16})$/
              h[:contents][-1][1] << [$1, $2, $3]
            else
              ary.unshift(s)
              break
            end
          end
        when /^Disassembly of section (.+?):$/
          ary.unshift(s)
          dumps = []
          while s = ary.shift # extract disas part in dump file
            case s
            when /^$/
            when /^Disassembly of section (.+?):$/
              dumps << s
            when /^([a-f0-9]+) <(.+?)>:$/i
              dumps << s
            when /^ +([a-f0-9]+):\t/i
              dumps << s
            when /^\t\t\t\d+:/
            else
              ary.unshift(s)
              break
            end
          end
          h.merge!(parse_disas(dumps))
        end
      end
      h
    end
    def self.parse_disas dumps
      id, sec, sym = 0, '', ''
      jmp_srcs, jmp_dsts = [], []
      jmp = nil
      new_sym = nil
      last = []
      insts = []
      flows = []
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
        ENV['DEBUG'] && puts("dump: #{s}")
        case s
        when /^Disassembly of section (.+?):$/
          sec = $1
        when /^([a-f0-9]+) <(.+?)>:$/i
          ENV['DEBUG'] && puts("  new symbol #{sym}")
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
              ENV['DEBUG'] && puts("  asm[0][0]=='j': #{asm[1]}")
              insts[-1][:code] << [addr, hexs, *asm]
              if asm[1][0] == '*'
                # jmp *0xXXXX, can't deal this type, all as :jmp
                jmp = :jmp
              else
                asm[1] =~ /^([xa-f0-9]+)/
                flows << [id, $1.to_i(16), :jmp_succ]
                if asm[0] == 'jmp' # jmp doesn't line to next addr
                  ENV['DEBUG'] && puts(  'jmp = :jmp')
                  jmp = :jmp
                else
                  ENV['DEBUG'] && puts(  "jmp = :#{jmp}")
                  jmp = "jx_#{flows.size}".to_sym
                  flows << [id, 0, :jmp_fail]
                end
              end
            elsif jmp
              ENV['DEBUG'] && puts("  if jmp: #{jmp}")
              id = addr
              insts << {id: id, sec: sec, sym: nil, code: [[addr, hexs, *asm]]}
              if jmp =~ /^jx/
                flows[jmp[3..-1].to_i][1] = addr
              end
              jmp = nil
            elsif asm[0] =~ /^ret/
              ENV['DEBUG'] && puts('  if asm[0] =~ /^ret/')
              insts[-1][:code] << [addr, hexs, *asm]
              jmp = :ret
            elsif jmp_dsts.include?(addr) && !new_sym # jmp destination
              ENV['DEBUG'] &&
                puts(new_sym ? '  if new_sym' : 'if addr in jmp_dsts')
              if ![/^ret/].map{|r| last[2] =~ r}.any?
                ENV['DEBUG'] && puts("    add flow")
                flows << [id, addr, :next]
              end
              id = addr
              insts << {id: id, sec: sec, sym: nil, code: [[addr, hexs, *asm]]}
            else
              ENV['DEBUG'] && puts('  normal')
              insts[-1][:code] << [addr, hexs, *asm]
            end
            last = [addr, hexs, *asm]
          end # if s.size == 2
          new_sym = false
        end # case s
      end # dumps.map
      {instructions: insts, flows: flows}
    end
  end
end
