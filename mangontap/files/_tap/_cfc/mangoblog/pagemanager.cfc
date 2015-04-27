<cfcomponent name="MangoBlog.PageManager" extends="inc.mangoblog.components.PageManager" output="false">
	<cfinclude template="mixin.cfm" />
	
	<cffunction name="getPageById" access="public" output="false" returntype="any">
		<cfargument name="id" required="true" type="string" hint="Id"/>
		<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts"/>
		<cfargument name="useWrapper" required="false" type="boolean" hint="Whether to use the page wrapper"/>
		
		<!--- admin mode does not use cache --->
		<cfset var pagesQuery = "" />
		<cfset var pages = "" />
		<cfset var cacheresult = variables.itemsCache.checkAndRetrieve(arguments.id) />
		<cfset var eventObj =  structnew() />
		<cfset var event = "" />
		
		<cfif NOT structkeyexists(arguments, 'useWrapper')>
			<cfset arguments.useWrapper = NOT arguments.adminMode />
		</cfif>
		
		<cfif NOT arguments.adminMode AND cacheresult.contains>
			<cfif arguments.useWrapper>
				<cfreturn tapGetObject("PageWrapper").init(variables.pluginQueue, cacheresult.value) />
			<cfelse>
				<cfreturn cacheresult.value />
			</cfif>
		<cfelse>
			<!--- not in cache, we must get it from db --->
			<cfset pagesQuery = variables.accessObject.getById(arguments.id,arguments.adminMode) />
			<cfset pages = packageObjects(pagesQuery,1,1, arguments.useWrapper, NOT arguments.adminMode) />
			<cfif NOT pagesQuery.recordcount>
				<cfthrow errorcode="PageNotFound" message="Page was not found" type="PageNotFound">
			</cfif>
			
			<cfset eventObj.collection = pages />
			<cfset eventObj.query = pagesQuery />
			<cfset eventObj.arguments = arguments />	
			<cfset event = variables.pluginQueue.createEvent("getPageById",eventObj,"Collection") />
			<cfset event = variables.pluginQueue.broadcastEvent(event) />
			
			<cfreturn pages[1] />
		</cfif>
		
	</cffunction>
	
	<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="packageObjects" access="private" output="false" returntype="array">
		<cfargument name="pagesQuery" required="true" type="query">
		<cfargument name="from" required="false" default="1" type="numeric" hint=""/>
		<cfargument name="count" required="false" default="0" type="numeric" hint=""/>
		<cfargument name="useWrapper" required="false" default="true" type="boolean" hint="Whether to use page wrapper"/>
		<cfargument name="useCache" required="false" type="boolean" hint="Whether to use the page cache"/>
		
		<cfset var pages = arraynew(1) />
		<cfset var thisPage = "" />
		<cfset var urlString = "" />
		<cfset var parent = 0 />
		<cfset var i = 0/>
		<cfset var thisid = "" />
		<cfset var hierarchyNames = "" />
		<cfset var wrappedPage = "" />
		<cfset var cacheCheck = "" />
		<cfset var createNewPage = true />
		<cfset var pageUrl = "" />
		<cfset var blogUrl = "" />
		<cfset var blog = "" />
		
		<cfif NOT structkeyexists(arguments, 'useCache')>
			<cfset arguments.useCache = arguments.useWrapper />
		</cfif>
		
		<cfif arguments.count EQ 0>
			<cfset arguments.count = pagesQuery.recordcount />
		</cfif>
		
		<cfif pagesQuery.recordcount>
			<cfset blog = variables.mainApp.getBlog() />
			<cfset pageUrl = blog.getSetting("pageUrl") />
			<cfset blogUrl = blog.getUrl() />
			
			<cfoutput query="arguments.pagesQuery" group="id">
				<cfset i = i + 1 />
				<cfset hierarchyNames = ""/>
				<cfset createNewPage = true />
				<cfif i GTE arguments.from AND i LT (arguments.count + arguments.from)>
					<!--- check the cache --->
					<cfif arguments.useCache>
						<cfset cacheCheck = variables.itemsCache.checkAndRetrieve(id) />
						<cfif cacheCheck.contains>
							<cfset thisPage = cacheCheck.value />
							<cfset createNewPage = false />
						</cfif>
					</cfif>
					
					<cfif createNewPage>
						<cfset thisPage = tapGetObject("model.Page") />
										
						<cfif NOT len(parent_page_id)>
							<cfset parent = 0 />
						<cfelse>
							<cfset parent = parent_page_id />
						</cfif>
					
						<cfscript>
							thisPage.parentPageId = parent_page_id;
							thisPage.template = template;
							thisPage.hierarchy = hierarchy;
							thisPage.id = id;
							thisPage.name = name;
							thisPage.title = title;
							thisPage.content = content;
							thisPage.excerpt = excerpt;
							thisPage.authorId = author_id;
							thisPage.author = author;
							thisPage.commentsAllowed = comments_allowed;
							thisPage.status = status;
							thisPage.lastModified = last_modified;
							thisPage.commentCount = comment_count;
							thisPage.sortOrder = sort_order;
							thisPage.blogId = blog_id;
						</cfscript>
					
						<cfoutput group="field_id">
							<cfif len(field_id)>
								<cfset thisPage.customFields[field_id] = structnew() />
								<cfset thisPage.customFields[field_id]["key"] = field_id  />
								<cfset thisPage.customFields[field_id]["name"] = field_name  />
								<cfset thisPage.customFields[field_id]["value"] = field_value  />
								<!--- the above should have been done this way, but I am trying to avoid function calls to make it faster --->
								<!--- <cfset thisPage.setCustomField(field_id,field_name,field_value) /> --->
							</cfif>
						</cfoutput>
						
						<!--- replace hierarchy ids for names --->
						<cfloop list="#hierarchy#" index="thisid" delimiters="/">
							<cfset hierarchyNames = listappend(hierarchyNames,getPageNameFromCache(thisid),"/") />						
						</cfloop>
						
						<cfif len(hierarchyNames)>
							<cfset hierarchyNames = hierarchyNames & "/"/>
						</cfif>
						<!--- set URL with setting from blog --->
						<cfset urlString = replacenocase(replacenocase(replacenocase(pageUrl,"{pageid}",id),
									"{pageName}",name),
									"{pageHierarchyNames}",hierarchyNames) />
						
						<cfset thisPage.urlString = urlString />
						<cfset thisPage.permalink = blogUrl & urlString />
					</cfif>
					
					
					<cfif arguments.useWrapper>
						<cfset wrappedPage = tapGetObject("PageWrapper").init(variables.pluginQueue,thisPage) />						
					<cfelse>
						<cfset wrappedPage = thisPage />
					</cfif>
					<cfif createNewPage AND arguments.useCache>
						<!--- store in cache (only if we are not in admin mode and we have not retrieved it from the cache already) --->
						<cfset variables.itemsCache.store(id,thisPage) />
					</cfif>
					
					<cfset arrayappend(pages,wrappedPage)>
				</cfif>
				
			</cfoutput>
		</cfif>
		<cfreturn pages />
	</cffunction>

</cfcomponent>