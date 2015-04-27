<cfset blog = request.blogManager.getBlog() />
<cfset title = getIoC('mangoblog').getBean('fileman').getAdminPage() />

<cfset tempskin = getTap().getHTML().skin />
<cfparam name="tempskin.mangoblog" default="#ArrayNew(1)#" />
<cfset ArrayAppend(tempskin.mangoblog,"mangoblog/adminmenu.xsl") />

<cfoutput>
	<cfswitch expression="#tap.layout#">
		<cfcase value="header">
			<div id="container">
				<div id="header">
					<h1>#blog.getTitle()# &gt; #title#</h1>
						<div id="viewsitelink"><a href="#blog.getUrl()#">Go to site</a></div>
					<div id="logout"><a href="index.cfm?logout=1">Logout</a></div>
				</div>
				<!--- the cf_html tag here allows us to use xsl to alter the admin menu outside of Mango Blog if necessary --->
				<cf_html skin="mangoblog">
					<cfmodule template="/inc/mangoblog/admin/navigation.cfm" page="#title#">
				</cf_html>
		</cfcase>
		
		<cfcase value="footer">
				<div id="footer">
					<a href="http://www.mangoblog.org" id="mangolink"><span>Powered by Mango Blog></span></a>
					<span class="footer_version">&nbsp;&nbsp;#request.blogManager.getVersion()#</span>
				</div>
			</div><!--- container --->
		</cfcase>
	</cfswitch>
</cfoutput>

<!--- the css for the Mango Blog Admin causes problems for the debug output --->
<cfset getTap().getCF().onrequestend.debug=false />