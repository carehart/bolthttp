<cfparam name="reporter" default="simple">
<cfoutput><h1>Bolt HTTP Tests</h1></cfoutput>
<cfif reporter IS "simple">
	<style>
	.pass { background-color:#DFF0D8; padding: 10px; }
	.fail { background-color: #F2DEDE;  padding: 10px;}
	</style>
</cfif>
<cfset json = fileRead(expandPath("./test-data.json"))>
<cfset data = deserializeJSON(json)>
<div>
	<cfoutput>
		<cfif structKeyExists(server, "coldfusion") AND structKeyExists(server.coldfusion, "productname") AND server.coldfusion.productname contains "ColdFusion">
			ColdFusion #server.coldfusion.productlevel# Edition #server.coldfusion.productversion#
		<cfelseif structKeyExists(server, "lucee")>
			Lucee #server.lucee.version#
		<cfelse>
			<cfdump var="#server#" label="Server Info">
		</cfif>
		<cfset system = CreateObject("java", "java.lang.System")>
		Java: #htmlEditFormat(system.getProperty("java.version"))#
	</cfoutput>
</div>
<cfloop array="#data#" index="test">
	<cfif NOT structKeyExists(test, "method")>
		<cfset test.method = "GET">
	</cfif>
	<cfoutput><h3>#htmlEditFormat(test.title)#</h3><div><small>#htmlEditFormat(test.method)# <a href="#xmlFormat(test.url)#">#htmlEditFormat(test.url)#</a></small></div></cfoutput><cfif cgi.script_name contains "tls-tests.cfm"><cfflush></cfif>
	<cfset threw = false>
	<cfset exception = "">
	<cfset result = "">
	<cfset test.pass = false>
	<cftry>
		<cfset bolt = new bolthttp.bolthttp()>
		<cfset result = bolt.request(test.url, test.method)>
		<cfcatch type="any">
			<cfset threw = true>
			<cfset exception = duplicate(cfcatch)>
		</cfcatch>
	</cftry>
	
	<cfif NOT threw>
		<cfif isNumeric(test.expect)>
			<cfif result.status EQ test.expect>
				<cfset test.pass = true>
			</cfif>
		</cfif>
	<cfelseif test.expect IS "exception">
		<cfset test.pass = true>
	</cfif>
	<cfoutput>
		<cfif test.pass>
			<div class="pass"><strong>OK:</strong>
		<cfelse>
			<div class="fail"><strong>FAIL:</strong>
		</cfif>	
	
		Expected #test.expect# 
		<cfif threw>
			got exception: <em>#htmlEditFormat(exception.message)#</em>
			<cfif reporter IS "simple"><cfdump var="#exception#" label="Exception" expand="false"></cfif>
		<cfelseif isNumeric(test.expect)>
			#htmlEditFormat(result.status)#
		</cfif> 
		<cfif NOT isSimpleValue(result)>
			got result: <cfif structKeyExists(result, "statuscode")>#htmlEditFormat(result.statuscode)#</cfif>
			<cfif reporter IS "simple"><cfdump var="#result#" expand="false" label="HTTP Response"></cfif>
		</cfif>
	</cfoutput>
	</div>

</cfloop>