<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:dita-community="http://org.dita-community"
  xmlns:gloss="http://org.dita-community/glossary"
  xmlns:dci18n="http://org.dita-community/i18n"
  xmlns:dci18nfunc="http://org.dita-community/i18n/saxon-extensions"
  xmlns:df="http://dita2indesign.org/dita/functions"
  
  exclude-result-prefixes="xs dita-community gloss dci18n dci18nfunc df"
  version="2.0">
  <!-- ========================================================
       Glossary preprocessing extension: Glossary Filter
       
       This module filters glossary topicrefs to reflect only
       those glossary entries referenced directly or indirectly
       from normal-role topics.
       
       Implements mode "dita-community:glossary-filter" 
       
       Natively recognizes the following markup as being the
       root of a glossary to be sorted:
       
       - <glossarylist> (BookMap)
       - <topicref outputclass="glossarylist"> (any map type)
       
       Copyright (c) 2019 DITA Community Project
       
       ======================================================== -->
  
  <!-- 
    Filters the input map base on the links.
    
    @return The filtered map and the link report. The link report, if generated,
    is the second document in the retured sequence.
    -->
  <xsl:template mode="dita-community:glossary-filter" match="/" as="document-node()+">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:variable name="localDebug" as="xs:boolean" select="false() or $doDebug"/>
    
    <xsl:variable name="normalRoleTopicrefs" as="element()*"
      select="/*//*[df:isNormalRoleTopicRef(.)]"
    />
    
    <xsl:if test="$localDebug">
      <xsl:message>+ [DEBUG] dita-community:glossary-filter: Have <xsl:value-of select="count($normalRoleTopicrefs)"/> normal-role topicrefs</xsl:message>
    </xsl:if>
    
    <xsl:variable name="normalRoleTopics" as="element()*">
      <xsl:apply-templates select="$normalRoleTopicrefs" mode="gloss:get-topics-for-topicrefs">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
        <xsl:with-param name="processDescendantTopicrefs" as="xs:boolean" tunnel="yes" select="false()"/>
        <xsl:with-param name="excludeClass" as="xs:string?" tunnel="yes" select="' glossentry/glossentry '"/>
      </xsl:apply-templates>
    </xsl:variable>

    <xsl:if test="$localDebug">
      <xsl:message>
+ [DEBUG] dita-community:glossary-filter: Have <xsl:value-of select="count($normalRoleTopics)"/> normal-role topics that are not glossary entries:</xsl:message>
<!--      <xsl:for-each select="$normalRoleTopics">
        <xsl:message>+ [DEBUG] [<xsl:value-of select="position()"/>] <xsl:value-of select="df:getNavtitleForTopic(.)"/> (<xsl:value-of select="base-uri(.)"/>)</xsl:message>
      </xsl:for-each>
-->    </xsl:if>
    
    <xsl:variable name="links" as="element()*">
      <xsl:apply-templates mode="gloss:get-links-from-topics" select="$normalRoleTopics">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
      </xsl:apply-templates>
    </xsl:variable>
    
    <xsl:if test="$localDebug">
      <xsl:message>
+ [DEBUG] dita-community:glossary-filter: Have <xsl:value-of select="count($links)"/> links:</xsl:message>
<!--      <xsl:for-each select="$links">
        <xsl:message>+ [DEBUG]   [<xsl:value-of select="position()"/>] <xsl:sequence select="."/></xsl:message>
      </xsl:for-each>        
-->    </xsl:if>
        
    <xsl:variable name="rootElem" as="element()" select="/*"/>
    <xsl:document>
      <xsl:sequence select="node()[. &lt;&lt; $rootElem]"/>
      <xsl:comment>[DEBUG] applying templates in mode dita-community:glossary-filter</xsl:comment>
      <xsl:apply-templates mode="#current">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
      </xsl:apply-templates>
      <xsl:comment>[DEBUG] After applying templates in mode dita-community:glossary-filter</xsl:comment>
      <xsl:sequence select="node()[. &gt;&gt; $rootElem]"/>
    </xsl:document>
    
    <!-- Make the link report -->
    <xsl:if test="$localDebug">
      <xsl:message>+ [DEBUG] dita-community:glossary-filter: Calling make-link-report...</xsl:message>
    </xsl:if>
    <xsl:call-template name="dita-community:make-link-report">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
      <xsl:with-param name="links" as="element()*" select="$links"/>
    </xsl:call-template>
    <xsl:if test="$localDebug">
      <xsl:message>+ [DEBUG] dita-community:glossary-filter: After make-link-report.</xsl:message>
    </xsl:if>
    
    
  </xsl:template>
  
  <xsl:template mode="dita-community:glossary-filter" match="*" priority="-1">
    <xsl:variable name="localDebug" as="xs:boolean" select="false()"/>
    
    <xsl:if test="$localDebug">
      <xsl:message>+ [DEBUG] dita-community:glossary-filter: Catch-all (<xsl:value-of select="concat(name(..), '/', name(.))"/>), outputclass="<xsl:value-of select="@outputclass"/>"</xsl:message>
    </xsl:if>
    
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates mode="#current" select="@*, node()">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$localDebug"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="dita-community:glossary-filter" match="text() | @* | comment() | processing-instruction()" priority="-1">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:variable name="localDebug" as="xs:boolean" select="false()"/>
    
    <xsl:if test="$localDebug">
      <xsl:message>+ [DEBUG] dita-community:glossary-filter: Catch-all for non-element node: <xsl:sequence select="."/></xsl:message>
    </xsl:if>
    <xsl:sequence select="."/>
  </xsl:template>  
  
</xsl:stylesheet>