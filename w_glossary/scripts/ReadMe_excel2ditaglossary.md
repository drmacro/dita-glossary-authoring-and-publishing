# Using the Excel to DITA glossary script

## Usage
```
excel2ditaglossary <Excel file> <output directory>
```
### Summary
excel2ditaglossary allows you to use an Excel spreadsheet to maintain glossary entries, then use that spreadsheet to create a DITA glossary topic for each entry.

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

## Output Directory

This step is optional. If you do not provide a directory, the script uses the directory that the Excel file is in to generate the topics. You do not have create the directory before specifying it. It will be created for you, if it doesn't exist.

## Requirements

- Ruby 2.x
- Ruby gems: 
-- Nokogiri
-- creek

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