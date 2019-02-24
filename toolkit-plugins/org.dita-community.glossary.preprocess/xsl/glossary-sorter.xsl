<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:dita-community="http://org.dita-community"
  exclude-result-prefixes="xs dita-community"
  version="2.0">
  <!-- ========================================================
       Glossary preprocessing extension: Glossary Sorter
       
       This module manages sorting glossary entries using a
       local-aware sort.
       
       Implements mode "dita-community:glossary-sort" 
       
       Natively recognizes the following markup as being the
       root of a glossary to be sorted:
       
       - <glossarylist> (BookMap)
       - <topicref outputclass="glossarylist"> (any map type)
       
       Copyright (c) 2019 DITA Community Project
       
       ======================================================== -->
  
  

  <xsl:template mode="dita-community:glossary-sort" 
    match="*[contains(@class, ' bookmap/glossarlist ')] | 
    *[contains(@class, ' map/topicref ')][tokenize(@outputclass, ' ') = ('glossarylist')]"
    >
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates mode="#current">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="dita-community:glossary-sort" match="*" priority="-1">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates mode="#current" select="@*, node()">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="dita-community:glossary-sort" match="text() | @* | comment() | processing-instruction()" priority="-1">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:sequence select="."/>
  </xsl:template>
  
  
</xsl:stylesheet>