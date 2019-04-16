# Using the markentries Script

## Usage
```
markentries <Excel file> <ditmap>
```
### Summary
markentries allows you to use an Excel spreadsheet to maintain glossary entries, then use that spreadsheet to mark the first instance of the terms in each topic listed in the DITA map or bookmap.

terms found in the DITA topics use keydefs and are mapped to the actual word minus any invalid XML characters and white space. For example:
```
<term keyref="advancedperipheralbus">Advanced Peripheral Bus</term>
```
Keys are mapped to the topics using the ***glossaryentries.ditamap***. 

If a term has already been defined within the topic, it is skipped. 

## Excel Format
The first row is considered the header row and will never be processed. The spreadsheet structure looks like this:

<table>
<tr>
	<th>Term</th>
	<th>Definition</th>
</tr>
<tr>
	<td>actual term</td>
	<td>actual definition</td>
</tr>
</table>

## Requirements

- Ruby 2.x
- Ruby gems: 
-- Nokogiri
-- creek
- Excel spreadsheet with terms and definitions.

### Getting started with Ruby

If you haven't ever used ruby, you may need to install it. 

- [ruby language](https://www.ruby-lang.org/en/downloads/)

There are versions for linux, Mac OS X, and Windows.
Ruby gems are libraries used to perform certain things. I used two for this project; creek is used to read the Excel data, nokogiri is the XML library used to read and write XML data. 

After Ruby is installed, you need to install the libraries. This is done by running: 
```
bundler install
```
This will look at your Ruby gems and install any needed gems for this script. 