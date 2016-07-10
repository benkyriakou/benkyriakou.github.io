<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html" doctype-system="about:legacy-compat" />

  <xsl:template match="/">
    <html lang="en">
      <head>
        <meta charset="utf-8" />
        <meta name="theme-color" content="#333" />
        <meta name="description" content="{document/description}" />
        <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=1" />
        <link rel="canonical" href="http://benkyriakou.com{document/slug}" />
        <link rel="shortcut icon" href="/favicon.ico" type="image/x-icon" />

        <title><xsl:apply-templates select="document/title" /></title>

        <link type="text/css" rel="stylesheet" href="/css/style.css" media="all" />

        <xsl:call-template name="open-graph" />
        <xsl:call-template name="twitter-card" />
        <xsl:call-template name="google-analytics" />
      </head>
      
      <body>
        <div class="wrapper">
          <header class="site-header">
            <xsl:call-template name="header" />
          </header><!--/header-->
          <main class="center-wrapper">
            <xsl:apply-templates select="document" />
          </main><!-- /main -->
        </div>

        <script>
          var userAgent = navigator.userAgent || navigator.vendor || window.opera;

          if (userAgent.match(/Android/i)) {
            document.documentElement.className += ' is-android';
          }
        </script>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="document">
    <xsl:if test="not(title) or title=''">
      <xsl:message terminate="yes">
        Document requires a title value.
      </xsl:message>
    </xsl:if>

    <xsl:if test="not(description) or description=''">
      <xsl:message terminate="yes">
        Document requires a description value.
      </xsl:message>
    </xsl:if>

    <xsl:apply-templates select="content" />
  </xsl:template>

  <xsl:template name="header">
    <div class="center-wrapper">
      <nav>
        <ul class="site-header__items">
          <li class="site-header__item">
            <a href="/">Home</a>
          </li>
          <li class="site-header__item">
            <a href="//drupal.org/u/ben.kyriakou">Drupal.org</a>
          </li>
          <li class="site-header__item">
            <a href="//twitter.com/benkyriakou">Twitter</a>
          </li>
        </ul>
      </nav>
    </div>
  </xsl:template>

  <xsl:template match="document[@type!='homepage']/title">
    <xsl:value-of select="text()" /><xsl:text> | Ben Kyriakou</xsl:text>
  </xsl:template>

  <xsl:template match="article">
    <article class="article">
      <xsl:if test="date/@datetime">
        <time class="article__date" datetime="{date/@datetime}">
          <xsl:value-of select="date" />
        </time>
      </xsl:if>
      <h1 class="article__header">
        <xsl:value-of select="title" />
      </h1>
      <div class="article__content">
        <xsl:apply-templates select="content" />
        <xsl:apply-templates select="content" mode="reference" />
      </div>
    </article><!-- /.article -->
  </xsl:template>

  <!-- The general template for content nodes. -->
  <!-- In most cases we just want to copy the HTML verbatim. -->
  <xsl:template match="article/content//*">
    <xsl:copy>
      <!-- Also copy any attributes of the current node. -->
      <xsl:copy-of select="@*" />

      <!-- Continue applying templates to child nodes. -->
      <xsl:apply-templates />
    </xsl:copy>
  </xsl:template>

  <!-- Override content processing for references. -->
  <xsl:template match="content//reference">
    <sup class="reference">
      <a href="#{@id}" id="ref-{@id}">
        <xsl:number level="any" count="reference" />
      </a>
    </sup>
  </xsl:template>

  <!-- In code blocks, ignore external whitespace nodes and only process -->
  <!-- lines of code wrapped in a <span> -->
  <xsl:template match="content//pre/code">
    <xsl:copy>
      <xsl:copy-of select="@*" />
      <xsl:apply-templates select="span" />
    </xsl:copy>
  </xsl:template>

  <!-- Add a newline after each line of code in a code block -->
  <xsl:template match="content//pre/code/span">
    <xsl:copy>
      <xsl:copy-of select="@*" />
      <xsl:apply-templates />
    </xsl:copy>
    <xsl:text>&#xa;</xsl:text><!-- \n -->
  </xsl:template>

  <xsl:template match="content" mode="reference">
    <xsl:if test="count(/document//reference) &gt; 0">
      <ol class="references">
        <xsl:apply-templates select=".//reference" mode="reference" />
      </ol>
    </xsl:if>
  </xsl:template>

  <xsl:template match="content//reference" mode="reference">
    <li>
      <a href="#ref-{@id}" title="Return to reference">^</a>
      <xsl:text> </xsl:text>
      <cite class="references__item">
        <a id="{@id}" href="{@href}" rel="external">
          <xsl:value-of select="@title" />
        </a>
      </cite>
    </li>
  </xsl:template>

  <xsl:template match="document[@type='homepage']/content">
    <h1 class="hidden">Ben Kyriakou</h1>
    <div class="articles">
      <xsl:apply-templates select="document[@type='article']" mode="teaser" />
    </div>
  </xsl:template>

  <xsl:template match="document[@type='article']" mode="teaser">
    <article class="article article--teaser">
      <time class="article__date" datetime="{.//article/date/@datetime}">
        <xsl:value-of select=".//article/date" />
      </time>
      <h2 class="article__header">
        <a href="{slug}">
          <xsl:value-of select=".//article/title" />
        </a>
      </h2>
      <div class="article__content">
        <p><xsl:value-of select="description" /></p>
      </div>
    </article>
  </xsl:template>

  <xsl:template name="open-graph">
    <meta property="og:url" content="http://benkyriakou.com{document/slug}" />
    <meta property="og:title" content="{document/title}" />
    <meta property="og:description" content="{document/description}" />
    <meta property="og:image" content="http://benkyriakou.com/images/global/twitter-card-image.png" />
  </xsl:template>

  <xsl:template name="twitter-card">
    <meta name="twitter:card" content="summary" />
    <meta name="twitter:site" content="@benkyriakou" />
    <meta name="twitter:title" content="{document/title}" />
    <meta name="twitter:description" content="{document/description}" />
    <meta name="twitter:image" content="http://benkyriakou.com/images/global/twitter-card-image.jpg" />
  </xsl:template>

  <xsl:template name="google-analytics">
    <script>
      (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
      (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
      m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
      })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

      ga('create', 'UA-64337321-1', 'auto');
      ga('send', 'pageview');
    </script>
  </xsl:template>
</xsl:stylesheet>
