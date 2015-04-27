<cfif installer.checkInstallation()>
	<cfset installer.installFiles() />
	<cfset tap.goto.domain = "C" />
	<cfset tap.goto.href = structNew() />
	<cfset tap.goto.href.netaction = plugin.getValue('source') & '/install/database' />
</cfif>

<cfparam name="attributes.location" type="string" default="blog" />
<cfset request.location = attributes.location />

<cf_html return="temp" parent="#pluginmanager.view.main#">
	<div xmlns:tap="xml.tapogee.com" class="formwrapper">
		<tap:form tap:domain="C" tap:variable="installForm">
			<input type="hidden" name="netaction" 
				value="<cfoutput>#plugin.getValue('source')#</cfoutput>/install/download/getarchive" />
			
			<input type="text" name="location" label="Location" tap:required="true" hint="Where do you want your blog?">
				<tap:event name="onkeyup"><cfoutput>
					document.getElementById('destination').innerHTML = '#getLib().getURL('/','T')#' + element.value; 
				</cfoutput></tap:event>
			</input>
			
			<button type="submit" style="margin:5px;">Download</button>
		</tap:form>
		
		<div id="destination">
			<tap:text><cfoutput><![CDATA[#getLib().getURL(attributes.location,'T')#]]></cfoutput></tap:text>
		</div>
	</div>
</cf_html>
