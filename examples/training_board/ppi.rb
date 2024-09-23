require 'i8080'

class PPI < I8080::IoDelegate

  attr_reader :mode_a, :mode_b, :mode_c_l, :mode_c_h
  attr_reader :port_a, :port_b, :port_c
  attr_reader :key_queue

  ('0'..'9').each do |n|
    PPI.const_set "KEY_#{n}", n.ord
  end
  ('A'..'F').each do |n|
    PPI.const_set "KEY_#{n}", n.ord
  end
  KEY_RUN = 'R'.ord
  KEY_RET = "\r".ord
  KEY_ADRS_SET = ' '.ord
  KEY_READ_DEC = ",".ord
  KEY_READ_INC = ".".ord
  KEY_WRITE_INC = "/".ord
  KEY_STORE_DATA = 'S'.ord
  KEY_LOAD_DATA = 'L'.ord
  KEY_STEP_ON = '↑'.ord
  KEY_STEP_OFF = '↓'.ord

  def initialize
    super
    @port_a = 0
    @port_b = 0
    @port_c = 0
    @control = 0
    @mode = 0
    @mode_a = :input
    @mode_b = :input
    @mode_c_l = :input
    @mode_c_h = :input
    @pressed_keys = []
    @key_queue = Queue.new
    @keys_expired = {}
    @key_queue.push nil
  end

  # Key assign
  # 0: 0, 1: 1, 2: 2, 3: 3, 4: 4, 5: 5, 6: 6, 7: 7, 8: 8, 9: 9,
  # A: A, B: B, C: C, D: D, E: E, F: F,
  # RUN: R, RET: RETURN, ADRS SET: SPACE,
  # READ DEC: ',(<)', READ INC: .(>), WRITE INC: /(?),
  # STORE DATA: S, LOAD DATA: L
  # RESET: ESC
  def in port
    case port & 0x3
    when 0
      return @port_a unless @mode_a == :input && @mode_c_h == :output
      
      @key_queue.pop
      v = 0xff

      if @port_c[4] == 0
        v = v & ~(1 << 0) if @pressed_keys.include?(KEY_0)
        v = v & ~(1 << 1) if @pressed_keys.include?(KEY_1)
        v = v & ~(1 << 2) if @pressed_keys.include?(KEY_2)
        v = v & ~(1 << 3) if @pressed_keys.include?(KEY_3)
        v = v & ~(1 << 4) if @pressed_keys.include?(KEY_4)
        v = v & ~(1 << 5) if @pressed_keys.include?(KEY_5)
        v = v & ~(1 << 6) if @pressed_keys.include?(KEY_6)
        v = v & ~(1 << 7) if @pressed_keys.include?(KEY_7)
      end
      if @port_c[5] == 0
        v = v & ~(1 << 0) if @pressed_keys.include?(KEY_8)
        v = v & ~(1 << 1) if @pressed_keys.include?(KEY_9)
        v = v & ~(1 << 2) if @pressed_keys.include?(KEY_A)
        v = v & ~(1 << 3) if @pressed_keys.include?(KEY_B)
        v = v & ~(1 << 4) if @pressed_keys.include?(KEY_C)
        v = v & ~(1 << 5) if @pressed_keys.include?(KEY_D)
        v = v & ~(1 << 6) if @pressed_keys.include?(KEY_E)
        v = v & ~(1 << 7) if @pressed_keys.include?(KEY_F)
      end
      if @port_c[6] == 0
        v = v & ~(1 << 0) if @pressed_keys.include?(KEY_RUN)
        v = v & ~(1 << 1) if @pressed_keys.include?(KEY_RET)
        v = v & ~(1 << 2) if @pressed_keys.include?(KEY_ADRS_SET)
        v = v & ~(1 << 3) if @pressed_keys.include?(KEY_READ_DEC)
        v = v & ~(1 << 4) if @pressed_keys.include?(KEY_READ_INC)
        v = v & ~(1 << 5) if @pressed_keys.include?(KEY_WRITE_INC)
        v = v & ~(1 << 6) if @pressed_keys.include?(KEY_STORE_DATA)
        v = v & ~(1 << 7) if @pressed_keys.include?(KEY_LOAD_DATA)
      end
      expires = @keys_expired.map do |k, v|
        k if v < Time.now
      end
      @pressed_keys -= expires
      @keys_expired.delete_if do |k, v|
        expires.include?(k)
      end
      @key_queue.push nil
      v
    when 1
      @port_b
    when 2
      @port_c
    end
  end
  
  def out port, data
    case port & 0x3
    when 0
      @port_a = data if @mode_a == :output
    when 1
      @port_b = data if @mode_b == :output
    when 2
      mask = (@mode_c_h == :output ? 0xf0 : 0x00) |
             (@mode_c_l == :output ? 0x0f : 0x00)
      @port_c = data & mask
    when 3
      if data & 0x80 == 0
        bit = (data >> 1) & 0x07
        set = data & 0x01 == 0 ? 0 : 1
        if @mode_c_h == :output && bit >= 4 ||
           @mode_c_l == :output && bit < 4
          @port_c = (@port_c & ~(1 << bit)) | (set << bit)
        end
      else
        @mode_a = data[4] == 0 ? :output : :input
        @mode_c_h = data[3] == 0 ? :output : :input
        @mode_b = data[1] == 0 ? :output : :input
        @mode_c_l = data[0] == 0 ? :output : :input
      end
    end
  end

  def press key, expired_at=Time.now + 0.05
    @key_queue.pop
    @pressed_keys << key.ord
    @keys_expired[key.ord] = expired_at
    @pressed_keys.uniq!
    @key_queue.push nil
  end

end

