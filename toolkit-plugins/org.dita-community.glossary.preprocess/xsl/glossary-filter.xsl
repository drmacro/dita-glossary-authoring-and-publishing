<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:dita-community="http://org.dita-community"
  xmlns:gloss="http://org.dita-community/glossary"
  xmlns:dci18n="http://org.dita-community/i18n"
  xmlns:dci18nfunc="http://org.dita-community/i18n/saxon-extensions"
  xmlns:df="http://dita2indesign.org/dita/functions"
  
  exclude-result-prefixes="xs dita-community gloss dci18n dci18nfunc df"
  expand-text="yes"
  version="3.0">
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
    Filters the input map based on the links.
    
    @return The filtered map and the link report. The link report, if generated,
    is the second document in the retured sequence.
    -->
  <xsl:template mode="dita-community:glossary-filter" match="/" as="document-node()+">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:variable name="localDebug" as="xs:boolean" select="true() or $doDebug"/>
    
    <xsl:variable name="normalRoleTopicrefs" as="element()*"
      select="/*//*[df:isNormalRoleTopicRef(.)]"
    />
    
    <xsl:message>+ [INFO] Gathering normal-role topics in order to evaluate links to glossary entries...</xsl:message>

    <xsl:if test="$localDebug">
      <xsl:message>+ [DEBUG] dita-community:glossary-filter: Have <xsl:value-of select="count($normalRoleTopicrefs)"/> normal-role topicrefs.</xsl:message>
    </xsl:if>
    
    <xsl:variable name="normalRoleTopics" as="element()*">
      <xsl:apply-templates select="$normalRoleTopicrefs" mode="gloss:get-topics-for-topicrefs">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
        <xsl:with-param name="processDescendantTopicrefs" as="xs:boolean" tunnel="yes" select="false()"/>
        <xsl:with-param name="excludeClass" as="xs:string?" tunnel="yes" select="' glossentry/glossentry '"/>
      </xsl:apply-templates>
    </xsl:variable>

    <xsl:variable name="glossaryTopics" as="element()*">
      <xsl:apply-templates select="$normalRoleTopicrefs" mode="gloss:get-topics-for-topicrefs">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
        <xsl:with-param name="processDescendantTopicrefs" as="xs:boolean" tunnel="yes" select="false()"/>
        <xsl:with-param name="includeClass" as="xs:string?" tunnel="yes" select="' glossentry/glossentry '"/>
      </xsl:apply-templates>
    </xsl:variable>
    
    <xsl:if test="$localDebug">
      <xsl:message>
+ [DEBUG] dita-community:glossary-filter: Have <xsl:value-of select="count($normalRoleTopics)"/> normal-role topics that are not glossary entries.
      </xsl:message>
<!--      <xsl:for-each select="$normalRoleTopics">
        <xsl:message>+ [DEBUG] [<xsl:value-of select="position()"/>] <xsl:value-of select="df:getNavtitleForTopic(.)"/> (<xsl:value-of select="base-uri(.)"/>)</xsl:message>
      </xsl:for-each>
-->      <xsl:message>+ [DEBUG] dita-community:glossary-filter: Have <xsl:value-of select="count($glossaryTopics)"/> normal-role glossary topics.</xsl:message>
<!--      <xsl:for-each select="$glossaryTopics">
        <xsl:message>+ [DEBUG] [<xsl:value-of select="position()"/>] <xsl:value-of select="df:getNavtitleForTopic(.)"/> (<xsl:value-of select="base-uri(.)"/>)</xsl:message>
      </xsl:for-each>
-->    </xsl:if>
    
    <xsl:variable name="links" as="element()*">
      <xsl:apply-templates mode="gloss:get-links-from-topics" select="$normalRoleTopics">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>        
      </xsl:apply-templates>
    </xsl:variable>       
    
    <xsl:if test="$localDebug or true()">
      <xsl:message>
+ [DEBUG] dita-community:glossary-filter: Have {count($links)} links:</xsl:message>
      <xsl:for-each select="$links">
        <xsl:message>+ [DEBUG]   [{position()}] {name(.)} {if (exists(@keyref)) 
          then ' keyref=&quot;' || @keyref || '&quot;'
          else ()} href="{@href}" {
          if (not(matches(., '^\s*$'))) 
          then '&quot;' || normalize-space(.) || '&quot;'  
          else ''}</xsl:message>
      </xsl:for-each>        

    
    </xsl:if>
    
    <xsl:variable name="directlyUsedGlossaryEntries" as="element()*">
      <xsl:apply-templates select="$links" mode="gloss:get-glossary-entries-for-links">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
        <xsl:with-param name="rootmap" as="element()" tunnel="yes" select="/*"/>        
      </xsl:apply-templates>
    </xsl:variable>    

    <xsl:message>+ [INFO] dita-community:glossary-filter: Have {count($directlyUsedGlossaryEntries)} directly-used glossary entries</xsl:message>
    
    <xsl:variable name="indirectlyUsedGlossaryEntries" as="element()*">
      <xsl:call-template name="gloss:getIndirectlyUsedGlossaryEntries">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
        <xsl:with-param name="directlyUsedGlossaryEntries" as="element()*" select="$directlyUsedGlossaryEntries"/>
        <xsl:with-param name="rootmap" as="element()" tunnel="yes" select="/*"/>        
      </xsl:call-template>
    </xsl:variable>
    
    <xsl:message>+ [DEBUG] dita-community:glossary-filter: Have {count($indirectlyUsedGlossaryEntries)} indirectly-used glossary entries</xsl:message>

    <xsl:variable name="usedGlossaryEntries" as="element()*"
      select="($directlyUsedGlossaryEntries | $indirectlyUsedGlossaryEntries)"
    />
    
    <xsl:message>+ [DEBUG] dita-community:glossary-filter: Have {count($usedGlossaryEntries)} used glossary entries</xsl:message>
    
    <xsl:variable name="rootElem" as="element()" select="/*"/>
    <xsl:document>
      <xsl:sequence select="node()[. &lt;&lt; $rootElem]"/>
      <xsl:comment>[DEBUG] applying templates to map in mode dita-community:glossary-filter</xsl:comment>
      <xsl:apply-templates mode="#current">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug or $localDebug"/>
        <xsl:with-param name="usedGlossaryEntries" as="element()*" tunnel="yes" 
          select="$usedGlossaryEntries"
        />
      </xsl:apply-templates>
      <xsl:comment>[DEBUG] After applying templates in mode dita-community:glossary-filter</xsl:comment>
      <xsl:sequence select="node()[. &gt;&gt; $rootElem]"/>
    </xsl:document>
    
    <!-- Make the link report -->
    <!-- WEK: Link report turns out to not be that useful and I don't want to support it at this time. -->
