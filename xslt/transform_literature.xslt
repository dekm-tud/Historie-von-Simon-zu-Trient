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
    <xsl:sequence select="normalize-space(string( ($p/tei:surname, $p/tei:name, $p/tei:forename, $p)[1] ))"/>
  </xsl:function>

  <xsl:function name="local:sort-title" as="xs:string">
    <xsl:param name="b" as="element()"/>
    <xsl:sequence select="normalize-space(string((
      $b/tei:analytic/tei:title[@level='a'],
      $b/tei:monogr/tei:title[@level=('m','j')],
      $b/tei:analytic/tei:title,
      $b/tei:monogr/tei:title
    )[1]))"/>
  </xsl:function>

  <xsl:function name="local:sort-key" as="xs:string">
    <xsl:param name="b" as="element()"/>
    <xsl:variable name="person" select="local:sort-person($b)"/>
    <xsl:sequence select="if ($person != '') then $person else local:sort-title($b)"/>
  </xsl:function>

  <xsl:function name="local:group-key" as="xs:string">
    <xsl:param name="b" as="element()"/>
    <xsl:variable name="lead" select="replace(local:sort-key($b), '^[^\p{L}\p{N}]+', '')"/>
    <xsl:variable name="k" select="upper-case(substring($lead, 1, 1))"/>
    <xsl:sequence select="if ($k != '') then $k else '#'"/>
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
      select="(//*[self::tei:listBibl], //*[local-name()='listBibl'])[1]"/>

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
                  <a href="https://github.com/dekm-tud/Historie-von-Simon-zu-Trient/">GitHub</a>

                </xsl:when>
                <xsl:otherwise>
                  <a href="../index.html">Home</a>
                  <a href="introduction.html">Einleitung</a>
                  <a href="edition.html">Edition</a>
                  <a href="literature.html" aria-current="page">Literatur</a>
                  <a href="https://github.com/dekm-tud/Historie-von-Simon-zu-Trient/">GitHub</a>

                </xsl:otherwise>
              </xsl:choose>
            </div>
          </nav>
        </header>

        <main class="container">
          <section id="literature">
            <div class="section-head">
              <h1>Historie von Simon zu Trient: Forschungsbibliographie</h1>
              <h2>von Marco Heiles unter Mitarbeit von Sophie-Elisabeth Grimm</h2>
              <p>Diese Bibliographie sammelt Forschungsliteratur zur 'Historie von Simon zu Trient' und ihrem historischen Kontext, dem Trienter Ritualmordprozess von 1475-1478. Alle bibliographischen Daten sind auch in <a href="https://www.zotero.org/groups/5071036/historie_von_simon_zu_trient._forschungsbibliographie">Zotero</a> erfasst.</p>
              <div class="toolbar">
                <h2>Suche</h2>
                <label class="visually-hidden" for="bibl-search">Suche in der Bibliographie</label>
                <input id="bibl-search" type="search" placeholder="Autor, Titel, Jahr, …" />
                <p id="bibl-search-status" class="muted" aria-live="polite"/>
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
              var status = document.getElementById('bibl-search-status');
              if (!q || !root) return;

              var entries = Array.prototype.slice.call(root.querySelectorAll('.bibl-entry'));
              var groups = Array.prototype.slice.call(root.querySelectorAll('.bibl-group'));

              function setStatus(visible, total, needle) {
                if (!status) return;
                if (!needle) {
                  status.textContent = 'Einträge: ' + total;
                  return;
                }
                status.textContent = 'Treffer: ' + visible + ' / ' + total;
              }

              function applyFilter() {
                var needle = q.value.trim().toLowerCase();

                entries.forEach(function(li){
                  var txt = li.textContent.toLowerCase();
                  li.style.display = needle && !txt.includes(needle) ? 'none' : '';
                });

                groups.forEach(function(section){
                  var hasVisible = Array.prototype.some.call(
                    section.querySelectorAll('.bibl-entry'),
                    function(li){ return li.style.display !== 'none'; }
                  );
                  section.style.display = hasVisible ? '' : 'none';
                });

                var visibleCount = entries.filter(function(li){ return li.style.display !== 'none'; }).length;
                setStatus(visibleCount, entries.length, needle);
              }

              q.addEventListener('input', applyFilter);
              applyFilter.call(q);
            })();
          ]]></script>
        </main>

        <footer>
                    <h2>Impressum</h2>
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
                    <p>Die Forschung von <a href="https://hcommons.org/members/marcoheiles/">Dr. Marco Heiles</a> zur Edition der Historie von Simon zu Trient fand im <a href="https://www.germlit.rwth-aachen.de/cms/germlit/Das-Institut/~mpma/Aeltere-deutsche-Literatur/">Institut für Germanistische und Allgemeine Literaturwissenschaft der RWTH Aachen University</a> und am <a href="https://www.csmc.uni-hamburg.de">Centre for the Study of Manuscript Cultures (CSMC) der Universität Hamburg</a> statt. Sie wurde durch die Deutsche Forschungsgemeinschaft (DFG) im Rahmen der Exzellenzstrategie des Bundes und der Länder – EXC 2176 „Understanding Written Artefacts: Material, Interaction and Transmission in Manuscript Cultures”, Projektnr. 390893796 gefördert.</p>
                    <p>Die Einrichtung und Veröffentlichung der Digitalen Edition und der Sicherung der Forschungsdaten erfolgte durch <a href="https://orcid.org/0000-0002-2750-1900">Prof. Dr. Michael Schonhardt</a> im Fachgebiet <a href="https://www.linglit.tu-darmstadt.de/institutlinglit/fachgebiete/digitale_editorik_und_kulturgeschichte_des_mittelalters/index.de.jsp">Digitale Editorik und Kulturgeschichte des Mittelalters</a> der Technischen Universität Darmstadt.</p>                </footer>
        <script src="{$js_href}"></script>
      </body>
    </html>
  </xsl:template>


  <xsl:template match="tei:listBibl | listBibl" mode="biblio">
    <xsl:for-each-group select="tei:biblStruct | *[local-name()='biblStruct']"
                        group-by="local:group-key(.)">
      <xsl:sort select="current-grouping-key()"/>
      <section class="bibl-group" aria-labelledby="bibl-h-{current-grouping-key()}">
        <h2 id="bibl-h-{current-grouping-key()}">
          <xsl:value-of select="current-grouping-key()"/>
        </h2>
        <ul class="bibl">
          <xsl:for-each select="current-group()">
            <xsl:sort select="local:sort-key(.)"/>
            <xsl:sort select="local:sort-year(.)"/>
            <xsl:sort select="local:sort-title(.)"/>
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
    <xsl:call-template name="emit-people-prefix">
      <xsl:with-param name="nodes" select="tei:monogr/(tei:author|tei:editor)"/>
    </xsl:call-template>
    <xsl:variable name="titleM" select="normalize-space(string((tei:monogr/tei:title[@level=('m','j')], tei:monogr/tei:title)[1]))"/>
    <xsl:if test="$titleM != ''">
      <span class="title-m"><xsl:value-of select="$titleM"/></span>
    </xsl:if>
    <xsl:call-template name="series"/>
    <xsl:call-template name="imprint"/>
    <xsl:call-template name="ids"/>
    <xsl:call-template name="links"/>
  </xsl:template>

  <xsl:template name="b-bookSection">
    <xsl:call-template name="emit-people-prefix">
      <xsl:with-param name="nodes" select="
        if (exists(tei:analytic/(tei:author|tei:editor)))
        then tei:analytic/(tei:author|tei:editor)
        else tei:monogr/(tei:author|tei:editor)
      "/>
    </xsl:call-template>
    <xsl:variable name="titleA" select="normalize-space(string((tei:analytic/tei:title[@level='a'], tei:analytic/tei:title)[1]))"/>
    <xsl:if test="$titleA != ''">
      <span class="title-a">„<xsl:value-of select="$titleA"/>“</span>
      <xsl:text>. </xsl:text>
    </xsl:if>
    <xsl:variable name="eds" select="tei:monogr/tei:editor"/>
    <xsl:variable name="titleM" select="normalize-space(string((tei:monogr/tei:title[@level=('m','j')], tei:monogr/tei:title)[1]))"/>
    <xsl:if test="$eds or $titleM != ''">
      <xsl:text>In: </xsl:text>
      <xsl:if test="$eds">
        <xsl:call-template name="people">
          <xsl:with-param name="nodes" select="$eds"/>
          <xsl:with-param name="role" select="'(Hg.)'"/>
        </xsl:call-template>
        <xsl:if test="$titleM != ''">
          <xsl:text>, </xsl:text>
        </xsl:if>
      </xsl:if>
      <xsl:if test="$titleM != ''">
        <span class="title-m"><xsl:value-of select="$titleM"/></span>
      </xsl:if>
    </xsl:if>
    <xsl:call-template name="series"/>
    <xsl:call-template name="imprint"/>
    <xsl:call-template name="ids"/>
    <xsl:call-template name="links"/>
  </xsl:template>

  <xsl:template name="b-journal">
    <xsl:call-template name="emit-people-prefix">
      <xsl:with-param name="nodes" select="
        if (exists(tei:analytic/tei:author))
        then tei:analytic/tei:author
        else tei:monogr/tei:author
      "/>
    </xsl:call-template>
    <xsl:variable name="titleA" select="normalize-space(string((tei:analytic/tei:title[@level='a'], tei:analytic/tei:title)[1]))"/>
    <xsl:variable name="titleJ" select="normalize-space(string((tei:monogr/tei:title[@level=('j','m')], tei:monogr/tei:title)[1]))"/>
    <xsl:if test="$titleA != ''">
      <span class="title-a">„<xsl:value-of select="$titleA"/>“</span>
      <xsl:if test="$titleJ != ''">
        <xsl:text>. </xsl:text>
      </xsl:if>
    </xsl:if>
    <xsl:if test="$titleJ != ''">
      <span class="title-m"><xsl:value-of select="$titleJ"/></span>
    </xsl:if>
    <xsl:variable name="vol" select="normalize-space(string(tei:monogr/tei:imprint/tei:biblScope[@unit='volume'][1]))"/>
    <xsl:variable name="issue" select="normalize-space(string(tei:monogr/tei:imprint/tei:biblScope[@unit='issue'][1]))"/>
    <xsl:variable name="date" select="normalize-space(string(tei:monogr/tei:imprint/tei:date[1]))"/>
    <xsl:variable name="pages" select="normalize-space(string(tei:monogr/tei:imprint/tei:biblScope[@unit='page'][1]))"/>
    <xsl:if test="$vol != '' or $issue != '' or $date != '' or $pages != ''">
      <span class="imprint">
        <xsl:text> </xsl:text>
        <xsl:value-of select="$vol"/>
        <xsl:if test="$issue != ''">
          <xsl:text>(</xsl:text><xsl:value-of select="$issue"/><xsl:text>)</xsl:text>
        </xsl:if>
        <xsl:if test="$date != ''">
          <xsl:text> </xsl:text><xsl:value-of select="$date"/>
        </xsl:if>
        <xsl:if test="$pages != ''">
          <xsl:text>, </xsl:text><xsl:value-of select="$pages"/>
        </xsl:if>
      </span>
    </xsl:if>
    <xsl:call-template name="ids"/>
    <xsl:call-template name="links"/>
  </xsl:template>

  <xsl:template name="b-thesis">
    <xsl:call-template name="emit-people-prefix">
      <xsl:with-param name="nodes" select="tei:monogr/(tei:author|tei:editor)"/>
    </xsl:call-template>
    <xsl:variable name="titleM" select="normalize-space(string((tei:monogr/tei:title[@level=('m','j')], tei:monogr/tei:title)[1]))"/>
    <xsl:if test="$titleM != ''">
      <span class="title-m"><xsl:value-of select="$titleM"/></span>
    </xsl:if>
    <xsl:variable name="tt" select="normalize-space(string(tei:monogr/tei:imprint/tei:note[@type='thesisType'][1]))"/>
    <xsl:variable name="date" select="normalize-space(string(tei:monogr/tei:imprint/tei:date[1]))"/>
    <xsl:if test="$tt != '' or $date != ''">
      <xsl:if test="$titleM != ''"><xsl:text>. </xsl:text></xsl:if>
      <span class="imprint">
        <xsl:if test="$tt != ''"><xsl:value-of select="$tt"/><xsl:if test="$date != ''"><xsl:text>. </xsl:text></xsl:if></xsl:if>
        <xsl:if test="$date != ''"><xsl:value-of select="$date"/></xsl:if>
      </span>
    </xsl:if>
    <xsl:call-template name="links"/>
  </xsl:template>

  <xsl:template name="b-encyclo">
    <xsl:call-template name="emit-people-prefix">
      <xsl:with-param name="nodes" select="
        if (exists(tei:analytic/tei:author))
        then tei:analytic/tei:author
        else tei:monogr/tei:author
      "/>
    </xsl:call-template>
    <xsl:variable name="titleA" select="normalize-space(string((tei:analytic/tei:title[@level='a'], tei:analytic/tei:title)[1]))"/>
    <xsl:variable name="titleM" select="normalize-space(string((tei:monogr/tei:title[@level=('m','j')], tei:monogr/tei:title)[1]))"/>
    <xsl:if test="$titleA != ''">
      <span class="title-a">„<xsl:value-of select="$titleA"/>“</span>
      <xsl:if test="$titleM != ''"><xsl:text>. </xsl:text></xsl:if>
    </xsl:if>
    <xsl:if test="$titleM != ''">
      <span class="title-m"><xsl:value-of select="$titleM"/></span>
    </xsl:if>
    <xsl:call-template name="imprint"/>
    <xsl:call-template name="links"/>
  </xsl:template>

  <xsl:template name="b-web">
    <xsl:call-template name="emit-people-prefix">
      <xsl:with-param name="nodes" select="
        if (exists(tei:analytic/tei:author))
        then tei:analytic/tei:author
        else tei:monogr/tei:author
      "/>
    </xsl:call-template>
    <xsl:variable name="titleA" select="normalize-space(string((tei:analytic/tei:title[@level='a'], tei:analytic/tei:title)[1]))"/>
    <xsl:variable name="titleM" select="normalize-space(string((tei:monogr/tei:title[@level=('m','j')], tei:monogr/tei:title)[1]))"/>
    <xsl:choose>
      <xsl:when test="$titleA != ''">
        <span class="title-a">„<xsl:value-of select="$titleA"/>“</span>
        <xsl:if test="$titleM != '' and $titleM != $titleA">
          <xsl:text>. </xsl:text>
          <span class="title-m"><xsl:value-of select="$titleM"/></span>
        </xsl:if>
      </xsl:when>
      <xsl:when test="$titleM != ''">
        <span class="title-m"><xsl:value-of select="$titleM"/></span>
      </xsl:when>
    </xsl:choose>
    <xsl:call-template name="imprint"/>
    <xsl:call-template name="links"/>
  </xsl:template>

  <xsl:template name="b-generic">
    <xsl:choose>
      <xsl:when test="tei:analytic/tei:title"><xsl:call-template name="b-bookSection"/></xsl:when>
      <xsl:otherwise><xsl:call-template name="b-book"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="emit-people-prefix">
    <xsl:param name="nodes" as="element()*"/>
    <xsl:param name="role"  as="xs:string" select="''"/>
    <xsl:variable name="people-fragment">
      <xsl:call-template name="people">
        <xsl:with-param name="nodes" select="$nodes"/>
        <xsl:with-param name="role" select="$role"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:if test="normalize-space(string($people-fragment)) != ''">
      <span class="people">
        <xsl:copy-of select="$people-fragment/node()"/>
      </span>
      <xsl:text>: </xsl:text>
    </xsl:if>
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
        <xsl:otherwise><xsl:value-of select="normalize-space(.)"/></xsl:otherwise>
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
    <xsl:variable name="place" select="normalize-space(string($imp/tei:pubPlace[1]))"/>
    <xsl:variable name="publisher" select="normalize-space(string($imp/tei:publisher[1]))"/>
    <xsl:variable name="date" select="normalize-space(string($imp/tei:date[1]))"/>
    <xsl:variable name="pages" select="normalize-space(string($imp/tei:biblScope[@unit='page'][1]))"/>
    <xsl:if test="$place != '' or $publisher != '' or $date != '' or $pages != ''">
      <xsl:text>. </xsl:text>
      <span class="imprint">
        <xsl:if test="$place != ''">
          <xsl:value-of select="$place"/>
          <xsl:if test="$publisher != '' or $date != ''"><xsl:text>: </xsl:text></xsl:if>
        </xsl:if>
        <xsl:if test="$publisher != ''">
          <xsl:value-of select="$publisher"/>
          <xsl:if test="$date != ''"><xsl:text>, </xsl:text></xsl:if>
        </xsl:if>
        <xsl:if test="$date != ''"><xsl:value-of select="$date"/></xsl:if>
        <xsl:if test="$pages != ''">
          <xsl:text>, </xsl:text><xsl:value-of select="$pages"/>
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
