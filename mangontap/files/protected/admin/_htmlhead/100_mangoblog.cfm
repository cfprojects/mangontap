<cfimport prefix="mangoAdmin" taglib="/inc/mangoblog/admin/tags" />
<cfset blog = request.blogManager.getBlog() />
<cfset currentSkin = request.administrator.getSkin(blog.getSkin()) />

<cfoutput>
	<cfset temp = getLib().getURL("_includes/mangoblog/admin","P") />
	<script type="text/javascript" src="#temp#/assets/scripts/jquery/jquery-1.3.2.min.js" ></script>
	<script type="text/javascript" src="#temp#/assets/scripts/jquery/jquery.metadata.min.js" ></script>
	<script type="text/javascript" src="#temp#/assets/scripts/jquery/jquery.validate.min.js" ></script>
	<link href="#temp#/assets/styles/tiger.css" rel="stylesheet" type="text/css" />
	<!--[if lte IE 6]>
	<link href='#temp#/assets/styles/tiger_ie.css' rel="stylesheet"  type='text/css' media='screen'>
	<![endif]-->
	<link href="#temp#/assets/styles/custom.css" rel="stylesheet" type="text/css" />
	<style>
		##header h1 { 
			text-transform: capitalize; 
		} 
	</style>
	
	<cfinclude template="/inc/mangoblog/admin/tap_editorsettings.cfm">
	
	<script type="text/javascript" src="#temp#/assets/scripts/spry/xpath.js"></script>
	<script type="text/javascript" src="#temp#/assets/scripts/spry/SpryData.js"></script>
	
	<cfsavecontent variable="regex">^(https?|ftp):\/\/(((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:)*@)?(((\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5]))|((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)*(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?)(:\d*)?)(\/((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)+(\/(([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)*)*)?)?(\?((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|[\uE000-\uF8FF]|\/|\?)*)?(\##((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|\/|\?)*)?$</cfsavecontent>
	
	<script type="text/javascript">//<![CDATA[ 
		/*
		 * Admin functions for Mango Blog
		 * 
		 * Dependent on:
		 * 
		 * jQuery
		 * 		http://www.jquery.com
		 * 		Usage: http://docs.jquery.com
		 * 
		 * jQuery Validation plugin
		 * 		http://bassistance.de/jquery-plugins/jquery-plugin-validation/
		 * 		Usage: http://docs.jquery.com/Plugins/Validation
		 * 
		 * jQuery Metadata plugin (used for configuring validation rules)
		 * 		http://plugins.jquery.com/project/metadata
		 */
		
		
		$(function(){
			
			/*
			 * ==========================================================================
			 * For each field that has a hint, set up a help icon to show/hide the hint;
			 * and hide all hints on page load
			 */
			$('p,li','form').each(function(){
				var label = $(this).children('label');
				var hint = $(this).children('span.hint');
				if (hint.length) {
					hint.hide();
					$('<img src="#temp#/assets/images/icons/help.png" width="16" height="16" alt="" class="helpicon" />')
						.click(function(){
							hint.toggle();
						})
						.hover(function(){
							$(this).addClass('helpicon-over');
						},function(){
							$(this).removeClass('helpicon-over');					
						})
						.insertAfter(label);
				}
			});
			
			/*
			 * ==========================================================================
			 * Add a "required" text label to all required fields
			 */
			$('.required','form').each(function(){
				var id = $(this).attr('id');
				if (id.length) $('label[for='+id+']').append(' <span>(required)</span>');
			});
			
			/*
			 * ==========================================================================
			 * Set up a button to enable/disable rich text editing (TinyMCE)
			 */
			$('.htmlEditor','form').each(function(){
				var id = $(this).attr('id');
				var button = $('<span> <img src="#temp#/assets/images/icons/page_edit.png" width="16" height="16" alt="" title="Click to enable/disable the rich text editor" class="helpicon" /></span>')
					.click(function(){
						toggleEditor(id);
					});
				$(this).parents('span.field').siblings('label').after(button);
			});
			
			/*
			 * ==========================================================================
			 * If a form has more than one hint, add a button to show/hide all hints
			 */
			var hints = $('span.hint');
			if (hints.length > 1) {
				$('<span class="allhints"><img src="#temp#/assets/images/icons/help.png" width="16" height="16" alt="" class="helpicon" /> Show/hide all hints</span>')
				.click(function(){
					var hidden_hints = hints.filter(':hidden');
					if (hidden_hints.length) {
						hints.show();
					} else {
						hints.hide();
					}
				})
				.appendTo($('h2.pageTitle'));
			}
			
			
			/*
			 * ==========================================================================
			 * Set up delete confirmation
			 */
			$('.deleteButton').click(function(){
				return confirm('Are you sure you want to delete this item?');
			});
			
			/*
			 * ==========================================================================
			 * Initialise form validation
			 */
			var validator = $('form').submit(function() {
				// update underlying textarea before submit validation
				tinyMCE.triggerSave();
			}).validate({
				errorPlacement: function(error, element){
					error.appendTo(element.parents('p'));
				}
			});
			
			try {
				validator.focusInvalid = function(){
					// put focus on tinymce on submit validation
					if (this.settings.focusInvalid) {
						try {
							var toFocus = $(this.findLastActive() || this.errorList.length && this.errorList[0].element || []);
							if (toFocus.is("textarea.htmlEditor")) {
								tinyMCE.get(toFocus.attr("id")).focus();
							}
							else {
								toFocus.filter(":visible").focus();
							}
						} 
						catch (e) {
						// ignore IE throwing errors when focusing hidden elements
						}
					}
				}
			} catch (e) {}
			
			/*
			 * ==========================================================================
			 * Additional form validation method for URLs which allows domains such as 'localhost'
			 */
			
			jQuery.validator.addMethod("url2", function(value, element, param) {
				return this.optional(element) || /#trim(regex)#/i.test(value); 
			}, jQuery.validator.messages.url);
			
			/*
			 * ==========================================================================
			 * Additional form validation method for URL-safe page title
			 */
			jQuery.validator.addMethod("urlslug", function (value, element, param) { 
				 return this.optional(element) || /^[a-z0-9]+(-[a-z0-9]+)*$/.test(value); 
			}, "Please enter only a-z, 0-9 or -, not starting or ending with a -");
			
			/*
			 * ==========================================================================
			 * Update all form fields so they have a class matching their type, for styling in older browsers (IE6!)
			 */
			$('tr.plugin_head').hover(function(){
				$(this).children('th').addClass('hover');
			}, function(){
				$(this).children('th').removeClass('hover');		
			});
			
			/*
			 * ==========================================================================
			 * Update all form fields so they have a class matching their type, for styling in older browsers (IE6!)
			 */
			$('input','form').each(function(){
				$(this).addClass($(this).attr('type'));
			});
		});
		
		/*
		 * ==========================================================================
		 * Function to enable/disable tinyMCE rich text editing
		 */
		function toggleEditor(id) {
			if (!tinyMCE.getInstanceById(id))
				tinyMCE.execCommand('mceAddControl', false, id);
			else
				tinyMCE.execCommand('mceRemoveControl', false, id);
		} 
		
		// Mango Blog isn't very good about letting us specify where our images are, so we need to fix some of them 
		function tapFixImages() { 
			var lnk = null; 
			var img = document.getElementsByTagName('IMG'); 
			for (var i = 0; i < img.length; i++) { 
				var rex1 = new RegExp("^.*(skins/.*)$"); 
				var rex2 = new RegExp("^.*/_tap/.*$"); 
				
				if (img[i].src.search(rex1) >= 0 && img[i].src.search(rex2) < 0) { 
					img[i].src = img[i].src.replace(rex1,'#jsstringformat(getLib().getURL("mangoblog/","inc"))#$1'); 
				} 
			} 
			
			rex1 = new RegExp("^.*url\\((assets/images/.*)\\).*$"); 
			img = document.getElementById('adminmenu').getElementsByTagName('A'); 
			for (i = 0; i < img.length; i++) { 
				lnk = img[i]; 
				if (lnk.style.backgroundImage != null && lnk.style.backgroundImage.length > 0) { 
					lnk.style.backgroundImage = lnk.style.backgroundImage.replace(rex1,"url('#jsstringformat(getLib().getURL("mangoblog/admin/","inc"))#$1')"); 
				} 
			} 
		}
//]]></script>
	<mangoAdmin:Event name="beforeAdminHeaderEnd">

	<!--- run our function to fix image paths when the page loads --->
	<cf_load>tapFixImages();</cf_load>
</cfoutput>
