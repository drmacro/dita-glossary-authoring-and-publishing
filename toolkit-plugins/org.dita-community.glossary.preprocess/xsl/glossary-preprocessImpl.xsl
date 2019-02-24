<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:dita-community="http://org.dita-community"
  xmlns:gloss="http://org.dita-community/glossary"
  exclude-result-prefixes="xs dita-community gloss"
  version="2.0">
  <!-- ========================================================
       Glossary preprocessing extension.
       
       Extends base 
       
       Copyright (c) 2019 DITA Community Project
       
       ======================================================== -->
  
  <!--
    Turn glossary sorting on.
    
    Recognized glossary lists will be sorted automatically when this is 
    true(), otherwise they will not be sorted.
    -->
  <xsl:param name="dita-community:sort-glossary" as="xs:string" select="'false'"/>
  <xsl:variable name="gloss:sort-glossary" as="xs:boolean"
    select="matches($dita-community:sort-glossary, 'yes|true|on|1', 'i')"
  />

  <!--
    Turn glossary filtering on
    
    When filtering is on, the normal-role glossary entries found or generated
    will be limited to those glossary entries used directly or indirectly by
    normal-role non-glossary-entry topics.
    -->
  <xsl:param name="dita-community:filter-glossary" as="xs:string" select="'false'"/>
  <xsl:variable name="gloss:filter-glossary" as="xs:boolean"
    select="matches($dita-community:filter-glossary, 'yes|true|on|1', 'i')"
  />
  
  <!--
    Turn glossary generation on.
    
    When true() and a recognized glossary list marker element is found (e.g.,
    <glossarylist/>), then the glossary will be generated. 
    
    If glossary filtering is turned on then the glossary will reflect those
    glossary entries used directly or indirectly from normal-role, non-glossary-entry
    topics.
    
    If glossary filtering is turned off then all glossary entry topics referenced
    by the map will be used to construct the generated glossary.
    -->
  <xsl:param name="dita-community:generate-glossary" as="xs:string" select="'false'"/>
  <xsl:variable name="gloss:generate-glossary" as="xs:boolean"
    select="matches($dita-community:generate-glossary, 'yes|true|on|1', 'i')"
  />
  
  
  <xsl:import href="glossary-sorter.xsl"/>
  
  <xsl:template match="/">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:message>+ [INFO] DITA Community glossary preprocessing:</xsl:message>
    <xsl:message>+ [INFO]   filter-glossary: <xsl:value-of select="$gloss:filter-glossary"/> (<xsl:value-of select="$dita-community:filter-glossary"/>)</xsl:message>
    <xsl:message>+ [INFO]   generate-glossary: <xsl:value-of select="$gloss:generate-glossary"/> (<xsl:value-of select="$dita-community:generate-glossary"/>)</xsl:message>
    <xsl:message>+ [INFO]   sort-glossary: <xsl:value-of select="$gloss:sort-glossary"/> (<xsl:value-of select="$dita-community:sort-glossary"/>)</xsl:message>
    
    <xsl:next-match>
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:next-match>
  </xsl:template>

</xsl:stylesheet>