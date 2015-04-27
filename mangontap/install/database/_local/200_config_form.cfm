<cfset structappend(attributes,installer.getConfig(),false) />

<cf_html parent="#pluginmanager.view.main#">
	<div xmlns:tap="xml.tapogee.com" class="formwrapper">
	<form method="post" action="?" tap:variable="installform">
		<input type="hidden" name="netaction" value="<cfoutput>#plugin.getValue('source')#</cfoutput>/install/database/complete" />
		
		<fieldset>
			<legend>Datasource Information</legend>
			
			<p>
				<strong tap:variable="dbtypelabel">Database Type</strong>
				<span class="field">
					<cfif datasource.getValue("server") is "mysql">
						<input type="hidden" name="dbtype" value="mysql" />
					<cfelse>
						<label class="option"><input type="radio" value="mssql" name="dbtype" class="required" tap:required="true" tap:label="dbtypelabel" /> MS SQL 2000</label>
						<label class="option"><input type="radio" value="mssql_2005" name="dbtype" class="required" /> MS SQL 2005</label>
					</cfif>
				</span>
			</p>
			
			<p>
				<label for="prefix" tap:variable="prefixlabel">Table Prefix</label>
				<span class="hint">Fill this if your database is not empty or you have another Mango installation in the same database</span>
				<span class="field"><input type="text" id="prefix" name="prefix" size="20" class="alphanumeric" tap:required="true" tap:label="prefixlabel" tap:default="mango_"/></span>
			</p>
			
		</fieldset>
		
		<div style="text-align:center;">
			<button type="button">
				<tap:event name="onclick">
					<tap:location href="?netaction=<cfoutput>#plugin.getValue('source')#</cfoutput>/install/configure" domain="C" />
				</tap:event>
				Skip
			</button>
			<button type="submit">Next</button>
		</div>
		
	</form>
	</div>
</cf_html>
