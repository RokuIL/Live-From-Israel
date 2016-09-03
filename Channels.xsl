<?xml version="1.0" encoding="UTF-8"?>
<html xsl:version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<body>
<table>
  <tr>
    <xsl:for-each select="Channels/Channel">
      <xsl:if test="position() mod 7 = 1">
        <tr/>
      </xsl:if>
      <td>
      <table>
        <tr>
          <td>
            <xsl:value-of select="@Title"/>
          </td>
        </tr>
        <tr>
          <td>
            <xsl:element name="iframe">
              <xsl:attribute name="width">180</xsl:attribute>
              <xsl:attribute name="height">180</xsl:attribute>
              <xsl:attribute name="src">
                <xsl:value-of select="@StreamURL"/>
              </xsl:attribute>
            </xsl:element>
          </td>
        </tr>
      </table>
      </td>
    </xsl:for-each>
  </tr>
</table>
</body>
</html>