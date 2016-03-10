# encoding: utf-8
require_relative '../spec_helper'

def data_path(path)
  File.expand_path(File.join(
      File.expand_path('../../data', __FILE__),
      path
    ))
end

def data_file(path)
  File.read( data_path(path) )
end

describe 'VCard' do
  
  should 'add a new field without parameters' do
    v = VCardParser::VCard.new("3.0")
    v.add_field("N", "Georges")
    
    v['N'].value.should == 'Georges'
  end
  
  describe 'vCard 3.0' do
    should 'handle blank lines' do
      vcards = VCardParser::VCard.parse( data_file('malformed3.0.vcf') )
      vcards.size.should == 1

      vcards[0].version.should == "3.0"
    end

    should 'parse simple card' do
      vcards = VCardParser::VCard.parse( data_file('vcard3.0.vcf') )
      vcards.size.should == 1
      
      vcards[0].version.should == "3.0"
      vcards[0]["PRODID"].value.should == "-//Apple Inc.//iOS 5.0.1//EN"
      vcards[0]["N"].value.should == "Durand;Christophe;;;"
      vcards[0]["FN"].value.should == "Christophe Durand"
      vcards[0]["UID"].value.should == "11"
    end
    
    should 'parse simple card with UID as first field' do
      data = <<-EOS
BEGIN:VCARD
UID:20121108T134354Z-1348-27ECEFA3-2-53E3B7B2.vcf
VERSION:3.0
PRODID:-//SOGoSync 0.5.0//NONSGML SOGoSync AddressBook//EN
FN:Pp, Tt
N:Pp;Tt
END:VCARD
      EOS
      
      vcards = VCardParser::VCard.parse(data)
      vcards.size.should == 1
      
      vcards[0].version.should == "3.0"
      vcards[0]['PRODID'].value.should == '-//SOGoSync 0.5.0//NONSGML SOGoSync AddressBook//EN'
      vcards[0]['UID'].value.should == '20121108T134354Z-1348-27ECEFA3-2-53E3B7B2.vcf'
      vcards[0]['FN'].value.should == 'Pp, Tt'
      vcards[0]['N'].value.should == 'Pp;Tt'
    end
    
    should 'parse multiple cards' do
      vcards = VCardParser::VCard.parse( data_file('two_vcard3.0.vcf') )
      vcards.size.should == 2
      
      vcards[0].version.should == "3.0"
      vcards[0]["PRODID"].value.should == "-//Apple Inc.//iOS 5.0.1//EN"
      vcards[0]["N"].value.should == "Durand;Christophe;;;"
      vcards[0]["FN"].value.should == "Christophe Durand"
      vcards[0]["UID"].value.should == "11"
      
      
      vcards[1].version.should == "3.0"
      vcards[1]["N"].value.should == "Jean;René;;;"
      vcards[1]["FN"].value.should == "Jean René"
      vcards[1]["UID"].value.should == "12"
    end
    
    should 'return firstname, lastname' do
      vcards = VCardParser::VCard.parse( data_file('two_vcard3.0.vcf') )
      vcards.size.should == 2
      
      vcards[0].firstname.should == "Christophe"
      vcards[0].lastname.should == "Durand"
    end
    
    should 'enumerate attributes 1' do
      vcards = VCardParser::VCard.parse( data_file('vcard3.0.vcf') )
      vcards.size.should == 1
      
      attrs = []
      
      vcards[0].each_field do |a|
        attrs << a
      end
      
      attrs.size.should == 12
    end
    
    should 'list groups' do
      vcards = VCardParser::VCard.parse( data_file('vcard3.0.vcf') )
      vcards.size.should == 1
      
      vcards[0].groups.to_a.should == %w(item1 item2)
    end
    
    should 'return fields for given group' do
      vcards = VCardParser::VCard.parse( data_file('vcard3.0.vcf') )
      vcards.size.should == 1
      
      fields = vcards[0].get_fields_by_group('item2')
      fields.size.should == 2
      
      fields['tel'].tap do |f|
        f.name.should == "TEL"
        f.value.should == "5 66"
      end
      
      fields['adr'].tap do |f|
        f.name.should == "ADR"
      end
    end
    
    should 'enumerate attributes 2' do
      vcards = VCardParser::VCard.parse( data_file('vcard3.0.vcf') )
      vcards.size.should == 1
      
      attrs = []
      
      vcards[0].each_field.sort_by(&:name).each do |a|
        attrs << a
      end
      
      n = -1
      attrs[n+= 1].tap do |a|
        a.group.should == "item2"
        a.name.should == "ADR"
        a.value.should == ";;3 rue du chat;Dris;;90880;FRANCE"
        a.params.should == {'type' => ['HOME', 'pref']}
      end
      
      attrs[n+= 1].tap do |a|
        a.name.should == "BDAY"
        a.value.should == Time.parse('1900-01-01')
        a.params.should == {'value' => ['date']}
      end

      
      attrs[n+= 1].tap do |a|
        a.name.should == "FN"
        a.value.should == "Christophe Durand"
        a.params.should == {}
      end
      
      attrs[n+= 1].tap do |a|
        a.name.should == "N"
        a.value.should == "Durand;Christophe;;;"
        a.params.should == {}
      end
      
      attrs[n+= 1].tap do |a|
        a.name.should == "ORG"
        a.value.should == "Op;"
        a.params.should == {}
      end
      
      attrs[n+= 1].tap do |a|
        a.name.should == "PHOTO"
        a.value.should.include?("AAD/4gxYSUNDX1BST0ZJTEUAAQEAAAxITGlub")
        a.params.should == {"encoding"=>["b"], "type"=>["JPEG"]}
      end
      
      attrs[n+= 1].tap do |a|
        a.name.should == "PRODID"
        a.value.should == "-//Apple Inc.//iOS 5.0.1//EN"
        a.params.should == {}
      end

      attrs[n+= 1].tap do |a|
        a.name.should == "REV"
        a.value.should == Time.parse("2012-10-31T16:08:22Z")
        a.params.should == {}
      end
      
      attrs[n+= 1].tap do |a|
        a.group.should == "item1"
        a.name.should == "TEL"
        a.value.should == "2 56 38 54"
        a.params.should == {'type' => %w(pref)}
      end

      attrs[n+= 1].tap do |a|
        a.group.should == "item2"
        a.name.should == "TEL"
        a.value.should == "5 66"
        a.params.should == {'type' => %w(pref)}
      end

      attrs[n+= 1].tap do |a|
        a.group.should == nil
        a.name.should == "TEL"
        a.value.should == "3 55"
        a.params.should == {'type' => %w(CELL VOICE)}
      end

      attrs[n+=1].tap do |a|
        a.name.should == "UID"
        a.value.should == "11"
        a.params.should == {}
      end
      
    end
    
    should "raise an error if version is not supported" do
      ->{
        VCardParser::VCard.parse( data_file('vcard2.1.vcf') )
        }.should.raise(VCardParser::UnsupportedVersion)
    end
    
    
    should 'parse and rebuild a full vcard' do
      vcard_data = <<-EOS
