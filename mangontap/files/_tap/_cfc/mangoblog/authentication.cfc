<cfcomponent displayname="MangoBlog.Authentication" output="false" 
hint="This component maps Members onTap member data to a Mango Blog credential object, allowing Mango blog to use the Members onTap user / security system">
	<cfinclude template="mixin.cfm" />
	
	<cffunction name="init" access="public" output="false" returntype="any">
		<!--- these are the arguments that are passed to the object from Mango Blog, but we don't need or use them --->
		<!--- 
			<cfargument name="mainApp" required="true" type="any">
			<cfargument name="settings" required="true" type="struct">
		---> 
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="checkCredentials" access="public" hint="This should return a credential object">
		<cfargument name="credentials" type="any" required="true" hint="This should be a model.Credential object" />
		<cfscript>
			var permission = 0; 
			var usr = credentials.getUserName(); 
			var ioc = getIoC("membersontap"); 
			var auth = ioc.getBean("login").authenticate(usr,credentials.getPassword()); 
			
			// we need the member object to set properties for the user below 
			var factory = ioc.getBean("memberfactory"); 
			var member = factory.getMember(factory.getMemberID(usr)); 
			
			// load the credentials object with data from the member object 
			loadMemberCredentials(credentials,member); 
			
			return arguments.credentials; 
		</cfscript>
	</cffunction>
	
	<cffunction name="newCredentials" access="private" output="false">
		<cfreturn CreateObject("component","inc.mangoblog.components.model.Credential") />
	</cffunction>
	
	<cffunction name="setCurrentUser" access="private" output="false">
		<cfargument name="author" type="any" required="true" />
		<cfset getIoC("mangoblog").getBean("Mango").setCurrentUser(author) />
	</cffunction>
	
	<cffunction name="loadSessionCredentials" access="public" output="false" 
	hint="loads the current session member and ensures that they exist in the Mango Blog database">
		<cfset var credentials = loadMemberCredentials(newCredentials(),getTap().session.getMember(),true) />
		<cfset setCurrentUser(setupNativeAuthor(credentials)) />
	</cffunction>
	
	<cffunction name="setupNativeAuthor" access="private" output="false">
		<cfargument name="credentials" type="any" required="true" hint="This should be a model.Credential object" />
		<cfreturn getIoC("mangoblog").getBean("Authorizer").setupNativeAuthor(credentials) />
	</cffunction>
	
	<cffunction name="loadMemberCredentials" access="public" hint="This should return a credential object">
		<cfargument name="credentials" type="any" required="true" hint="This should be a model.Credential object" />
		<cfargument name="member" type="any" required="true" hint="this is a member object from the member factory" />
		<cfscript>
			var permission = 0; 
			var usr = ""; 
			
			if (member.isLoaded()) { 
				// initialize the credentials first 
				usr = member.getValue("MemberUsername"); 
				credentials.init(usr, member.getValue("MemberPassword"), 
									  member.getValue("PreferredFamiliarName"), 
									  member.getValue("MemberEmail"), 
									  "", "administrator"); // this would normally be a Mango Blog role, but we're using Members onTap security instead, so we assign max permissions here with the "administrator" role 
				
				// we need to determine the process path for the permission based on the location of the blog in the site 
				permission = getTapConfig().location & "/admin"; 
				
				// the user is authorized to view the blog admin if they have the correct permission 
				credentials.setIsAuthorizer(getIoC("membersontap").getBean("PolicyManager").isPermitted(permission,member.getValue("memberid"))); 
				
			} else { 
				// if the user isn't logged in, then they definitely aren't allowed to admin the blog 
				credentials.setIsAuthorizer(false); 
			} 
			
			return credentials; 
		</cfscript>
	</cffunction>
</cfcomponent>