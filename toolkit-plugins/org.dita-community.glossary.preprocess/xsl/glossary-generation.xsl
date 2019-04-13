<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:dita-community="http://org.dita-community"
  xmlns:gloss="http://org.dita-community/glossary"
  xmlns:dci18n="http://org.dita-community/i18n"
  xmlns:dci18nfunc="http://org.dita-community/i18n/saxon-extensions"
  xmlns:df="http://dita2indesign.org/dita/functions"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"  
  
  exclude-result-prefixes="xs dita-community gloss dci18n dci18nfunc df map"
  expand-text="yes"
  version="3.0">
  <!-- ========================================================
       Glossary preprocessing extension: Glossary Generation
       
       This module generates a glossary navigation structure
       from the resource-only topicrefs to glossary entries
       when there is also an empty <glossarylist> element in 
       the publication.
       
       Implements mode "dita-community:glossary-generation" 
       
       Natively recognizes the following markup as being the
       point at which to generate the glossary:
       
       - <glossarylist> (BookMap)
       - <topicref outputclass="glossarylist"> (any map type)
       
       Copyright (c) 2019 DITA Community Project
       
       ======================================================== -->
  
  
  
</xsl:stylesheet>