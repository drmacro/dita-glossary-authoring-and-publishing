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
    p body.to_s


  end
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

