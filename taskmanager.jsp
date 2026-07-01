<%@ page import="java.util.*" %>
<%@ page import="com.dba.models.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    DrDatabaseInfo databaseInfo =
            (DrDatabaseInfo) request.getAttribute("databaseInfo");

    List<DrManagedProcessInfo> processList =
            (List<DrManagedProcessInfo>) request.getAttribute("processList");

    List<DrLagInfo> lagList =
            (List<DrLagInfo>) request.getAttribute("lagList");

    List<DrArchiveSequenceInfo> sequenceList =
            (List<DrArchiveSequenceInfo>) request.getAttribute("sequenceList");

    List<DrArchiveDestInfo> destList =
            (List<DrArchiveDestInfo>) request.getAttribute("destList");


    String[][] dbList =
            (String[][]) request.getAttribute("dbList");


    String site =
            (String) request.getAttribute("site");

    String target =
            (String) request.getAttribute("target");


    String run =
            (String) request.getAttribute("run");


    String errorMsg =
            (String) request.getAttribute("errorMsg");


    if(processList==null)
        processList=new ArrayList<>();

    if(lagList==null)
        lagList=new ArrayList<>();

    if(sequenceList==null)
        sequenceList=new ArrayList<>();

    if(destList==null)
        destList=new ArrayList<>();


    if(site==null)
        site="";

    if(target==null)
        target="";

%>



<!DOCTYPE html>

<html>

<head>

<title>DR Health Monitor</title>


<style>

body{

    margin:0;
    padding:25px;

    font-family:"Segoe UI",Arial;

    background:
    linear-gradient(135deg,#07111f,#13253b);

    color:#e5eefb;

}



h1{

    font-size:32px;
    margin-bottom:5px;

}


.subtitle{

    color:#94a3b8;
    margin-bottom:20px;

}



.card{

    background:rgba(15,23,42,.85);

    border:1px solid rgba(148,163,184,.25);

    border-radius:18px;

    padding:18px;

    margin-bottom:18px;

}



select,input{

    height:38px;

    background:#020617;

    color:white;

    border:1px solid #334155;

    border-radius:8px;

    padding:0 10px;

}



button{

    height:38px;

    background:#22d3ee;

    border:none;

    border-radius:8px;

    padding:0 18px;

    font-weight:bold;

    cursor:pointer;

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



.badge{

    padding:5px 10px;

    border-radius:20px;

    font-weight:bold;

}



.good{

    background:#14532d;

    color:#86efac;

}



.bad{

    background:#7f1d1d;

    color:#fecaca;

}



.normal{

    background:#1e293b;

    color:#cbd5e1;

}


.error{

    background:#7f1d1d;

    padding:12px;

    border-radius:10px;

}


.empty{

    text-align:center;

    color:#94a3b8;

    padding:20px;

}


</style>



</head>



<body>



<h1>DR Health Monitor</h1>

<div class="subtitle">
Data Guard status, MRP, lag and archive health
</div>



<% if(errorMsg!=null){ %>

<div class="error">
<%=errorMsg%>
</div>

<% } %>




<div class="card">


<form method="get"
action="<%=request.getContextPath()%>/drhealthmonitor">


<input type="hidden"
name="run"
value="Y">


<select id="dbSelect"
onchange="setDb()">



<option value="">
Select Database
</option>


<%

if(dbList!=null){

for(int i=0;i<dbList.length;i++){


String value =
dbList[i][0]+"|"+dbList[i][1];

%>


<option value="<%=value%>">

<%=dbList[i][0]%>-<%=dbList[i][1]%>

</option>


<%

}

}

%>


</select>



<input type="hidden"
name="site"
id="site">


<input type="hidden"
name="target"
id="target">


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
<th>Protection Mode</th>
<th>Protection Level</th>
<th>Switchover</th>


</tr>



<tr>


<td>

<span class="badge good">

<%=databaseInfo.getDatabaseRole()%>

</span>

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


<h2>Managed Standby Processes</h2>



<table>


<tr>

<th>Process</th>
<th>Status</th>
<th>Thread</th>
<th>Sequence</th>
<th>Client</th>


</tr>



<%

for(DrManagedProcessInfo p:processList){

%>


<tr>

<td><%=p.getProcess()%></td>

<td>

<span class="badge good">

<%=p.getStatus()%>

</span>

</td>


<td><%=p.getThreadNo()%></td>

<td><%=p.getSequenceNo()%></td>

<td><%=p.getClientProcess()%></td>


</tr>


<%

}

%>


</table>


</div>







<div class="card">


<h2>Data Guard Lag</h2>


<table>


<tr>

<th>Name</th>
<th>Value</th>
<th>Unit</th>
<th>Time</th>


</tr>



<%

for(DrLagInfo l:lagList){

%>


<tr>


<td><%=l.getName()%></td>

<td><%=l.getValue()%></td>

<td><%=l.getUnit()%></td>

<td><%=l.getTimeComputed()%></td>


</tr>


<%

}

%>


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


<td><%=s.getThreadNo()%></td>

<td><%=s.getReceivedSeq()%></td>

<td><%=s.getAppliedSeq()%></td>


<td>


<%

if(s.getGap()>0){

%>


<span class="badge bad">

<%=s.getGap()%>

</span>


<%

}else{

%>


<span class="badge good">

0

</span>


<%

}

%>



</td>


</tr>



<%

}

%>


</table>


</div>








<div class="card">


<h2>Archive Destination Status</h2>


<table>


<tr>

<th>Dest ID</th>
<th>Status</th>
<th>Type</th>
<th>Recovery Mode</th>
<th>Error</th>


</tr>




<%

for(DrArchiveDestInfo d:destList){

%>



<tr>


<td><%=d.getDestId()%></td>


<td>


<span class="badge good">

<%=d.getStatus()%>

</span>


</td>


<td><%=d.getType()%></td>


<td><%=d.getRecoveryMode()%></td>


<td><%=d.getError()%></td>



</tr>



<%

}

%>


</table>


</div>



<%

}

else{

%>


<div class="card empty">

Select database and click Check DR Health

</div>


<%

}

%>





<script>


function setDb(){


let val =
document.getElementById("dbSelect").value;


if(val!=""){


let arr=val.split("|");


document.getElementById("site").value=arr[0];


document.getElementById("target").value=arr[1];


}



}


</script>




</body>

</html>