require 'bundler'
require 'nokogiri'
require 'creek'

def writeFile (file)
  # Need path for map
  filename = File.join(@output,@filename)
  File.open("#{filename}", "w") { |f| f.write file }
  puts "Wrote: #{filename}"
end

def checklist (xmlbody)


end

@topics = Array.new
@terms = Array.new


def glosswrap(para)
  @terms.each do |singleterm|
    read_buffer = para.to_s
    if read_buffer.include? singleterm
      read_buffer.gsub! singleterm, "<term keyref=\"#{singleterm}\" />"
    end
    para = read_buffer
  end
  return para
end



xlsheet = ARGV[0]
@map = ARGV[1]
directory = File.dirname(@map)

#Dir::mkdir(@output) unless File.exists?(@output)

doc = Creek::Book.new(xlsheet)   # Read spreadsheet
sheet = doc.sheets[0] # pickup first sheet only
sheet.rows.each.with_index do |row, idx|   # go through each row
  if idx !=0  # Ignore the header row
    @terms.push(row["A#{idx+1}"])  # put each term into an array
  end
end

p @terms
# Open the map

ditamap = Nokogiri::XML(open(@map))
links = ditamap.xpath("//topicref[@href]")
ditafiles = Array.new
links.each do |link|
  ditafiles.push(link.attr('href').to_s)
  file = Nokogiri::XML(open("#{directory}/#{link.attr('href').to_s}"))  # open the file
  filetype = file.xpath("/*").first.name # get type of file
  if filetype == "reference"
    body = file.xpath("//refbody")
    replacedText = glosswrap(body)
    xml = Nokogiri::XML replacedText
    xml_replacement = xml.xpath("//refbody")
    body.content(xml_replacement)


    file.replace(body)

   #body.replace(xml_replacement)

    p body
    p file
   #body.send(:native_content=,glosswrap(body.to_s))

  end
  p body
end




=begin
require 'nokogiri'

text = '<html> <body> <div> <span class="blah">XSS Attack document</span> </div> </body> </html>'
html = Nokogiri::HTML(text)

# get the node span
node = html.at_xpath('//span[@class="blah"]')
# change its text content
node.content = node.content.gsub('XSS', '')

# create a node <a>
link = Nokogiri::XML::Node.new('a', html)
link['href'] = 'http://blah.com'
link.content = 'XSS'

# add it before the text
node.children.first.add_previous_sibling(link)

# print it
puts html.to_html
=end

