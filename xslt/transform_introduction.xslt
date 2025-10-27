<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:f="urn:intro-fns"
                exclude-result-prefixes="tei xs f">
                
                
    <xsl:param name="site_title"
               as="xs:string"
               select="'Historie von Simon zu Trient – Digitale Edition'" />
    
    <xsl:param name="css_href"
               as="xs:string"
               select="'assets/site.css'" />
    <xsl:param name="js_href"
               as="xs:string"
               select="'assets/site.js'" />
    <xsl:output method="html"
                indent="no"
                encoding="UTF-8"
                omit-xml-declaration="yes" />
    
    <!-- Footnote number helper -->
    <xsl:function name="f:fn-number"
                  as="xs:integer">
        <xsl:param name="n"
                   as="element(tei:note)" />
        <xsl:sequence select="count($n/preceding::tei:note[@place='foot']) + 1" />
    </xsl:function>
    
    <xsl:template match="/tei:TEI">
        <html lang="de">
            <head>
                <meta charset="utf-8" />
                <meta name="viewport"
                      content="width=device-width, initial-scale=1" />
                <title>
                    <xsl:value-of select="concat($site_title, ' — Introduction')" />
                </title>
                <link rel="stylesheet"
                      href="{$css_href}" />
            </head>
            <body class="mode-expan">
                <header class="site-header">
                    <nav class="nav">
                        <div class="brand">
                            <xsl:value-of select="$site_title" />
                        </div>
                        <div class="menu">
                            <a href="../index.html">Home</a>
                            <a aria-current="page"
                               href="introduction.html">Einleitung</a>
                            <a href="edition.html">Edition</a>
                            <a href="literature.html">Literatur</a>
                        </div>
                    </nav>
                </header>
                <main class="container">
                    <section id="intro">
                        <h1>Einleitung</h1>
    
                        <xsl:variable name="author"
                                      select="normalize-space(tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author)" />
                        <xsl:variable name="date"
                                      select="normalize-space(tei:teiHeader/tei:editionStmt/tei:edition/tei:date)" />
                        <xsl:if test="$author or $date">
                            <p style="color:var(--muted)">
                                <xsl:if test="$author">
                                    <xsl:text>Von </xsl:text>
                                    <a href="https://orcid.org/0000-0003-1635-9248">
                                        <xsl:value-of select="$author" />
                                    </a>
                                </xsl:if>
                                <xsl:if test="$author and $date">
                                    <xsl:text> — </xsl:text>
                                </xsl:if>
                                <xsl:if test="$date">
                                    <time datetime="{$date}">
                                        <xsl:value-of select="$date" />
                                    </time>
                                </xsl:if>
                            </p>
                        </xsl:if>
    
                        <xsl:apply-templates select="tei:text/tei:body" />
    
                        <!-- Footnotes -->
                        <xsl:if test="//tei:note[@place='foot']">
                            <h2 style="margin-top:2rem">Anmerkungen</h2>
                            <ol class="footnotes">
                                <xsl:apply-templates select="//tei:note[@place='foot']"
                                                     mode="foot" />
                            </ol>
                        </xsl:if>
                    </section>
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
                <script src="{$js_href}" />
            </body>
        </html>
    </xsl:template>
    
    <xsl:template match="tei:body">
        <div>
            <xsl:apply-templates />
        </div>
    </xsl:template>
    <xsl:template match="tei:p">
        <p>
            <!-- preserve simple inline text-align from the Word import -->
            <xsl:if test="@style">
                <xsl:attribute name="style">
                    <xsl:value-of select="@style" />
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates />
        </p>
    </xsl:template>
    <xsl:template match="tei:p[@rend='TOC Heading']">
        <h2>
            <xsl:apply-templates />
        </h2>
    </xsl:template>
    <xsl:template match="tei:list[@rend='bulleted']">
        <ul>
            <xsl:apply-templates />
        </ul>
    </xsl:template>
    <xsl:template match="tei:head">
        <h2>
            <xsl:apply-templates />
        </h2>
    </xsl:template>
    <xsl:template match="tei:item">
        <li>
            <xsl:apply-templates />
        </li>
    </xsl:template>
    <!-- ignore page breaks -->
    <xsl:template match="tei:pb" />
    <!-- line break -->
    <xsl:template match="tei:lb">
        <br class="lb" />
    </xsl:template>
    <!-- anchors become in-page targets -->
    <xsl:template match="tei:anchor[@xml:id]">
        <a id="{@xml:id}" />
    </xsl:template>
    
    <xsl:template match="tei:hi">
        <xsl:variable name="rend"
                      select="normalize-space(@rend)" />
        <xsl:variable name="styles"
                      as="xs:string*"
                      select="(
&#xA;        if (contains($rend,'italic')) then 'font-style: italic' else (),
&#xA;        if (contains($rend,'bold')) then 'font-weight: 600' else (),
&#xA;        if (contains($rend,'underline')) then 'text-decoration: underline' else (),
&#xA;        if (contains($rend,'superscript')) then 'vertical-align: super; font-size: smaller' else (),
&#xA;        if (matches($rend,'background\([^)]+\)')) then concat('background:', replace($rend,'.*background\(([^)]+)\).*','$1')) else (),
&#xA;        if (matches($rend,'color\([^)]+\)')) then concat('color:', replace($rend,'.*color\(([^)]+)\).*','$1')) else ()
&#xA;      )" />
        <span>
            <xsl:if test="exists($styles)">
                <xsl:attribute name="style"
                               select="string-join($styles,'; ')" />
            </xsl:if>
            <xsl:apply-templates />
        </span>
    </xsl:template>
    
    <!-- links -->
    <xsl:template match="tei:ref[@target]">
        <a href="{@target}">
            <xsl:apply-templates />
        </a>
    </xsl:template>
    
    <!-- Footnotes -->
    <xsl:template match="tei:note[@place='foot']">
        <xsl:variable name="num"
                      select="if (@n) then @n else f:fn-number(.)" />
        <sup id="fnref-{(@xml:id, generate-id())[1]}">
            <a href="#fn-{(@xml:id, generate-id())[1]}">
                <xsl:value-of select="$num" />
            </a>
        </sup>
    </xsl:template>
    
    <xsl:template match="tei:note[@place='foot']"
                  mode="foot">
        <xsl:variable name="num"
                      select="if (@n) then @n else f:fn-number(.)" />
        <li id="fn-{(@xml:id, generate-id())[1]}">
    
            <xsl:choose>
                <xsl:when test="tei:p">
                    <xsl:apply-templates select="tei:p/node()" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates />
                </xsl:otherwise>
            </xsl:choose>
            <a href="#fnref-{(@xml:id, generate-id())[1]}"
               aria-label="Back to content">↩︎</a>
        </li>
    </xsl:template>
    
    <xsl:template match="text()">
        <xsl:value-of select="." />
    </xsl:template>
    <xsl:template match="*">
        <xsl:apply-templates />
    </xsl:template>
</xsl:stylesheet>