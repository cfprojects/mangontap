<cfimport prefix="mango" taglib="/inc/mangoblog/tags/mango">

<!--- check for entry query string --->
<cfif structkeyexists(request.externalData,"entry")>
	<!--- for individual pages, we only need id/name --->
	<cfset request.externalData.pageName = listlast(request.externalData.entry,"/") />
<cfelseif arraylen(request.externalData.raw)>
	<!--- put variables into the request scope --->
	<cfset request.externalData.pageName = request.externalData.raw[arraylen(request.externalData.raw)] />
<cfelse>
	<!--- unknown post --->
	<cfset request.externalData.pageName =  "" />
</cfif>

<cfsavecontent variable="title">
<mango:Page>
	<cfoutput><mango:PageProperty title /> &mdash; <mango:Blog title /></cfoutput>
</mango:Page>
</cfsavecontent>

<cfset getTap().getPage().title = trim(title) />
