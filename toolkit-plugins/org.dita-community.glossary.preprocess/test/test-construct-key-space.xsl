<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:df="http://dita2indesign.org/dita/functions"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:relpath="http://dita2indesign/functions/relpath"
  xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  exclude-result-prefixes="relpath df dita-ot map"
  expand-text="yes"
  version="3.0">
  
  <xsl:import href="plugin:org.dita-community.common.xslt:xsl/relpath_util.xsl"/>
  <xsl:import href="plugin:org.dita-community.common.xslt:xsl/dita-support-lib.xsl"/>     
  <xsl:import href="../xsl/construct-key-spaces.xsl"/>
  
  <xsl:template match="/">
    <xsl:variable name="df:keySpaces" as="map(*)">
      <xsl:call-template name="df:construct-key-spaces">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="true()"/>
      </xsl:call-template>
    </xsl:variable>
    
    <xsl:message>+ [TEST] Have a keySpaces result: {exists($df:keySpaces)}</xsl:message>
    
    <test-result>
      <xsl:sequence select="df:report-key-spaces($df:keySpaces)"/>      
    </test-result>
    
  </xsl:template>
  
</xsl:stylesheet>