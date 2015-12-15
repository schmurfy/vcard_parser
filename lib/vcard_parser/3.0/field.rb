require 'time'

module VCardParser
  module V30
    
    class Field
      attr_reader :name, :group, :value, :params
      
      FORMAT = /^
          (?:(?<group>[a-zA-Z0-9\-]+)\.)?
          (?<name>[a-zA-Z0-9\-\/]+)
          (?<params> (?:;[A-Za-z-]+=[^;]+)+ )?
          :(?<value>.*)
        $/x
      
      def initialize(name, value, group = nil, params = {})
        @name = name
        @group = group
        @value = convert_value(value)
        @params = params
      end
      
      def full_name
        ret = ""
        ret << "#{@group}." if group
        ret << @name
        ret
      end
      
      def values
        if value
          value.split(';')
        else
          nil
        end
      end
      
      def self.parse(line)
        m = FORMAT.match(line.strip)
        if m
          params = {}
          if m[:params]
            m[:params].split(';').reject{|s| s.empty? }.each do |p|
              pname, pvalue = p.split('=')
              pname.downcase!
              params[pname] ||= []
              params[pname] << pvalue
            end
          end
          
          new(m[:name], m[:value], m[:group], params)
        else
          raise MalformedInput, line
        end
      end
      
      def to_s
        ret = full_name
                
        @params.each do |name, values|
          values.each do |v|
            ret << ";#{name}=#{v}"
          end
        end
        
        ret << ":#{dump_value(value)}"
        
        ret
      end
          
    private
      def convert_value(value)
        case name
        when "REV", "BDAY"  then Time.parse(value)
        when "NOTE"         then value.gsub('\r\n', "\n").gsub('\n', "\n")
        else
          value
        end
      end
      
      def dump_value(value)
        case name
        when "REV"    then value.iso8601
        when "BDAY"   then value.strftime("%Y-%m-%d")
        when "NOTE"   then value.gsub("\n", '\n')
        else
          value
        end
      end
      
    end
    
  end
end
