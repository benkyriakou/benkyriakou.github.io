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

        <title><xsl:apply-templates select="document/title" /></title>

        <link href="//fonts.googleapis.com/css?family=Lato:400,900" rel="stylesheet" type="text/css" />
        <link type="text/css" rel="stylesheet" href="/css/normalize.css" media="all" />
        <link type="text/css" rel="stylesheet" href="/css/style.css" media="all" />

        <script>
          var userAgent = navigator.userAgent || navigator.vendor || window.opera;

          if (userAgent.match(/Android/i)) {
            document.documentElement.className += ' is-android';
          }
        </script>

        <xsl:call-template name="google-analytics" />
      </head>
      
      <body>
        <div class="wrapper">
          <header class="site-header">
            <xsl:call-template name="header" />
          </header><!--/header-->
          <main class="center-wrapper">
            <xsl:apply-templates select="document/content" />
          </main><!-- /main -->
        </div>
      </body>
    </html>
  </xsl:template>

  <xsl:template name="header">
    <div class="center-wrapper">
      <nav>
        <div class="site-header__item site-header__item--left">
          <a href="/">Home</a>
        </div>
        <div class="site-header__item site-header__item--right">
          <a href="//twitter.com/benkyriakou" target="_blank">
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
      <time class="article__date" datetime="{date/@datetime}">
        <xsl:value-of select="date" />
      </time>
      <h1 class="article__header">
        <xsl:value-of select="title" />
      </h1>
      <xsl:copy-of select="content/node()" />
    </article><!-- /.article -->
  </xsl:template>

  <xsl:template match="document[@type='homepage']/content">
    <h1 class="hidden">Ben Kyriakou</h1>
    <div class="articles">
      <xsl:apply-templates select="article" mode="teaser" />
    </div>
  </xsl:template>

  <xsl:template match="article" mode="teaser">
    <article class="article article--teaser">
      <time class="article__date" datetime="{date/@datetime}">
        <xsl:value-of select="date" />
      </time>
      <h2 class="article__header">
        <a href="/posts/{slug}">
          <xsl:value-of select="title" />
        </a>
      </h2>
      <p><xsl:value-of select="description" /></p>
    </article>
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
