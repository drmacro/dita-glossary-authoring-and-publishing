require 'bundler'
require 'nokogiri'
require 'creek'

def writeFile (file)
  # Need path for map
  File.open("#{@directory}/#{@ditafile}", "w") { |f| f.write file }
  puts "Wrote: #{@directory}/#{@ditafile}"
end

def checklist (xmlbody)


end

@topics = Array.new
@terms = Array.new
@directory = Array.new
@ditafiles = Array.new


def glosswrap(para)
  @terms.each do |singleterm|
    read_buffer = para.to_s
    if read_buffer.include? singleterm
      read_buffer.gsub! singleterm, "<term keyref=\"#{singleterm}\" />"
      @writeme = true
    end
    para = read_buffer
  end
  return para
end



xlsheet = ARGV[0]
@map = ARGV[1]
@directory = File.dirname(@map)

#Dir::mkdir(@output) unless File.exists?(@output)

doc = Creek::Book.new(xlsheet)   # Read spreadsheet
sheet = doc.sheets[0] # pickup first sheet only
sheet.rows.each.with_index do |row, idx|   # go through each row
  if idx !=0  # Ignore the header row
    @terms.push(row["A#{idx+1}"])  # put each term into an array
  end
end

# Open the map

ditamap = Nokogiri::XML(open(@map))
links = ditamap.xpath("//topicref[@href]")

links.each do |link|
  @writeme = false  # Only write file if needed.
  @ditafile = (link.attr('href').to_s)
  file = Nokogiri::XML(open("#{@directory}/#{link.attr('href').to_s}"))
  filetype = file.xpath("/*").first.name # get type of file
  if filetype == "reference"
    txtfile = file.to_s
    filesplit = txtfile.split('<refbody>')
    filesplit[1] = glosswrap(filesplit[1])
    txtfile = filesplit.join("<refbody>")
  end
  if @writeme
    writeFile(txtfile)
  end
end




