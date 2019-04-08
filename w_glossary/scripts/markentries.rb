require 'bundler'
require 'nokogiri'
require 'creek'


def checklist (xmlbody)


end

@topics = Array.new
@terms = Array.new
@directory = Array.new
@ditafiles = Array.new


def glosswrap(para)                # Wraps glossary entries.
  @terms.each do |singleterm|
    read_buffer = para.to_s
    if read_buffer.include? "\s#{singleterm}"
      all = read_buffer.split(singleterm)  # only want first instance in topic
      all.each.each_with_index do |text, idx|
        if idx.eql?(0)
          @writeme = true
          all[0] = (text + "<term keyref=\"#{singleterm}\">#{singleterm}</term>")
        else
          all[idx] = (text)
        end
      end
     para = all.join("")
    end
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
  if filetype.eql?("reference")
    topictype = 'refbody'
  elsif filetype.eql?('topic')
    topictype = 'body'
  elsif filetype.eql?('concept')
    topictype = 'conbody'
  elsif filetype.eql?('troubleshooting')
    topictype = 'troublebody'
  elsif filetype.eql?('task')
    topictype = 'taskbody'
  end
  body = file.xpath("//#{topictype}")[0] # Only process the body. No processing short description or title.
  nextelements = body.element_children
  body.children = (glosswrap(nextelements))
  if @writeme
    File.write("#{@directory}/#{@ditafile}", file)
    p "Modified : #{@directory}/#{@ditafile}"
  else
    p "No Changes in: #{@directory}/#{@ditafile}"
  end
end