BEGIN:VCARD
VERSION:3.0
PRODID:-//Apple Inc.//iOS 5.0.1//EN
N:Durand;Christophe;;;
FN:Christophe Durand
ORG:Op;
item1.TEL;type=pref:2 56 38 54
item2.TEL;type=pref:5 66
TEL;type=CELL;type=VOICE:3 55
item2.ADR;type=HOME;type=pref:;;3 rue du chat;Dris;;90880;FRANCE
BDAY;value=date:1900-01-01
REV:2012-10-31T16:08:22Z
UID:12
END:VCARD
      EOS
      
      cards = VCardParser::VCard.parse(vcard_data)
      cards.size.should == 1
      cards[0]['TEL', 'item1'].value.should == '2 56 38 54'
      cards[0].to_s.should == vcard_data
    end

    should 'generate vcard from data' do
      data = data_file('vcard3.0.vcf')
      vcard = VCardParser::VCard.parse(data).first
      vcard.vcard.should == data
      vcard.to_s.should == data
    end
    
    should 'generate partial vCard' do
      data = data_file('vcard3.0.vcf')
      vcard = VCardParser::VCard.parse(data).first
      vcard.vcard.should == data
      vcard.to_s(%w(VERSION UID NICKNAME EMAIL FN)).should == <<-EOS
BEGIN:VCARD
VERSION:3.0
FN:Christophe Durand
UID:11
END:VCARD
      EOS
    end
    
  end
  
end