<!--    <xsl:if test="$localDebug">
      <xsl:message>+ [DEBUG] dita-community:glossary-filter: Calling make-link-report...</xsl:message>
    </xsl:if>
    <xsl:call-template name="dita-community:make-link-report">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
      <xsl:with-param name="links" as="element()*" select="$links"/>
    </xsl:call-template>
    <xsl:if test="$localDebug">
      <xsl:message>+ [DEBUG] dita-community:glossary-filter: After make-link-report.</xsl:message>
    </xsl:if>
-->    
    
  </xsl:template>
  
  <!-- If the topicref is to a used glossary entry, keep it, otherwise ignore it. -->
  <xsl:template mode="dita-community:glossary-filter" match="*[gloss:isTopicrefToGlossaryEntry(.)]">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:param name="usedGlossaryEntries" as="element()*" tunnel="yes"/>
    
    <xsl:variable name="localDebug" as="xs:boolean" select="false() or $doDebug"/>
    
    <xsl:variable name="target" as="element()*"
      select="df:resolveTopicRef(., $doDebug)"
    />
    
    <xsl:choose>
      <xsl:when test="exists($target intersect $usedGlossaryEntries)">
        <xsl:next-match>
          <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
        </xsl:next-match>
      </xsl:when>
      <xsl:otherwise>
        <!-- Not a reference to a used glossary entry, filter it out -->
        <xsl:apply-templates select="*[contains(@class, ' map/topicref ')]" mode="#current">
          <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>                  
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:template>
  
  <xsl:template mode="dita-community:glossary-filter" match="*" priority="-1">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
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
  
  <!-- Context element should be some form of link -->
  <xsl:template mode="gloss:get-glossary-entries-for-links" match="*" as="element()?">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:param name="rootmap" as="element()" tunnel="yes"/>
    <xsl:variable name="localDebug" as="xs:boolean" select="false()"/>
    
    <xsl:variable name="targetURI" as="xs:string?"
      select="
      if (exists(@keyref))
      then df:getEffectiveUriForKeyref(., $rootmap, $doDebug)
      else string(@href)
      "
    />    
    
    <xsl:variable name="target" as="element()?"
      select="df:resolveTopicElementRef(., $targetURI)"
    />

    <xsl:choose>
      <xsl:when test="exists($target)">
        <xsl:choose>
          <xsl:when test="contains(@class, ' glossentry/glossentry ')">
            <xsl:sequence select="$target"/>
          </xsl:when>
          <xsl:otherwise>
            <!-- Not a glossary entry, ignore it -->
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <!-- No target, nothing to do -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Give a set of glossary entries, find all the links in those glossary
       entries and then return the glossary entries linked by those links,
       if any.
       
       Repeat until no more links are found.
    -->
  <xsl:template name="gloss:getIndirectlyUsedGlossaryEntries" as="element()*">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:param name="directlyUsedGlossaryEntries" as="element()*"/>
    
    <xsl:call-template name="gloss:_getIndirectlyUsedGlossaryEntries">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
      <xsl:with-param name="directlyUsedGlossaryEntries" as="element()*" select="$directlyUsedGlossaryEntries"/>
    </xsl:call-template>
  </xsl:template>
  
  <!-- Recursive template to get references to glossary entries from the directly-used glossary entries -->
  <xsl:template name="gloss:_getIndirectlyUsedGlossaryEntries" as="element()*">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:param name="directlyUsedGlossaryEntries" as="element()*"/>
    
    <!-- Get the links from the directly-used glossary entires, get the glossary
         entries from those, and recurse.
      -->
    
    <xsl:variable name="links" as="element()*">
      <xsl:apply-templates mode="gloss:get-links-from-topics" select="$directlyUsedGlossaryEntries">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:variable name="newIndirectGlossaryEntries" as="element()*">
      <xsl:apply-templates select="$links" mode="gloss:get-glossary-entries-for-links">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:variable name="newTopics" as="element()*"
      select="
        $newIndirectGlossaryEntries except ($directlyUsedGlossaryEntries)
      "
    />
    <xsl:choose>
      <xsl:when test="empty($newTopics)">
        <xsl:sequence select="$directlyUsedGlossaryEntries"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="gloss:_getIndirectlyUsedGlossaryEntries">
          <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
          <xsl:with-param name="directlyUsedGlossaryEntries" as="element()*" select="$directlyUsedGlossaryEntries, $newTopics"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:template>
  
</xsl:stylesheet>