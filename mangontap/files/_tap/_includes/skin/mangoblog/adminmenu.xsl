<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:tap="xml.tapogee.com" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="xml" indent="no" omit-xml-declaration="yes" />
	
	<xsl:variable name="lcase" select="'abcdefghijklmnopqrstuvwxyz'" />
	<xsl:variable name="ucase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
	<xsl:variable name="tap" select="'xml.tapogee.com'" />
	
	<xsl:template match="comment()">
		<xsl:copy-of select="." />
	</xsl:template>
	
	<xsl:template match="text()">
		<xsl:copy-of select="." />
	</xsl:template>
	
	<xsl:template match="*">
		<xsl:copy>
			<xsl:copy-of select="@*" />
			<xsl:apply-templates />
		</xsl:copy>
	</xsl:template>
	
	<!-- remove the authors menu item - this is handled by the Members onTap security -->
	<xsl:template match="*[translate(name(),$ucase,$lcase)='li' and translate(@*[translate(name(),$ucase,$lcase)='id'],$ucase,$lcase)='authorsmenuitem']">
		<xsl:copy>
			<xsl:copy-of select="@*" />
			<a href="admin/security/members/" tap:domain="T"> Users </a>
		</xsl:copy>
	</xsl:template>
	
</xsl:stylesheet>
