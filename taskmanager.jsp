<%@ page import="java.util.*" %>
<%@ page import="com.dba.models.*" %>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>


<%

DrDatabaseInfo databaseInfo =
(DrDatabaseInfo)request.getAttribute("databaseInfo");


List<DrManagedProcessInfo> processList =
(List<DrManagedProcessInfo>)request.getAttribute("processList");


List<DrLagInfo> lagList =
(List<DrLagInfo>)request.getAttribute("lagList");


List<DrArchiveSequenceInfo> sequenceList =
(List<DrArchiveSequenceInfo>)request.getAttribute("sequenceList");


List<DrArchiveDestInfo> destList =
(List<DrArchiveDestInfo>)request.getAttribute("destList");


String[][] dbList =
(String[][])request.getAttribute("dbList");


String site =
(String)request.getAttribute("site");


String target =
(String)request.getAttribute("target");



if(processList==null)
processList=new ArrayList<>();

if(lagList==null)
lagList=new ArrayList<>();

if(sequenceList==null)
sequenceList=new ArrayList<>();

if(destList==null)
destList=new ArrayList<>();


%>



<!DOCTYPE html>

<html>


<head>


<title>DR Health Monitor</title>


<style>


body{

background:#071426;

font-family:Segoe UI;

color:white;

padding:25px;

}


h1{

font-size:30px;

}



.topbar{

display:flex;

justify-content:space-between;

margin-bottom:20px;

}



.card{

background:#10233b;

padding:20px;

border-radius:15px;

margin-bottom:20px;

border:1px solid #334155;

}



select,button{


height:38px;

padding:0 15px;

border-radius:8px;


}


select{

background:#020617;

color:white;

border:1px solid #475569;

}



button{


background:#22d3ee;

border:none;

font-weight:bold;

}



.back{


background:#334155;

padding:10px 15px;

border-radius:8px;

color:white;

text-decoration:none;

}



table{

width:100%;

border-collapse:collapse;

}


th{

background:#020617;

padding:12px;

text-align:left;

}



td{

padding:12px;

border-bottom:1px solid #334155;

}



.green{

color:#4ade80;

font-weight:bold;

}


.red{

color:#f87171;

font-weight:bold;

}



</style>


</head>



<body>




<div class="topbar">


<h1>
DR Health Monitor
</h1>



<a class="back"
href="<%=request.getContextPath()%>/dashboard">

← Back to Dashboard

</a>



</div>







<div class="card">


<form method="get"
action="<%=request.getContextPath()%>/drhealthmonitor">


<select name="db">


<option value="">
Select Database
</option>



<%

if(dbList!=null){


for(String[] db:dbList){


String value=db[0]+"|"+db[1];


boolean selected =
value.equals(site+"|"+target);



%>



<option value="<%=value%>"
<%=selected?"selected":""%>>


<%=db[0]%> - <%=db[1]%>


</option>


<%


}


}


%>


</select>




<button>

Check DR Health

</button>



</form>



</div>








<%

if(databaseInfo!=null){


%>



<div class="card">


<h2>Database Status</h2>



<table>


<tr>

<th>Role</th>
<th>Open Mode</th>
<th>Protection</th>
<th>Level</th>
<th>Switch Over</th>

</tr>


<tr>


<td>
<%=databaseInfo.getDatabaseRole()%>
</td>


<td>
<%=databaseInfo.getOpenMode()%>
</td>


<td>
<%=databaseInfo.getProtectionMode()%>
</td>


<td>
<%=databaseInfo.getProtectionLevel()%>
</td>


<td>
<%=databaseInfo.getSwitchoverStatus()%>
</td>


</tr>


</table>


</div>








<div class="card">


<h2>Managed Standby Process</h2>



<table>


<tr>

<th>Process</th>
<th>Status</th>
<th>Thread</th>
<th>Sequence</th>

</tr>



<%

for(DrManagedProcessInfo p:processList){

%>


<tr>

<td>
<%=p.getProcess()%>
</td>


<td class="green">
<%=p.getStatus()%>
</td>


<td>
<%=p.getThreadNo()%>
</td>


<td>
<%=p.getSequenceNo()%>
</td>


</tr>



<% } %>


</table>


</div>










<div class="card">


<h2>Data Guard Lag</h2>


<table>


<tr>

<th>Name</th>
<th>Value</th>
<th>Unit</th>

</tr>


<%


for(DrLagInfo l:lagList){


%>



<tr>


<td>
<%=l.getName()%>
</td>


<td>
<%=l.getValue()%>
</td>


<td>
<%=l.getUnit()%>
</td>


</tr>


<% } %>



</table>


</div>









<div class="card">


<h2>Archive Sequence Gap</h2>


<table>


<tr>

<th>Thread</th>
<th>Received</th>
<th>Applied</th>
<th>Gap</th>

</tr>



<%

for(DrArchiveSequenceInfo s:sequenceList){


%>


<tr>


<td>
<%=s.getThreadNo()%>
</td>


<td>
<%=s.getReceivedSeq()%>
</td>


<td>
<%=s.getAppliedSeq()%>
</td>



<td>


<%

if(s.getGap()>0){

%>


<span class="red">
<%=s.getGap()%>
</span>


<%

}else{

%>


<span class="green">
0
</span>


<%

}

%>


</td>


</tr>



<% } %>


</table>


</div>









<div class="card">


<h2>Archive Destination</h2>


<table>


<tr>

<th>ID</th>
<th>Status</th>
<th>Type</th>
<th>Error</th>

</tr>



<%

for(DrArchiveDestInfo d:destList){


%>



<tr>


<td>
<%=d.getDestId()%>
</td>


<td class="green">
<%=d.getStatus()%>
</td>


<td>
<%=d.getType()%>
</td>


<td>
<%=d.getError()%>
</td>



</tr>



<% } %>



</table>


</div>



<%


}

else{


%>


<div class="card">

Select database and click Check DR Health

</div>


<%


}


%>



</body>


</html>