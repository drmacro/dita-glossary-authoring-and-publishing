<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:dita-community="http://org.dita-community"
  xmlns:gloss="http://org.dita-community/glossary"
  xmlns:dci18n="http://org.dita-community/i18n"
  xmlns:dci18nfunc="http://org.dita-community/i18n/saxon-extensions"
  
  exclude-result-prefixes="xs dita-community gloss dci18n dci18nfunc"
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
  
  <xsl:variable name="gloss:customCollatorUri" as="xs:string"
    select="'http://org.dita-community.i18n.zhCNawareCollator?lang=zh-CN'"
  />
  <xsl:variable name="gloss:defaultCollatorUri" as="xs:string"
    select="'http://www.w3.org/2005/xpath-functions/collation/codepoint'"
  />
  
  <xsl:variable name="gloss:collatorUri" as="xs:string"
    select="$gloss:customCollatorUri"
  />

  <xsl:template mode="dita-community:glossary-sort" 
    match="*[contains(@class, ' bookmap/glossarlist ')] | 
    *[contains(@class, ' map/topicref ')][tokenize(@outputclass, ' ') = ('glossarylist')]"
    >
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:variable name="localDebug" as="xs:boolean" select="true() or $doDebug"/>
    
    <xsl:if test="$localDebug">
      <xsl:message>+ [DEBUG] dita-community:glossary-sort: Have a glossary list topicref (<xsl:value-of select="concat(name(..), '/', name(.))"/>) starting...</xsl:message>
    </xsl:if>
    
    <!-- Groups and sorts the the direct-child topicrefs of the glossary list. This code assumes that the 
         topicrefs are not already grouped.
         
         There are a couple of ways this could work, including looking at the entire descendant map at this
         point and constructing a flat list of references but that could pose its own problems.
         
         To keep it simple, assuming that the children are the topicrefs to be sorted.
         
      -->
    
    <!-- 1: Get the topicrefs to be sorted 
    
            Topicrefs to topics
    -->
    
    <xsl:variable name="topicrefsToSort" as="element()*" 
      select="*[contains(@class, ' map/topicref ')][@href ne ''][empty(@format) or (@format eq 'dita')]">
    </xsl:variable>    
    
    <xsl:if test="$localDebug">
      <xsl:message>+ [DEBUG] dita-community:glossary-sort: Found <xsl:value-of select="count($topicrefsToSort)"/> topicrefs to be sorted.</xsl:message>
    </xsl:if>
    
    <!-- 2: Group and sort the topics -->
    <!-- collation="{$gloss:collatorUri}" -->
    <xsl:for-each-group select="$topicrefsToSort" group-by="gloss:getGroupingKey(., $localDebug)">
      <xsl:sort select="current-grouping-key()"/>
      <xsl:if test="$localDebug">
        <xsl:message>+ [DEBUG] dita-community:glossary-sort: [<xsl:value-of select="position()"/>] Grouping key="<xsl:value-of select="current-grouping-key()"/>"</xsl:message>
      </xsl:if>
      
      <topichead class="+ map/topicref mapgroup-d/topichead ">
        <topicmeta class="- map/topicmeta ">
          <navtitle class="- topic/navtitle "><xsl:value-of select="gloss:getGroupLabel(current-grouping-key(), $localDebug)"/></navtitle>  
        </topicmeta>
        <xsl:if test="$localDebug">
          <xsl:message>+ [DEBUG] dita-community:glossary-sort: [<xsl:value-of select="position()"/>] Have <xsl:value-of select="count(current-group())"/> topics in this group.</xsl:message>
        </xsl:if>
        <xsl:apply-templates mode="#current" select="current-group()">
          <xsl:sort collation="{$gloss:collatorUri}" select="gloss:getPrimarySortKeyForTopicref(., 'first', $localDebug)"/>
          <!--<xsl:sort collation="{$gloss:collatorUri}" select="dci18n:getBaseSortKeyForTopicref(.)"/>-->
        </xsl:apply-templates>
      </topichead>
    </xsl:for-each-group>
    
    <xsl:if test="$localDebug">
      <xsl:message>+ [DEBUG] dita-community:glossary-sort: <xsl:value-of select="concat(name(..), '/', name(.))"/> Done.</xsl:message>
    </xsl:if>
  </xsl:template>
  
  <xsl:template mode="dita-community:glossary-sort" match="*" priority="-1">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:variable name="localDebug" as="xs:boolean" select="false()"/>

    <xsl:if test="$localDebug">
      <xsl:message>+ [DEBUG] dita-community:glossary-sort: Catch-all (<xsl:value-of select="concat(name(..), '/', name(.))"/>), outputclass="<xsl:value-of select="@outputclass"/>"</xsl:message>
    </xsl:if>
    
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates mode="#current" select="@*, node()">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$localDebug"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="dita-community:glossary-sort" match="text() | @* | comment() | processing-instruction()" priority="-1">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:variable name="localDebug" as="xs:boolean" select="false()"/>
    
    <xsl:if test="$localDebug">
      <xsl:message>+ [DEBUG] dita-community:glossary-sort: Catch-all for non-element node: <xsl:sequence select="."/></xsl:message>
    </xsl:if>
    <xsl:sequence select="."/>
  </xsl:template>
  
  
</xsl:stylesheet>