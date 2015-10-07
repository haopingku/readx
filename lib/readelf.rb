module ReadX
  module ReadElf
    begin
      `readelf --version`
    rescue Errno::ENOENT => e
      e.message =~ /directory - (\S+)/
      raise NotSupport::Cmd, $1
    end
    def self.header file
      `readelf -h #{file}`
        .split(/\n+/)
        .select{|s| s =~ /^ +/}
        .map{|s| s =~ /^ +(.+?): +(.+?)$/; [$1, $2]}
    end
  end
end
