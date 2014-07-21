require_relative '../../spec_helper'

describe 'Field 3.0' do
  should 'parse grouped field' do
    f = VCardParser::V30::Field.parse("item1.TEL;type=pref:1 24 54 36")
    f.group.should == "item1"
    f.name.should == "TEL"
    f.value.should == "1 24 54 36"
    f.params.should == {'type' => ['pref']}
    
    f.full_name.should == "item1.TEL"
  end
  
  should 'parse NOTE field (\n)' do
    f = VCardParser::V30::Field.parse('NOTE:two\nlines\nand three')
    f.name.should == "NOTE"
    f.value.should == "two\nlines\nand three"
  end
  
  should 'parse NOTE field (\r\n)' do
    f = VCardParser::V30::Field.parse('NOTE:two\r\nlines\r\nand three')
    f.name.should == "NOTE"
    f.value.should == "two\nlines\nand three"
  end
  
  should 'parse empty field' do
    f = VCardParser::V30::Field.parse("FN:")
    f.group.should == nil
    f.name.should == "FN"
    f.value.should == ""
    f.params.should == {}
  end
  
  should 'parse extension field' do
    f = VCardParser::V30::Field.parse("X-ABShowAs:COMPANY")
    f.group.should == nil
    f.name.should == "X-ABShowAs"
    f.value.should == "COMPANY"
    f.params.should == {}
  end
  
  should 'parse extension field with numbers' do
    f = VCardParser::V30::Field.parse("X-HomeAddress1:5 rue de la Roguenette")
    f.group.should == nil
    f.name.should == "X-HomeAddress1"
    f.value.should == "5 rue de la Roguenette"
    f.params.should == {}
  end
  
  # X-HomeState/Prov
  should 'parse extension field with /' do
    f = VCardParser::V30::Field.parse("X-HomeState/Prov:5 rue de la Roguenette")
    f.group.should == nil
    f.name.should == "X-HomeState/Prov"
    f.value.should == "5 rue de la Roguenette"
    f.params.should == {}
  end
  
  should 'parse simple line' do
    f = VCardParser::V30::Field.parse("PRODID:-//Apple Inc.//Mac OS X 10.8.2//EN")
    f.group.should == nil
    f.name.should == "PRODID"
    f.value.should == "-//Apple Inc.//Mac OS X 10.8.2//EN"
    f.params.should == {}
  end
  
  should 'parse dat field' do
    f = VCardParser::V30::Field.parse("REV:2012-10-29T21:23:09Z")
    f.group.should == nil
    f.name.should == "REV"
    f.value.should == Time.parse("2012-10-29T21:23:09Z")
    f.params.should == {}
  end
  
  should 'parse line with parameters' do
    f = VCardParser::V30::Field.parse("TEL;type=WORK;type=VOICE;type=pref:1234")
    f.group.should == nil
    f.name.should == "TEL"
    f.value.should == "1234"
    f.params.should == {
      'type' => %w(WORK VOICE pref)
    }
  end
  
  should 'ignore parameters name case' do
    f = VCardParser::V30::Field.parse("TEL;type=WORK;type=VOICE;Type=pref;tYPe=something:1234")
    f.group.should == nil
    f.name.should == "TEL"
    f.value.should == "1234"
    f.params.should == {
      'type' => %w(WORK VOICE pref something)
    }
  end
  
  should 'generate vcf line for NOTE' do
    f = VCardParser::V30::Field.new('NOTE', "two\nlines\nand three")
    f.to_s.should == 'NOTE:two\nlines\nand three'
  end
  
  should 'generate vcf line from data' do
    line = "TEL;type=WORK;type=VOICE;type=pref:1234"
    f = VCardParser::V30::Field.parse(line)
    f.to_s.should == line
  end
  
  should 'generate vcf line from converted data' do
    line = "REV:2012-10-29T21:23:09Z"
    f = VCardParser::V30::Field.parse(line)
    f.to_s.should == line
  end
  
  should 'generate vcf line from data with group' do
    line = "item1.TEL;type=pref:1 24 54 36"
    f = VCardParser::V30::Field.parse(line)
    f.to_s.should == line
  end
  
  should 'return an array of values' do
    line = %{ORG:ABC, Inc.;North American Division;Marketing}
    f = VCardParser::V30::Field.parse(line)
    f.to_s.should == line
    f.values.should == ["ABC, Inc.", "North American Division", "Marketing"]
  end

  
end
