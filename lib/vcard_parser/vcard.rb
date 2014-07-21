module VCardParser
  ParsingError = Class.new(RuntimeError)
  
  UnsupportedVersion = Class.new(ParsingError)
  MalformedInput = Class.new(ParsingError)
  
  class VCard
    attr_reader :version, :fields
    
    VCARD_FORMAT = /
        BEGIN:VCARD\s+
        (.+?)
        END:VCARD\s*
      /xm
    
    def initialize(version, fields = [])
      @version = version
      @fields = fields
    end
    
    def self.parse(data)
      data.gsub!(/\r?\n /, "") # inline base64 data to not break parser
      data.scan(VCARD_FORMAT).map do |vcard_data|
        # find the version to choose the correct parser
        lines = vcard_data[0].each_line.map(&:strip)
        
        version_line_index = lines.index{|str| str.start_with?('VERSION:') }
        
        unless version_line_index
          raise MalformedInput, "Unable to find VERSION field"
        end
        
        # remove version field
        version_line = lines.delete_at(version_line_index)
        
        key, version = version_line.split(':')
        
        new(version).tap do |card|
          lines.each do |line|
            card.add_field_from_string(line)
          end
        end
        
      end
    end
    
    def add_field_from_string(line)
      f = field_class.parse(line)
      @fields << f
    end
    
    def add_field(*args)
      f = field_class.new(*args)
      @fields << f
    end
    
    def values(key, group = nil)
      @fields.select do |f|
        (f.name == key) &&
        (!group || (f.group == group))
      end
    end
    
    def [](key, group = nil)
      v = values(key, group)
      v.empty? ? nil : v[0]
    end
    
    def each_field(&block)
      @fields.each(&block)
    end
    
    def vcard(wanted_fields = [])
      ret = ["BEGIN:VCARD"]
      
      if wanted_fields.empty? || wanted_fields.include?('VERSION')
        ret << "VERSION:#{@version}"
      end
      
      @fields.each do |f|
        if wanted_fields.empty? || wanted_fields.include?(f.name)
          ret << f.to_s
        end
      end
      
      ret << "END:VCARD\n"
      ret.join("\n")
    end
    
    alias :to_s :vcard
  
  
  private
    def field_class
      @field_class ||= case version
        when '3.0'  then V30::Field
        else
          raise UnsupportedVersion, version
      end
    end
        
  end
end
