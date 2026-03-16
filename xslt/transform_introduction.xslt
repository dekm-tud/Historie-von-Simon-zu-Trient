<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:f="urn:intro-fns"
                exclude-result-prefixes="tei xs f">
    <xsl:import href="common.xslt" />
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
        <xsl:call-template name="page-shell">
            <xsl:with-param name="title"
                            select="concat($site_title, ' — Introduction')" />
            <xsl:with-param name="css-href"
                            select="$css_href" />
            <xsl:with-param name="js-href"
                            select="$js_href" />
            <xsl:with-param name="atRoot"
                            select="false()" />
            <xsl:with-param name="site_title"
                            select="$site_title" />
            <xsl:with-param name="head-extra">
                <script src="assets/leaflet/dist/leaflet.js"
                        type="text/javascript" />
                <link rel="stylesheet"
                      href="assets/leaflet/dist/leaflet.css" />
            </xsl:with-param>
            <xsl:with-param name="content">
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
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="tei:body">
        <div>
            <xsl:apply-templates />
        </div>
    </xsl:template>
    <xsl:template match="tei:p">
        <p>
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
    <xsl:template match="tei:pb" />
    <xsl:template match="tei:lb">
        <br class="lb" />
    </xsl:template>
    <xsl:template match="tei:anchor[@xml:id]">
        <a id="{@xml:id}" />
    </xsl:template>
    <xsl:template match="tei:hi">
        <xsl:variable name="rend"
                      select="normalize-space(@rend)" />
        <xsl:variable name="styles"
                      as="xs:string*"
                      select="(
&#xA;&#xA;        if (contains($rend,'italic')) then 'font-style: italic' else (),
&#xA;&#xA;        if (contains($rend,'bold')) then 'font-weight: 600' else (),
&#xA;&#xA;        if (contains($rend,'underline')) then 'text-decoration: underline' else (),
&#xA;&#xA;        if (contains($rend,'superscript')) then 'vertical-align: super; font-size: smaller' else (),
&#xA;&#xA;        if (matches($rend,'background\([^)]+\)')) then concat('background:', replace($rend,'.*background\(([^)]+)\).*','$1')) else (),
&#xA;&#xA;        if (matches($rend,'color\([^)]+\)')) then concat('color:', replace($rend,'.*color\(([^)]+)\).*','$1')) else ()
&#xA;&#xA;      )" />
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
        <a href="{@target}"
           target="_blank">
            <xsl:apply-templates />
        </a>
    </xsl:template>
    <!-- Karte -->
    <xsl:template match="tei:div[@type='map']">
        <div id="map"
             role="region"
             aria-label="Interaktive Karte der Orte" />
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