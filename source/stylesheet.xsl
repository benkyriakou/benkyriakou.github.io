<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:str="http://exslt.org/strings"
  xmlns:re="http://exslt.org/regular-expressions"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  exclude-result-prefixes="str xi re">

  <xsl:output method="html" encoding="utf-8" indent="yes" doctype-system="about:legacy-compat" />

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

        <link rel="stylesheet" href="/css/style.css" type="text/css" />

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
      </body>
    </html>
  </xsl:template>

  <xsl:template match="document">
    <xsl:if test="not(title) or title=''">
      <xsl:message terminate="yes">
        <xsl:text>Document requires a title value.</xsl:text>
      </xsl:message>
    </xsl:if>

    <xsl:if test="not(description) or description=''">
      <xsl:message terminate="yes">
        <xsl:text>Document requires a description value.</xsl:text>
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
            <a href="/about">About</a>
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

  <!-- Convert img tags to picture tags -->
  <xsl:template match="article//img">
    <xsl:variable name="file_path">
      <xsl:call-template name="filepath">
        <xsl:with-param name="path" select="@src" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="derivative_path" select="str:replace($file_path, '/articles/', '/derivatives/')" />
    <xsl:variable name="file_extension" select="substring(@src, string-length($file_path) + 1)" />

    <picture>
      <source media="(min-width: 1024px)" srcset="{@src}" />
      <source media="(min-width: 600px)" srcset="{$derivative_path}_760{$file_extension}" />
      <img src="{$derivative_path}_320{$file_extension}" alt="{@alt}" title="{@title}" />
    </picture>

  </xsl:template>

  <!-- Add URL fragment slugs to headings. -->
  <xsl:template match="content//*[re:match(name(), '^h[2-6]$')]">
    <xsl:copy select=".">
      <xsl:attribute name="id">
        <xsl:text>section-</xsl:text>
        <xsl:call-template name="slugify">
          <xsl:with-param name="raw_str" select="string(.)" />
        </xsl:call-template>
      </xsl:attribute>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- Add custom index generation. -->
  <xsl:template match="content//index">
    <div class="index">
      <ul class="index-level">
        <xsl:apply-templates select="following-sibling::h2" mode="index" />
      </ul>
    </div>
  </xsl:template>

  <!-- Simple top-level index template. -->
  <!-- @todo Extend this to allow multi-level indexes. -->
  <xsl:template match="h2" mode="index">
    <xsl:variable name="slug">
      <xsl:text>section-</xsl:text>
      <xsl:call-template name="slugify">
        <xsl:with-param name="raw_str" select="string(.)" />
      </xsl:call-template>
    </xsl:variable>

    <li>
      <a href="#{$slug}"><xsl:value-of select="string(.)" /></a>
    </li>
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
      <time class="article__date article__date--teaser" datetime="{.//article/date/@datetime}">
        <xsl:value-of select=".//article/date" />
      </time>
      <xsl:if test="@rel and @rel='external'">
        <span class="article__external">External article</span>
      </xsl:if>
      <h2 class="article__header article__header--teaser">
        <a href="{slug}">
          <xsl:value-of select=".//article/title" />
        </a>
      </h2>
      <div class="article__content article__content--teaser">
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
    <meta name="twitter:image" content="http://benkyriakou.com/images/global/twitter-card-image.png" />
  </xsl:template>

  <xsl:template name="google-analytics">
    <script>
      window.onload = function() {
        (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
        (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
        m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
        })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

        ga('create', 'UA-64337321-1', 'auto');
        ga('send', 'pageview');
      };
    </script>
  </xsl:template>

  <xsl:template name="filepath">
    <xsl:param name="path" />

    <xsl:call-template name="get_filepath">
      <xsl:with-param name="current_path" select="$path" />
      <xsl:with-param name="original_path" select="$path" />
    </xsl:call-template>
  </xsl:template>

  <!-- Split the file path from the file extension -->
  <xsl:template name="get_filepath">
    <xsl:param name="current_path" />
    <xsl:param name="original_path" />

    <xsl:variable name="path_len" select="string-length($current_path)" />

    <!-- Return if we reach the end of the path, or we reach the first period -->
    <xsl:choose>
      <!-- When the path length is 0, we've reached the end of the string -->
      <xsl:when test="$path_len = 0">
        <xsl:value-of select="''" />
      </xsl:when>

      <!-- When the last string is a period, we've reached the extension boundary -->
      <xsl:when test="substring($current_path, $path_len) = '.'">
        <xsl:value-of select="substring($current_path, 1, $path_len - 1)" />
      </xsl:when>

      <!-- Otherwise, continue recursing into the string -->
      <xsl:otherwise>
        <xsl:call-template name="get_filepath">
          <xsl:with-param name="current_path" select="substring($current_path, 1, $path_len - 1)" />
          <xsl:with-param name="original_path" select="$original_path" />
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Template to convert arbitrary strings into alphanumeric ASCII URL slugs. -->
  <!-- @todo This would be much nicer as a function if I can get lxml to play nicely with EXSLT. -->
  <xsl:template name="slugify">
    <xsl:param name="raw_str" />

    <xsl:variable name="alphanumeric" select="re:replace($raw_str, '[^a-z0-9\s]', 'gi', '')" />
    <xsl:variable name="lowercase" select="translate($alphanumeric, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')" />
    <xsl:variable name="slug" select="re:replace($lowercase, '\s+', 'g', '-')" />

    <xsl:value-of select="$slug" />
  </xsl:template>
</xsl:stylesheet>
