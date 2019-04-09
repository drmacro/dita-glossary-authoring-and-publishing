require 'nokogiri'


thefile = ARGV[0]


htmlFile = Nokogiri::HTML(open(thefile))

terms = htmlFile.css('dt')
defs = htmlFile.css('dd')

terms.each.with_index do |term, idx|
#  p "#{term.text}\t#{defs[idx].text}".gsub!(/\n\s+/, " ")
  newdef = defs[idx].text.gsub!(/\n\s+/, " ")
    if newdef.nil?
      newdef = defs[idx].text
    end
 puts "#{term.text}\t#{newdef}"
end
