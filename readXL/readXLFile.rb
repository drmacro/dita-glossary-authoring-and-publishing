require 'bundler'
require 'creek'
require 'nokogiri'

def writeFile (file)
  # Need path for map
  filename = File.join(@output,@filename)
  File.open("#{filename}", "w") { |f| f.write file }
  puts "Wrote: #{filename}"
end

@topics = Array.new


xlsheet = ARGV[0]
@output = ARGV[1]

Dir::mkdir(@output) unless File.exists?(@output)

doc = Creek::Book.new(xlsheet)
sheet = doc.sheets[0]

sheet.rows.each.with_index do |row, idx|
  # index 0 is the header row. If you remove the header row, then remove the if statement.

  if idx != 0
    @filename = "#{row["A#{idx+1}"].downcase.delete(' ').gsub(/[(,)']/ , '_')}.xml"
    @topics.push(@filename)
    begin
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.doc.create_internal_subset(
              'glossentry',
              "-//OASIS//DTD DITA Glossary//EN",
              "glossary.dtd"
          )
          xml.glossentry('id' => row["A#{idx+1}"].downcase.delete(' ').gsub(/[(,)']/ , '_')) do
            xml.glossterm row["A#{idx+1}"]
            xml.glossdef row["B#{idx+1}"]
          end
        end
        writeFile(builder.to_xml)
    end
  end
end

# Build map
#
# <!DOCTYPE map PUBLIC "-//OASIS//DTD DITA Map//EN" "map.dtd">
# <map>
#
# </map>

builder = Nokogiri::XML::Builder.new do |ditamap|
  ditamap.doc.create_internal_subset(
    'map',
    "-//OASIS//DTD DITA Map//EN",
    "map.dtd"
  )
  ditamap.map('id' =>'glossary_entries')do
    ditamap.title 'Glossary Map'
    @topics.each do |indfile|
      ditamap.topicref('href' => indfile, 'key' => indfile)
    end
  end
end

# build map file
contents = builder.to_xml
filename = File.join(@output,'glossaryentries.ditamap')
File.open("#{filename}", "w") { |f| f.write contents }
puts "Wrote: #{filename}"