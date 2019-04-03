require 'bundler'
require 'nokogiri'
require 'creek'

def writeFile (file)
  # Need path for map
  filename = File.join(@output,@filename)
  File.open("#{filename}", "w") { |f| f.write file }
  puts "Wrote: #{filename}"
end

@topics = Array.new
@terms = Array.new


xlsheet = ARGV[0]
@output = ARGV[1]

Dir::mkdir(@output) unless File.exists?(@output)

doc = Creek::Book.new(xlsheet)
sheet = doc.sheets[0]

sheet.rows.each.with_index do |row, idx|

  if idx !=0
    @terms.push(row["A#{idx+1}"])
  end


end

puts @terms