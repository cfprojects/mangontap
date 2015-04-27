<cfset getIoC("mangoblog").getBean("application").onRequestStart(cgi.SCRIPT_NAME) />

<cfimport prefix="mango" taglib="/inc/mangoblog/tags/mango">
<cfset pagetemp = getTap().getPage() />

<cfsavecontent variable="title"><mango:Blog title /></cfsavecontent>
<cfsavecontent variable="gen"><cfoutput>Mango <mango:Blog version /></cfoutput></cfsavecontent>
<cfsavecontent variable="descrip"><mango:Blog description />" /></cfsavecontent>
<cfset pagetemp.title = trim(title) />
<cfset pagetemp.meta["generator"] = trim(gen) />
<cfset pagetemp.meta["description"] = trim(descrip) />
