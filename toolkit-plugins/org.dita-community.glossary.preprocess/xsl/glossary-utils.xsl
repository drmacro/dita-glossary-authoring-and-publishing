<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:df="http://dita2indesign.org/dita/functions"
  xmlns:relpath="http://dita2indesign/functions/relpath"
  xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
  xmlns:gloss="http://org.dita-community/glossary"
  xmlns:dci18n="http://org.dita-community/i18n"
  xmlns:dci18nfunc="http://org.dita-community/i18n/saxon-extensions"  
  exclude-result-prefixes="xs df relpath dita-ot gloss"
  version="2.0">
  <!-- ===========================================================
       Glossary Processing Utilities
       
       Modes and functions common to all glossary processing.
       =========================================================== -->
  
  <!-- For a topicref that has an @href value and that has a format of "dita",
       attempt to resolve it to a topic and return the topic element.
       
       
    -->
  <xsl:template mode="gloss:get-topics-for-topicrefs" 
    match="*[contains(@class, ' map/topicref ')][@href ne ''][empty(@format) or (@format eq 'dita')]" as="element()?">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>    
    <xsl:variable name="localDebug" as="xs:boolean" select="false() or $doDebug"/>
    
    <xsl:variable name="topic" as="element()?"
      select="df:resolveTopicRef(.)"
    />
    <xsl:sequence select="$topic"/>
    
    <xsl:next-match>
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:next-match>
    
  </xsl:template>
  
  <xsl:template mode="gloss:get-topics-for-topicrefs" match="*" priority="-1">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>    
    <xsl:variable name="localDebug" as="xs:boolean" select="false() or $doDebug"/>
    
    <xsl:apply-templates mode="#current">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$localDebug"/>
    </xsl:apply-templates>
  </xsl:template>
  
  
  <!-- Get the grouping key for a topic.
       @param context Topic to get the grouping key for
       @param doDebug Turn debugging on or off
       @return The grouping key, i.e., a letter of the alphabet or
       locale-specific equivalent or "NUMERIC" if no other group
       can be determined.
       NOTE: This is a placeholder for a more complete locale-aware
       grouping mechanism that relies on configuration files to
       map characters to groups. It will work for most latin-based
       languages.
     -->
  <xsl:function name="gloss:getGroupingKey" as="xs:string">
    <xsl:param name="context" as="element()"/>
    <xsl:param name="doDebug" as="xs:boolean"/>
    
    <xsl:variable name="localDebug" as="xs:boolean" select="false()"/>
    
    <xsl:variable name="navtitle" as="xs:string" select="df:getNavtitleForTopicref($context)"/>
   
    <xsl:if test="$localDebug">
      <xsl:message>+ [DEBUG] gloss:getGroupingKey(): navtitle="<xsl:value-of select="$navtitle"/>"</xsl:message>
    </xsl:if>
    <xsl:variable name="firstChar" as="xs:string" select="substring($navtitle, 1, 1)"/>
    <xsl:if test="$localDebug">
      <xsl:message>+ [DEBUG] gloss:getGroupingKey(): firstChar="<xsl:value-of select="$firstChar"/>"</xsl:message>
    </xsl:if>
    <xsl:variable name="result" as="xs:string">
      <xsl:choose>
        <xsl:when test="matches($firstChar, '\w')">
          <xsl:sequence select="lower-case($firstChar)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="'NUMERIC'"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$localDebug">
      <xsl:message>+ [DEBUG] gloss:getGroupingKey(): returning "<xsl:value-of select="$result"/>"</xsl:message>
    </xsl:if>
    <xsl:sequence select="$result"/>
  </xsl:function>
  
  <!-- Get the grouping label for a given grouping key.
       @param groupKey The group key value (e.g., "a", "NUMERIC")
       @param doDebug Turn debugging on or off
       @return The grouping label. 
       NOTE: This is a placeholder for a more complete locale-aware
       grouping mechanism that relies on configuration files to
       define group labels. It will work for most latin-based
       languages.

     -->
  <xsl:function name="gloss:getGroupLabel" as="xs:string">
    <xsl:param name="groupKey" as="xs:string"/>
    <xsl:param name="doDebug" as="xs:boolean"/>
    <xsl:variable name="result" as="xs:string">
      <xsl:choose>
        <xsl:when test="$groupKey eq 'NUMERIC'">
          <xsl:sequence select="'Numeric'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="upper-case($groupKey)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:sequence select="$result"/>
  </xsl:function>
  
  
  <!-- Enhancement of the version in i18n-utils.xsl, which
       does not use the dita-support-lib functions.
    
       Get the primary sort key for the specified topicref. 
    
       The primary sort key is either the first sort-as value,
       if present, or the base sort key for the referenced
       topic.

       @param topicref The topicref whose referenced topic provides the sort key data.
       @param sortEnglish One of 'first', 'last', 'together'. Determines how English
       text is sorted relative to non-English (non-latin alphabet) text.
       @debug Turns debug messages on or off
       @return The primary sort key string.
    -->
  <xsl:function name="gloss:getPrimarySortKeyForTopicref">
    <xsl:param name="topicref" as="element()"/>
    <xsl:param name="sortEnglish" as="xs:string"/>
    <xsl:param name="doDebug" as="xs:boolean"/>
    
    <xsl:variable name="topic" as="element()?"
      select="df:resolveTopicRef($topicref)"
    />
    <xsl:variable name="sort-as" as="xs:string?"
      select="
      if (exists($topic))
      then (dci18n:getSortAsForTopic($topic, false()))
      else ()
      "
    />
    <xsl:variable name="navtitle" as="xs:string"
      select="df:getNavtitleForTopicref($topicref)"
    />
    <xsl:if test="$doDebug">
      <xsl:message>+ [DEBUG] gloss:getPrimarySortKeyForTopicref(): navtitle="<xsl:value-of select="$navtitle"/>"</xsl:message>
    </xsl:if>
    <xsl:variable name="sortKey"
      select="
      if (exists($sort-as) and $sort-as ne '')
      then $sort-as
      else lower-case(normalize-space($navtitle))
      "
    />
    <xsl:if test="$doDebug">
      <xsl:message>+ [DEBUG] gloss:getPrimarySortKeyForTopicref(): returning "<xsl:value-of select="$sortKey"/>"</xsl:message>
    </xsl:if>
    <xsl:sequence select="$sortKey"/>
  </xsl:function>
  
  
</xsl:stylesheet>