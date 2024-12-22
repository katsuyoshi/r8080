class MemoryManager < I8080::MemoryManager
  attr_reader :vram_image, :size

  def initialize(options={})
    super(options)
    # rom 8kbyte
    @rom = options[:rom] || (0..0x1fff)
    # ram 1kbyte
    @ram = options[:ram] || (0x2000..0x23ff)
    # vram 7kbyte
    @vram = options[:vram] || (0x2400..0x3fff)
    # mask for mirror 16kbyte
    @mask = (options[:mirror] || 0x4000) - 1
    # image size
    @size = options[:size] || { width: 224, height: 256 }
    @vram_image = Image.new(@size[:width], @size[:height], [255, 0, 0, 0])
    @dot_on = Image.new(1, 1, [255, 255, 255, 255])
    @dot_off = Image.new(1, 1, [255, 0, 0, 0])
    @force = false
  end

  def [](*args)
    #return super
    case args.size
    when 1
      case args[0]
      when Range
        args[0].map do |i|
          addr = i & @mask
          if @rom.include?(addr) || @ram.include?(addr)
            @mem[addr]
          else
            0
          end
        end
      else
        addr = args[0] & @mask
        if @rom.include?(addr) || @ram.include?(addr)
          @mem[addr]
        else
          0
        end
      end

    when 2
      addr = args[0]
      size = args[1]
      a = []
      size.times do |i|
        a << self[(addr + i) & @mask]
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
          addr = a & @mask
          if @vram.include?(addr)
            draw_vram addr, v
          elsif @force || @ram.include?(addr)
            @mem[addr] = v
          end
        end
      else
        addr = args[0] & @mask
        if @vram.include?(addr)
          draw_vram addr, v
        elsif @force || @ram.include?(addr)
          @mem[addr] = v
        else
          0
        end
      end

    when 3
      addr = args[0] & @mask
      size = args[1]
      v = args[2]
      size.times do |i|
        adr = (addr + i) & @mask
        if @vram.include?(adr)
          draw_vram addr, v
        elsif @force || @ram.include?(adr)
          @mem[adr] = v[i]
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

  private

  def draw_vram addr, val
    @mem[addr] = val
    idx = (addr - @vram.first) * 8
    x = (idx / @size[:height]).to_i
    y = @size[:height] - (idx % @size[:height])
    v = val
    8.times do |i|
      if v & 0x80 == 0x80
        @vram_image.draw(x, y, @dot_on)
      else
        @vram_image.draw(x, y, @dot_off)
      end
      y -= 1
      v <<= 1
    end
  end

end
