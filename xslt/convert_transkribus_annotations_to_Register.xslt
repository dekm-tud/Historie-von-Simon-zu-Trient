<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:f="urn:fun"
    exclude-result-prefixes="f xs">

    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
    <xsl:strip-space elements="*"/>

    <xsl:function name="f:norm" as="xs:string">
        <xsl:param name="n" as="item()*"/>
        <xsl:variable name="s" select="normalize-space(string-join($n,''))"/>
        <xsl:variable name="s_no_punct" select="replace($s, '[\.,;:]$', '')"/>
        <xsl:variable name="lc" select="lower-case(normalize-unicode($s_no_punct,'NFKD'))"/>
        <xsl:sequence select="replace($lc, '\p{M}', '')"/>
    </xsl:function>

    <xsl:function name="f:slug" as="xs:string">
        <xsl:param name="s" as="xs:string"/>
        <xsl:variable name="s_clean" select="if (matches($s, '^Q\d+$')) then $s else (if (contains($s, 'wikidata.org')) then substring-after($s, 'wiki/') else $s)"/>
        <xsl:variable name="t0" select="replace($s_clean, '\|', '-')"/>
        <xsl:variable name="t1" select="replace($t0,'[^a-zA-Z0-9]+','-')"/>
        <xsl:variable name="t2" select="replace(replace($t1,'^-+',''),'-+$','')"/>
        <xsl:sequence select="if ($t2 = '') then 'unknown' else lower-case($t2)"/>
    </xsl:function>

    <xsl:function name="f:entity-grouping-key" as="xs:string">
        <xsl:param name="node" as="element()"/>
        <xsl:variable name="wikidata_ref" select="$node/@ref[matches(., 'wikidata.org/wiki/Q\d+$')][1]"/>
        <xsl:variable name="qid" select="if ($wikidata_ref) then replace($wikidata_ref, '.*/(Q\d+)$', '$1') else ''"/>

        <xsl:choose>
            <xsl:when test="$qid ne ''">
                <xsl:sequence select="$qid"/> </xsl:when>
            <xsl:when test="$node/self::rs[@type='work'] and normalize-space($node/@ana) ne ''">
                 <xsl:sequence select="f:norm($node/@ana)"/>
            </xsl:when>
            <xsl:when test="$node/self::persName or $node/self::rs[@type='person']">
                <xsl:variable name="norm_forename" select="f:norm($node/@forename)"/>
                <xsl:variable name="norm_surname" select="f:norm($node/@surname)"/>
                <xsl:choose>
                  <xsl:when test="$norm_forename ne '' and $norm_surname ne ''">
                    <xsl:sequence select="concat($norm_forename, '|', $norm_surname)"/>
                  </xsl:when>
                  <xsl:when test="$norm_forename ne ''">
                     <xsl:sequence select="concat($norm_forename, '|')"/>
                  </xsl:when>
                   <xsl:when test="$norm_surname ne ''">
                     <xsl:sequence select="concat('|', $norm_surname)"/>
                  </xsl:when>
                  <xsl:when test="$node/@ref[not(matches(., 'wikidata.org/wiki/Q\d+$'))][1]">
                     <xsl:sequence select="normalize-space($node/@ref[not(matches(., 'wikidata.org/wiki/Q\d+$'))][1])"/>
                  </xsl:when>
                   <xsl:otherwise>
                    <xsl:sequence select="f:norm($node)"/>
                  </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
             <xsl:otherwise>
                 <xsl:variable name="other_ref_attr" select="$node/@ref[not(matches(., 'wikidata.org/wiki/Q\d+$'))][1]"/>
                 <xsl:choose>
                     <xsl:when test="$other_ref_attr">
                         <xsl:sequence select="normalize-space($other_ref_attr)"/>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:sequence select="f:norm($node)"/>
                     </xsl:otherwise>
                 </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="f:get-id-from-key" as="xs:string?">
        <xsl:param name="key" as="xs:string"/>
        <xsl:param name="type_prefix" as="xs:string"/>
        <xsl:sequence select="concat($type_prefix, '-', f:slug($key))"/>
    </xsl:function>

    <xsl:variable name="all_persons" select="//text/body//(persName | rs[@type='person'])"/>
    <xsl:variable name="all_places" select="//text/body//(placeName | rs[@type='place'] | geogName)"/>
    <xsl:variable name="all_works" select="//text/body//rs[@type='work']"/>

    <xsl:variable name="persons_register" as="element(person)*">
      <xsl:for-each-group select="$all_persons" group-by="f:entity-grouping-key(.)">
        <xsl:variable name="group_key" select="current-grouping-key()"/>
        <xsl:variable name="gid" select="f:get-id-from-key($group_key, 'p')"/>
        <xsl:variable name="g" select="current-group()"/>
        <xsl:variable name="best_node" select="($g[@ref[matches(., '/Q\d+$')]], $g[@forename ne '' and @surname ne ''], $g[@forename ne ''], $g[@surname ne ''], $g)[1]"/>
        <person xml:id="{$gid}">
           <persName>
              <xsl:choose>
                 <xsl:when test="normalize-space($best_node/@forename) ne '' and normalize-space($best_node/@surname) ne ''">
                    <forename><xsl:value-of select="normalize-space($best_node/@forename)"/></forename>
                    <surname><xsl:value-of select="normalize-space($best_node/@surname)"/></surname>
                 </xsl:when>
                 <xsl:when test="normalize-space($best_node/@forename) ne '' and normalize-space($best_node/@surname) eq '' and not(contains(normalize-space($best_node/@forename), ' '))">
                     <forename><xsl:value-of select="normalize-space($best_node/@forename)"/></forename>
                 </xsl:when>
                  <xsl:when test="normalize-space($best_node/@forename) eq '' and normalize-space($best_node/@surname) ne ''">
                     <surname><xsl:value-of select="normalize-space($best_node/@surname)"/></surname>
                 </xsl:when>
                  <xsl:when test="normalize-space($best_node/@forename) ne ''">
                     <xsl:value-of select="normalize-space($best_node/@forename)"/>
                 </xsl:when>
                 <xsl:otherwise>
                    <xsl:value-of select="replace(normalize-space(string(($g)[1])), '[\.,;:]$', '')"/>
                 </xsl:otherwise>
              </xsl:choose>
           </persName>
           <xsl:call-template name="process-other-attributes">
             <xsl:with-param name="nodes" select="$g"/>
             <xsl:with-param name="entry_type" select="'person'"/>
           </xsl:call-template>
        </person>
      </xsl:for-each-group>
    </xsl:variable>

    <xsl:variable name="places_register" as="element(place)*">
       <xsl:for-each-group select="$all_places" group-by="f:entity-grouping-key(.)">
        <xsl:variable name="group_key" select="current-grouping-key()"/>
        <xsl:variable name="gid" select="f:get-id-from-key($group_key, 'pl')"/>
        <xsl:variable name="g" select="current-group()"/>
        <xsl:variable name="group_settlements" select="distinct-values($g/@settlement[. ne ''])"/>
        <xsl:variable name="group_regions" select="distinct-values($g/@region[. ne ''])"/>
        <xsl:variable name="group_countries" select="distinct-values($g/@country[. ne ''])"/>
        <xsl:variable name="attested_name" select="replace(normalize-space(string($g[1])), '[\.,;:]$', '')"/>
        <xsl:variable name="canonical_name">
            <xsl:choose>
                <xsl:when test="$group_settlements[1]"><xsl:value-of select="$group_settlements[1]"/></xsl:when>
                <xsl:when test="$group_regions[1]"><xsl:value-of select="$group_regions[1]"/></xsl:when>
                <xsl:when test="$group_countries[1]"><xsl:value-of select="$group_countries[1]"/></xsl:when>
                <xsl:otherwise><xsl:value-of select="$attested_name"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <place xml:id="{$gid}">
           <placeName><xsl:value-of select="$canonical_name"/></placeName>
           <xsl:if test="normalize-space($attested_name) ne '' and normalize-space($attested_name) ne normalize-space($canonical_name)">
               <placeName type="attested"><xsl:value-of select="$attested_name"/></placeName>
           </xsl:if>
           <xsl:if test="exists($group_settlements) or exists($group_regions) or exists($group_countries)">
                <location>
                   <xsl:if test="not($canonical_name = $group_settlements[1])">
                       <xsl:for-each select="$group_settlements"><settlement><xsl:value-of select="."/></settlement></xsl:for-each>
                   </xsl:if>
                   <xsl:if test="not($canonical_name = $group_regions[1])">
                        <xsl:for-each select="$group_regions"><region><xsl:value-of select="."/></region></xsl:for-each>
                   </xsl:if>
                    <xsl:if test="not($canonical_name = $group_countries[1])">
                        <xsl:for-each select="$group_countries"><country><xsl:value-of select="."/></country></xsl:for-each>
                   </xsl:if>
                </location>
           </xsl:if>
           <xsl:call-template name="process-other-attributes">
             <xsl:with-param name="nodes" select="$g"/>
             <xsl:with-param name="entry_type" select="'place'"/>
           </xsl:call-template>
        </place>
      </xsl:for-each-group>
    </xsl:variable>

    <xsl:variable name="works_register" as="element(bibl)*">
       <xsl:for-each-group select="$all_works" group-by="f:entity-grouping-key(.)">
        <xsl:variable name="group_key" select="current-grouping-key()"/>
        <xsl:variable name="gid" select="f:get-id-from-key($group_key, 'w')"/>
        <xsl:variable name="g" select="current-group()"/>
        <xsl:variable name="group_anas" select="distinct-values($g/@ana[normalize-space(.) ne ''])"/>
        <xsl:variable name="attested_title" select="replace(normalize-space(string($g[1])), '[\.,;:]$', '')"/>
        <xsl:variable name="canonical_title">
             <xsl:choose>
                 <xsl:when test="$group_anas[1]"><xsl:value-of select="$group_anas[1]"/></xsl:when>
                 <xsl:otherwise><xsl:value-of select="$attested_title"/></xsl:otherwise>
             </xsl:choose>
        </xsl:variable>

        <bibl xml:id="{$gid}">
           <title level="u"><xsl:value-of select="$canonical_title"/></title>
           <xsl:if test="normalize-space($attested_title) ne '' and normalize-space($attested_title) ne normalize-space($canonical_title)">
               <title level="u" type="attested"><xsl:value-of select="$attested_title"/></title>
           </xsl:if>
           <xsl:call-template name="process-other-attributes">
             <xsl:with-param name="nodes" select="$g"/>
             <xsl:with-param name="entry_type" select="'work'"/>
           </xsl:call-template>
        </bibl>
      </xsl:for-each-group>
    </xsl:variable>

    <xsl:template name="process-other-attributes">
       <xsl:param name="nodes" as="element()*"/>
       <xsl:param name="entry_type" as="xs:string"/>

       <xsl:variable name="refs" select="distinct-values($nodes/@ref/normalize-space(.))"/>
       <xsl:variable name="anas" select="distinct-values($nodes/@ana[. ne ''])"/>
       <xsl:variable name="wikidatas" select="$refs[contains(., 'wikidata.org')]"/>

       <xsl:for-each select="$refs[not(contains(., 'wikidata.org'))]">
           <idno type="original_ref"><xsl:value-of select="."/></idno>
       </xsl:for-each>
       <xsl:if test="$wikidatas[1]">
            <idno type="wikidata"><xsl:value-of select="replace($wikidatas[1], '.*/(Q\d+)$', '$1')"/></idno>
       </xsl:if>

       <xsl:if test="$entry_type='work'">
            <xsl:variable name="canonical_title_from_ana" select="distinct-values($nodes/@ana[normalize-space(.) ne ''])[1]"/>
            <xsl:if test="not($canonical_title_from_ana)"> <xsl:for-each select="$anas">
                   <note type="annotation" subtype="ana"><xsl:value-of select="."/></note>
               </xsl:for-each>
           </xsl:if>
       </xsl:if>

        </xsl:template>

    <xsl:template match="@*|node()">
       <xsl:copy><xsl:apply-templates select="@*|node()"/></xsl:copy>
    </xsl:template>

    <xsl:template match="teiHeader[not(profileDesc)]">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
            <profileDesc>
                <xsl:call-template name="emit-registers"/>
            </profileDesc>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="profileDesc">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
            <xsl:call-template name="emit-registers"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="TEI[not(teiHeader)]">
         <xsl:copy>
             <xsl:apply-templates select="@*"/>
             <teiHeader>
                 <fileDesc><titleStmt><title>Title (auto-generated)</title></titleStmt><publicationStmt><p>Publication Info (auto-generated)</p></publicationStmt><sourceDesc><p>Source Info (auto-generated)</p></sourceDesc></fileDesc>
                 <profileDesc>
                     <xsl:call-template name="emit-registers"/>
                 </profileDesc>
             </teiHeader>
             <xsl:apply-templates select="node()"/>
         </xsl:copy>
    </xsl:template>

    <xsl:template name="emit-registers">
        <xsl:if test="count($persons_register) > 0">
            <particDesc>
                <listPerson>
                    <xsl:copy-of select="$persons_register"/>
                </listPerson>
            </particDesc>
        </xsl:if>
        <xsl:if test="count($places_register) > 0">
            <settingDesc>
                 <listPlace>
                    <xsl:copy-of select="$places_register"/>
                 </listPlace>
            </settingDesc>
        </xsl:if>
        <xsl:if test="count($works_register) > 0">
             <listBibl type="list_work">
                <xsl:copy-of select="$works_register"/>
             </listBibl>
        </xsl:if>
    </xsl:template>

    <xsl:template match="persName | rs[@type='person'] | placeName | rs[@type='place'] | geogName | rs[@type='work']">
        <xsl:if test="ancestor::text/body">
            <xsl:variable name="group_key" select="f:entity-grouping-key(.)"/>
             <xsl:variable name="type_prefix">
                 <xsl:choose>
                   <xsl:when test="self::persName | self::rs[@type='person']">p</xsl:when>
                   <xsl:when test="self::placeName | self::rs[@type='place'] | self::geogName">pl</xsl:when>
                   <xsl:when test="self::rs[@type='work']">w</xsl:when>
                   <xsl:otherwise>unknown</xsl:otherwise>
               </xsl:choose>
             </xsl:variable>
            <xsl:variable name="reg_id" select="f:get-id-from-key($group_key, $type_prefix)"/>
            <xsl:variable name="original_wikidata_ref" select="@ref[matches(., 'wikidata.org/wiki/Q\d+$')]"/>

            <xsl:copy>
                <xsl:attribute name="ref">
                    <xsl:value-of select="concat('#', $reg_id)"/>
                </xsl:attribute>
                <xsl:if test="$original_wikidata_ref">
                    <xsl:attribute name="target">
                        <xsl:value-of select="$original_wikidata_ref"/>
                    </xsl:attribute>
                </xsl:if>
                 <xsl:apply-templates select="@xml:id"/>
                <xsl:apply-templates select="node()"/>
            </xsl:copy>
        </xsl:if>
        <xsl:if test="not(ancestor::text/body)">
            <xsl:copy><xsl:apply-templates select="@*|node()"/></xsl:copy>
        </xsl:if>
    </xsl:template>

    <xsl:template match="
        text/body//persName/@*[not(self::xml:id)] |
        text/body//rs[@type='person']/@*[not(self::xml:id)] |
        text/body//placeName/@*[not(self::xml:id)] |
        text/body//rs[@type='place']/@*[not(self::xml:id)] |
        text/body//geogName/@*[not(self::xml:id)] |
        text/body//rs[@type='work']/@*[not(self::xml:id)]
     "/>

</xsl:stylesheet>