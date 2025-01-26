class MemoryManager < I8080::MemoryManager

  def initialize(options={})
    super(options)
    # rom 1kbyte
    @rom = options[:rom] || (0x0000..0x03ff)
    # ram 1kbyte
    @ram = options[:ram] || (0x8000..0x83ff)
    @force = false
  end

  def [](*args)
    #return super
    case args.size
    when 1
      case args[0]
      when Range
        args[0].map do |i|
          a = i
          if @rom.include?(a) || @ram.include?(a)
            @mem[a]
          else
            0
          end
        end
      else
        a = args[0]
        if @rom.include?(a) || @ram.include?(a)
          @mem[a]
        else
          0
        end
      end

    when 2
      addr = args[0]
      size = args[1]
      a = []
      size.times do |i|
        a << self[addr + i]
      end
      a
    end
  end

  def []=(*args)
    case args.size
    when 2
      v = args[1]
      case args[0]
      when Range
        args[0].each_with_index do |a, i|
          adr = a
          if @force || @ram.include?(adr)
            @mem[adr] = v[i]
          end
        end
      else
        adr = args[0]
        if @force || @ram.include?(adr)
          @mem[adr] = v
        else
          0
        end
      end

    when 3
      adr = args[0]
      size = args[1]
      v = args[2]
      size.times do |i|
        if @force || @ram.include?(adr)
          @mem[(adr + i)] = v[i]
        end
      end
    end
  end

  # Usually, the ROM memory is read-only.
  # This method enables to force write to the ROM memory.
  def force_write
    begin
      @force = true
      yield
    ensure
      @force = false
    end
  end

end
