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
        <div class="site-header__item site-header__item--left">
          <a href="/">Home</a>
        </div>
        <div class="site-header__item site-header__item--right">
          <a href="//twitter.com/benkyriakou">
            Twitter
          </a>
        </div>
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
        <xsl:copy-of select="content/node()" />
      </div>
    </article><!-- /.article -->
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
