<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xml="http://www.w3.org/XML/1998/namespace"
  xmlns:local="urn:local"
  exclude-result-prefixes="#all">

  <xsl:param name="site_title" select="'Historie von Simon zu Trient – Digital Edition'"/>
  <xsl:param name="css_href"    select="'assets/site.css'"/>
  <xsl:param name="js_href"     select="'assets/site.js'"/>
  <!-- Set true() if the output sits at repo root alongside index.html -->
  <xsl:param name="atRoot"      as="xs:boolean" select="false()"/>

  <xsl:output method="html" encoding="UTF-8" omit-xml-declaration="yes"/>

  <!-- Sort Helpers -->
  <xsl:function name="local:sort-person" as="xs:string">
    <xsl:param name="b" as="element()"/>
    <xsl:variable name="p"
      select="($b/tei:analytic/(tei:author|tei:editor) |
               $b/tei:monogr/(tei:author|tei:editor))[1]"/>
    <xsl:sequence select="normalize-space(string( ($p/tei:surname, $p/tei:name)[1] ))"/>
  </xsl:function>

  <xsl:function name="local:sort-year" as="xs:string">
    <xsl:param name="b" as="element()"/>
    <xsl:variable name="d"
      select="($b/tei:monogr/tei:imprint/tei:date,
               $b/tei:monogr/tei:date,
               $b/tei:analytic/tei:date)[1]"/>
    <xsl:sequence select="substring(normalize-space(string($d)),1,4)"/>
  </xsl:function>

  <xsl:template match="/">
    <xsl:variable name="bibl"
      select="(/*[self::tei:listBibl], /*[local-name()='listBibl'])[1]"/>

    <html lang="de">
      <head>
        <meta charset="utf-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <title><xsl:value-of select="concat($site_title, ' — Literatur')"/></title>
        <link rel="stylesheet" href="{$css_href}"/>
      </head>
      <body class="mode-expan layout-reading">
        <header class="site-header">
          <nav class="nav">
            <div class="brand"><xsl:value-of select="$site_title"/></div>
            <div class="menu">
              <xsl:choose>
                <xsl:when test="$atRoot">
                  <a href="index.html">Home</a>
                  <a href="html/introduction.html">Einleitung</a>
                  <a href="html/edition.html">Edition</a>
                  <a href="html/literature.html" aria-current="page">Literatur</a>
                </xsl:when>
                <xsl:otherwise>
                  <a href="../index.html">Home</a>
                  <a href="introduction.html">Einleitung</a>
                  <a href="edition.html">Edition</a>
                  <a href="literature.html" aria-current="page">Literatur</a>
                </xsl:otherwise>
              </xsl:choose>
            </div>
          </nav>
        </header>

        <main class="container">
          <section id="literature">
            <div class="section-head">
              <h1>Literatur</h1>
              <div class="toolbar">
                <label class="visually-hidden" for="bibl-search">Suche in der Bibliographie</label>
                <input id="bibl-search" type="search" placeholder="Suchen (Autor, Titel, Jahr, …)" />
              </div>
            </div>

            <xsl:choose>
              <xsl:when test="$bibl">
                <div id="biblio">
                  <xsl:apply-templates select="$bibl" mode="biblio"/>
                </div>
              </xsl:when>
              <xsl:otherwise>
                <p class="muted">Keine Bibliographie gefunden.</p>
              </xsl:otherwise>
            </xsl:choose>
          </section>

          <script><![CDATA[
            (function(){
              var q = document.getElementById('bibl-search');
              var root = document.getElementById('biblio');
              if (!q || !root) return;
              q.addEventListener('input', function(){
                var needle = this.value.trim().toLowerCase();
                root.querySelectorAll('.bibl-entry').forEach(function(li){
                  var txt = li.textContent.toLowerCase();
                  li.style.display = needle && !txt.includes(needle) ? 'none' : '';
                });
              });
            })();
          ]]></script>
        </main>

        <footer>
                    <h3>Angaben gemäß § 5 TMG</h3>
                    <p>
                        Herausgeber:
                        Dr. phil. Marco Heiles
                        Ulrich Haberland Straße 43
                        53121 Bonn
                        Deutschland
                        marco.heiles @ uni-hamburg.de
                    </p>
                    <h3>Lizenzbestimmungen</h3>
                    <p>Die Texte dieser Website stehen unter Creative Commons Attribution 4.0 International Lizenz. Sie dürfen die Texte unter Angabe des Urhebers und der CC-Lizenz sowohl kopieren als auch an anderer Stelle veröffentlichen.</p>
                    <h3>Förderung</h3>
                    <p>Die Forschung von Dr. Marco Heiles zur Edition der Historie von Simon zu Trient fand im Institut für Germanistische und Allgemeine Literaturwissenschaft der RWTH Aachen University und am Centre for the Study of Manuscript Cultures (CSMC) der Universität Hamburg statt. Sie wurde durch die Deutsche Forschungsgemeinschaft (DFG) im Rahmen der Exzellenzstrategie des Bundes und der Länder – EXC 2176 „Understanding Written Artefacts: Material, Interaction and Transmission in Manuscript Cultures”, Projektnr. 390893796 gefördert.</p>
                    <p>Die Einrichtung und Veröffentlichung der Digitalen Edition und der Sicherung der Forschungsdaten erfolgte durch <a href="https://orcid.org/0000-0002-2750-1900">Prof. Dr. Michael Schonhardt</a> im Fachgebiet <a href="https://www.linglit.tu-darmstadt.de/institutlinglit/fachgebiete/digitale_editorik_und_kulturgeschichte_des_mittelalters/index.de.jsp">Digitale Editorik und Kulturgeschichte des Mittelalters</a> der Technischen Universität Darmstadt.</p>
                </footer>
        <script src="{$js_href}"></script>
      </body>
    </html>
  </xsl:template>


  <xsl:template match="tei:listBibl | listBibl" mode="biblio">
    <xsl:for-each-group select="tei:biblStruct | *[local-name()='biblStruct']"
                        group-by="upper-case(substring(local:sort-person(.),1,1))">
      <xsl:sort select="current-grouping-key()"/>
      <section class="bibl-group" aria-labelledby="bibl-h-{current-grouping-key()}">
        <h2 id="bibl-h-{current-grouping-key()}">
          <xsl:value-of select="current-grouping-key()"/>
        </h2>
        <ul class="bibl">
          <xsl:for-each select="current-group()">
            <xsl:sort select="local:sort-person(.)"/>
            <xsl:sort select="local:sort-year(.)"/>
            <xsl:sort select="normalize-space((tei:analytic/tei:title[@level='a']|
                                               tei:monogr/tei:title[@level='m']|
                                               *[local-name()='analytic']/*[@level='a']|
                                               *[local-name()='monogr']/*[@level='m'])[1])"/>
            <li class="bibl-entry" id="{@xml:id}">
              <xsl:apply-templates select="." mode="bibl-line"/>
            </li>
          </xsl:for-each>
        </ul>
      </section>
    </xsl:for-each-group>
  </xsl:template>

  <xsl:template match="tei:biblStruct | *[local-name()='biblStruct']" mode="bibl-line">
    <xsl:variable name="t" select="@type"/>
    <xsl:choose>
      <xsl:when test="$t='book'"><xsl:call-template name="b-book"/></xsl:when>
      <xsl:when test="$t='bookSection'"><xsl:call-template name="b-bookSection"/></xsl:when>
      <xsl:when test="$t='journalArticle'"><xsl:call-template name="b-journal"/></xsl:when>
      <xsl:when test="$t='thesis'"><xsl:call-template name="b-thesis"/></xsl:when>
      <xsl:when test="$t='encyclopediaArticle'"><xsl:call-template name="b-encyclo"/></xsl:when>
      <xsl:when test="$t='webpage' or $t='blogPost'"><xsl:call-template name="b-web"/></xsl:when>
      <xsl:otherwise><xsl:call-template name="b-generic"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="b-book">
    <span class="people"><xsl:call-template name="people">
      <xsl:with-param name="nodes" select="tei:monogr/(tei:author|tei:editor)"/>
    </xsl:call-template></span>
    <xsl:text>: </xsl:text>
    <span class="title-m"><xsl:value-of select="tei:monogr/tei:title[@level='m'][1]"/></span>
    <xsl:call-template name="series"/>
    <xsl:call-template name="imprint"/>
    <xsl:call-template name="ids"/>
    <xsl:call-template name="links"/>
  </xsl:template>

  <xsl:template name="b-bookSection">
    <span class="people"><xsl:call-template name="people">
      <xsl:with-param name="nodes" select="tei:analytic/(tei:author|tei:editor)"/>
    </xsl:call-template></span>
    <xsl:text>: </xsl:text>
    <span class="title-a">„<xsl:value-of select="tei:analytic/tei:title[@level='a'][1]"/>“</span>
    <xsl:text>. In: </xsl:text>
    <xsl:variable name="eds" select="tei:monogr/tei:editor"/>
    <xsl:if test="$eds">
      <xsl:call-template name="people">
        <xsl:with-param name="nodes" select="$eds"/>
        <xsl:with-param name="role" select="'(Hg.)'"/>
      </xsl:call-template>
      <xsl:text>, </xsl:text>
    </xsl:if>
    <span class="title-m"><xsl:value-of select="tei:monogr/tei:title[@level='m'][1]"/></span>
    <xsl:call-template name="series"/>
    <xsl:call-template name="imprint"/>
    <xsl:call-template name="ids"/>
    <xsl:call-template name="links"/>
  </xsl:template>

  <xsl:template name="b-journal">
    <span class="people"><xsl:call-template name="people">
      <xsl:with-param name="nodes" select="tei:analytic/tei:author"/>
    </xsl:call-template></span>
    <xsl:text>: </xsl:text>
    <span class="title-a">„<xsl:value-of select="tei:analytic/tei:title[@level='a'][1]"/>“</span>
    <xsl:text>. </xsl:text>
    <span class="title-m"><xsl:value-of select="tei:monogr/tei:title[@level='j'][1]"/></span>
    <span class="imprint">
      <xsl:text> </xsl:text>
      <xsl:value-of select="tei:monogr/tei:imprint/tei:biblScope[@unit='volume'][1]"/>
      <xsl:if test="tei:monogr/tei:imprint/tei:biblScope[@unit='issue']">
        <xsl:text>(</xsl:text><xsl:value-of select="tei:monogr/tei:imprint/tei:biblScope[@unit='issue'][1]"/><xsl:text>)</xsl:text>
      </xsl:if>
      <xsl:if test="tei:monogr/tei:imprint/tei:date">
        <xsl:text> </xsl:text><xsl:value-of select="tei:monogr/tei:imprint/tei:date[1]"/>
      </xsl:if>
      <xsl:if test="tei:monogr/tei:imprint/tei:biblScope[@unit='page']">
        <xsl:text>, </xsl:text><xsl:value-of select="tei:monogr/tei:imprint/tei:biblScope[@unit='page'][1]"/>
      </xsl:if>
    </span>
    <xsl:call-template name="ids"/>
    <xsl:call-template name="links"/>
  </xsl:template>

  <xsl:template name="b-thesis">
    <span class="people"><xsl:call-template name="people">
      <xsl:with-param name="nodes" select="tei:monogr/tei:author"/>
    </xsl:call-template></span>
    <xsl:text>: </xsl:text>
    <span class="title-m"><xsl:value-of select="tei:monogr/tei:title[@level='m'][1]"/></span>
    <xsl:text>. </xsl:text>
    <span class="imprint">
      <xsl:variable name="tt" select="tei:monogr/tei:imprint/tei:note[@type='thesisType'][1]"/>
      <xsl:if test="$tt"><xsl:value-of select="$tt"/><xsl:text>. </xsl:text></xsl:if>
      <xsl:value-of select="tei:monogr/tei:imprint/tei:date[1]"/>
    </span>
    <xsl:call-template name="links"/>
  </xsl:template>

  <xsl:template name="b-encyclo">
    <span class="people"><xsl:call-template name="people">
      <xsl:with-param name="nodes" select="tei:analytic/tei:author"/>
    </xsl:call-template></span>
    <xsl:text>: </xsl:text>
    <span class="title-a">„<xsl:value-of select="tei:analytic/tei:title[@level='a'][1]"/>“</span>
    <xsl:text>. </xsl:text>
    <span class="title-m"><xsl:value-of select="tei:monogr/tei:title[@level='m'][1]"/></span>
    <xsl:call-template name="imprint"/>
    <xsl:call-template name="links"/>
  </xsl:template>

  <xsl:template name="b-web">
    <span class="people"><xsl:call-template name="people">
      <xsl:with-param name="nodes" select="tei:analytic/tei:author"/>
    </xsl:call-template></span>
    <xsl:text>: </xsl:text>
    <span class="title-a">„<xsl:value-of select="tei:analytic/tei:title[@level='a'][1]"/>“</span>
    <xsl:text>. </xsl:text>
    <span class="title-m"><xsl:value-of select="tei:monogr/tei:title[@level='m'][1]"/></span>
    <xsl:call-template name="imprint"/>
    <xsl:call-template name="links"/>
  </xsl:template>

  <xsl:template name="b-generic">
    <xsl:choose>
      <xsl:when test="tei:analytic/tei:title"><xsl:call-template name="b-bookSection"/></xsl:when>
      <xsl:otherwise><xsl:call-template name="b-book"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="people">
    <xsl:param name="nodes" as="element()*"/>
    <xsl:param name="role"  as="xs:string" select="''"/>
    <xsl:for-each select="$nodes">
      <xsl:if test="position() &gt; 1">
        <xsl:choose>
          <xsl:when test="position() = last()"><xsl:text> &amp; </xsl:text></xsl:when>
          <xsl:otherwise><xsl:text>, </xsl:text></xsl:otherwise>
        </xsl:choose>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="tei:surname">
          <xsl:value-of select="normalize-space(tei:surname)"/>
          <xsl:if test="tei:forename"><xsl:text>, </xsl:text><xsl:value-of select="normalize-space(tei:forename)"/></xsl:if>
        </xsl:when>
        <xsl:when test="tei:name"><xsl:value-of select="normalize-space(tei:name)"/></xsl:when>
      </xsl:choose>
    </xsl:for-each>
    <xsl:if test="$role and count($nodes) &gt; 0"><xsl:text> </xsl:text><xsl:value-of select="$role"/></xsl:if>
  </xsl:template>

  <xsl:template name="series">
    <xsl:variable name="s" select="tei:series"/>
    <xsl:if test="$s">
      <xsl:text>. </xsl:text>
      <span class="series">
        <xsl:value-of select="$s/tei:title[@level='s'][1]"/>
        <xsl:if test="$s/tei:biblScope[@unit='volume']">
          <xsl:text> </xsl:text><xsl:value-of select="$s/tei:biblScope[@unit='volume'][1]"/>
        </xsl:if>
      </span>
    </xsl:if>
  </xsl:template>

  <xsl:template name="imprint">
    <xsl:variable name="imp" select="tei:monogr/tei:imprint"/>
    <xsl:if test="$imp">
      <xsl:text>. </xsl:text>
      <span class="imprint">
        <xsl:if test="$imp/tei:pubPlace">
          <xsl:value-of select="normalize-space($imp/tei:pubPlace[1])"/>
          <xsl:if test="$imp/tei:publisher or $imp/tei:date"><xsl:text>: </xsl:text></xsl:if>
        </xsl:if>
        <xsl:if test="$imp/tei:publisher">
          <xsl:value-of select="$imp/tei:publisher[1]"/>
          <xsl:if test="$imp/tei:date"><xsl:text>, </xsl:text></xsl:if>
        </xsl:if>
        <xsl:if test="$imp/tei:date"><xsl:value-of select="$imp/tei:date[1]"/></xsl:if>
        <xsl:if test="$imp/tei:biblScope[@unit='page']">
          <xsl:text>, </xsl:text><xsl:value-of select="$imp/tei:biblScope[@unit='page'][1]"/>
        </xsl:if>
      </span>
    </xsl:if>
  </xsl:template>

  <xsl:template name="ids">
    <xsl:variable name="isbn" select="tei:monogr/tei:idno[@type='ISBN']"/>
    <xsl:variable name="issn" select="tei:monogr/tei:idno[@type='ISSN']"/>
    <xsl:if test="$isbn or $issn">
      <xsl:text>. </xsl:text>
      <span class="ids">
        <xsl:if test="$isbn">ISBN: <xsl:value-of select="$isbn[1]"/></xsl:if>
        <xsl:if test="$issn">
          <xsl:if test="$isbn"><xsl:text>; </xsl:text></xsl:if>
          ISSN: <xsl:value-of select="$issn[1]"/>
        </xsl:if>
      </span>
    </xsl:if>
  </xsl:template>

  <xsl:template name="links">
    <xsl:variable name="urlFromCorresp" select="@corresp"/>
    <xsl:variable name="urlFromNote"
      select="(tei:monogr/tei:imprint/tei:note[@type='url']|
               tei:monogr/tei:note[@type='url'])[1]"/>
    <xsl:variable name="url" select="if (string($urlFromCorresp)!='') then $urlFromCorresp else string($urlFromNote)"/>
    <xsl:variable name="accessed"
      select="(tei:monogr/tei:imprint/tei:note[@type='accessed']|
               tei:monogr/tei:note[@type='accessed'])[1]"/>
    <xsl:if test="normalize-space($url)!=''">
      <xsl:text>. </xsl:text>
      <a class="link" href="{$url}">Zotero</a>
      <xsl:if test="$accessed">
        <xsl:text> (zuletzt besucht: </xsl:text><xsl:value-of select="$accessed"/><xsl:text>)</xsl:text>
      </xsl:if>
    </xsl:if>
    <xsl:text>.</xsl:text>
  </xsl:template>

</xsl:stylesheet>
