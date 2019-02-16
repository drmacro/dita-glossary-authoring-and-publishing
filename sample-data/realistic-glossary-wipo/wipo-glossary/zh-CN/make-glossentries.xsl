<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xs"
  version="3.0">
  
  <xsl:output indent="yes"
    doctype-public="-//OASIS//DTD DITA BookMap//EN"
    doctype-system="bookmap.dtd"
  />
  <xsl:output indent="yes" name="glossentry"
    doctype-public="-//OASIS//DTD DITA Glossary Entry//EN"
    doctype-system="glossentry.dtd"
  />
  
  <xsl:key name="elementsById" match="*[@id]" use="@id"/>
  
  <xsl:template match="/">
    <bookmap>
      <booktitle>
        <mainbooktitle>WIPO Glossary zh-CN</mainbooktitle>
      </booktitle>
      <frontmatter>
        <booklists>
          <glossarylist>
            <xsl:apply-templates select="/*"/>
          </glossarylist>
        </booklists>
      </frontmatter>
    </bookmap>
        
  </xsl:template>
  
  <xsl:template match="/*">
    <xsl:for-each-group select="*" group-starting-with="p[empty(*)][not(starts-with(., '('))][string-length(normalize-space(.)) lt 10 ]">
      <xsl:variable name="glossaryID" as="xs:string" select="'gloss_' || position()"/>
      <xsl:variable name="resultURL" as="xs:string"
        select="$glossaryID || '.dita'"
      />
      <topicref keys="{$glossaryID}" href="{$resultURL}"/>
      <xsl:result-document format="glossentry" href="{$resultURL}">
        <glossentry id="{$glossaryID}">
          <glossterm><xsl:value-of select="."/></glossterm>
          <glossdef>
            <xsl:apply-templates select="tail(current-group())"/>
          </glossdef>
        </glossentry>
      </xsl:result-document>
    </xsl:for-each-group>
  </xsl:template>
  
  <xsl:template match="ph[starts-with(@id, '_ftnref')]" priority="10">
    <xsl:variable name="callout" as="xs:string" select="normalize-space(.)"/>
    <xsl:variable name="fnNumber" as="xs:string" select="substring-after(@id, '_ftnref')"/>
    <xsl:variable name="targetID" as="xs:string" select="'_ftn' || $fnNumber"/>
    <xsl:variable name="footnotePara" as="element()?" select="key('elementsById', $targetID, root(.))/parent::*"/>
    <fn>
      <xsl:apply-templates select="$footnotePara/node()"/>
    </fn>
  </xsl:template>
  
  <xsl:template match="ph[starts-with(@id, '_ftn')]">
    <!-- Ignore footnote callout phrases -->
  </xsl:template>
  
  <xsl:template match="p[matches(., '^\s*$')]">
    <!-- Throw it away -->
  </xsl:template>
  
  <xsl:template match="*" priority="-1">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*, node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="text() | @* | comment() | processing-instruction()">
    <xsl:sequence select="."/>
  </xsl:template>
</xsl:stylesheet>