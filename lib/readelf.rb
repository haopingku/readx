module ReadX
  module ReadElf
    begin
      `readelf --version`
    rescue Errno::ENOENT => e
      e.message =~ /directory - (\S+)/
      raise NotSupportError.new($1)
    end
    def self.header file
      `readelf -h #{file}`
        .split(/\n+/)
        .select{|s| s =~ /^ +/}
        .map{|s| s =~ /^ +(.+?): +(.+?)$/; [$1, $2]}
        .inject({}){|h, a| h[a[0]] = a[1]; h}
    end
  end
end
