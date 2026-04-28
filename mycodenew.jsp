<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.dba.models.*" %>
<%@ page import="java.util.List" %>

<%
    // Retrieve data passed from DashboardServlet
    dbsize sizeObj = (dbsize) request.getAttribute("dbSizeData");
    List<fra> fraList = (List<fra>) request.getAttribute("fraData");
    instanceinfo inst = (instanceinfo) request.getAttribute("instanceData");
    String status = (String) request.getAttribute("status");
    
    if (status == null) status = "Ready to connect";
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>DBA Dashboard</title>
    <style>
        /* CSS mimicking standard JavaFX Desktop Application */
        body {
            margin: 0;
            padding: 0;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f4f4f4; /* Light gray app background */
            color: #333;
        }

        .header-bar {
            background-color: #2c3e50; /* Dark blue/gray header */
            color: white;
            padding: 12px 20px;
            font-size: 18px;
            font-weight: bold;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .app-container {
            display: flex;
            height: calc(100vh - 45px); /* Full height minus header */
        }

        /* Sidebar Controls */
        .sidebar {
            width: 260px;
            background-color: #e9e9e9; /* JavaFX standard gray */
            border-right: 1px solid #ccc;
            padding: 20px;
            box-sizing: border-box;
        }

        .sidebar label {
            display: block;
            margin-bottom: 5px;
            font-size: 14px;
            font-weight: bold;
            color: #444;
        }

        .sidebar select {
            width: 100%;
            padding: 6px;
            margin-bottom: 20px;
            border: 1px solid #aaa;
            border-radius: 3px;
            background-color: white;
            font-size: 14px;
        }

        .sidebar button {
            width: 100%;
            padding: 8px;
            background-color: #e0e0e0;
            border: 1px solid #999;
            border-radius: 3px;
            cursor: pointer;
            font-size: 14px;
            font-weight: bold;
        }

        .sidebar button:hover {
            background-color: #d4d4d4;
        }

        .status-box {
            margin-top: 30px;
            padding-top: 15px;
            border-top: 1px solid #ccc;
            font-size: 14px;
        }

        /* Main Content Area */
        .main-content {
            flex-grow: 1;
            padding: 20px;
            overflow-y: auto;
        }

        .top-cards {
            display: flex;
            gap: 20px;
            margin-bottom: 20px;
        }

        .card {
            background-color: white;
            border: 1px solid #ccc;
            border-radius: 3px;
            padding: 15px;
            flex: 1;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
        }

        .card h3 {
            margin: 0 0 10px 0;
            font-size: 14px;
            color: #666;
            border-bottom: 1px solid #eee;
            padding-bottom: 5px;
            text-transform: uppercase;
        }

        .card-value {
            font-size: 28px;
            font-weight: bold;
            color: #2c3e50;
        }

        .card-row {
            font-size: 14px;
            margin-bottom: 5px;
        }
        .card-row span {
            font-weight: bold;
            color: #000;
        }

        /* JavaFX Style Table */
        .table-container {
            background-color: white;
            border: 1px solid #ccc;
            border-radius: 3px;
            padding: 15px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
        }

        table {
            width: 100%;
            border-collapse: collapse;
            font-size: 14px;
            margin-top: 10px;
        }

        th, td {
            border: 1px solid #ddd;
            padding: 8px 12px;
            text-align: left;
        }

        th {
            background-color: #f5f5f5;
            color: #333;
            font-weight: bold;
        }

        tr:nth-child(even) {
            background-color: #fafafa;
        }
        
        tr:hover {
            background-color: #f0f8ff; /* Light blue highlight on hover */
        }

    </style>
</head>
<body>

    <div class="header-bar">
        DBA DASHBOARD
    </div>

    <div class="app-container">
        
        <div class="sidebar">
            <form action="fetchDashboard" method="get">
                <label>Select Site:</label>
                <select name="site">
                    <option value="PR">PRODUCTION (PR)</option>
                    <option value="DR">DR SITE</option>
                </select>

                <label>Select Target:</label>
                <select name="target">
                    <option value="MIDB">MIDB</option>
                    <option value="HIDB">HIDB</option>
                    <option value="SBISI">SBISI</option>
                    <option value="REPORT">REPORT</option>
                    <option value="ARCHIVE">ARCHIVE</option>
                </select>

                <button type="submit">Connect</button>
            </form>
            
            <div class="status-box">
                <label>Status:</label>
                <div style="color: <%= status.contains("Error") ? "red" : "green" %>; font-weight: bold; margin-top: 5px;">
                    <%= status %>
                </div>
            </div>
        </div>

        <div class="main-content">
            
            <div class="top-cards">
                <div class="card">
                    <h3>Total DB Size</h3>
                    <div class="card-value">
                        <%= (sizeObj != null) ? sizeObj.getDbsize() + " " + sizeObj.getUnit() : "0.00 TB" %>
                    </div>
                </div>

                <div class="card">
                    <h3>Instance Info</h3>
                    <% if (inst != null) { %>
                        <div class="card-row">Name: <span><%= inst.getInstanceName() %></span></div>
                        <div class="card-row">Host: <span><%= inst.getHostName() %></span></div>
                        <div class="card-row">Status: <span><%= inst.getStatus() %></span></div>
                        <div class="card-row">Uptime: <span><%= inst.getStartupTime() %></span></div>
                    <% } else { %>
                        <div class="card-value" style="font-size: 18px; color: #999;">No Instance Connected</div>
                    <% } %>
                </div>
            </div>

            <div class="table-container">
                <h3 style="margin: 0 0 10px 0; font-size: 14px; color: #666; text-transform: uppercase;">FRA Usage</h3>
                <table>
                    <thead>
                        <tr>
                            <th>Name</th>
                            <th>Limit (MB)</th>
                            <th>Used (MB)</th>
                            <th>Reclaimable (MB)</th>
                            <th>Usage %</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (fraList != null && !fraList.isEmpty()) { 
                            for (fra f : fraList) { %>
                            <tr>
                                <td><%= f.getName() %></td>
                                <td><%= String.format("%.2f", f.getSpacelimitmb()) %></td>
                                <td><%= String.format("%.2f", f.getSpaceusedmb()) %></td>
                                <td><%= String.format("%.2f", f.getSpacereclaimablemb()) %></td>
                                <td><%= f.getPercentused() %>%</td>
                            </tr>
                        <% } 
                        } else { %>
                            <tr><td colspan="5" style="text-align: center; color: #999;">No data available. Click Connect.</td></tr>
                        <% } %>
                    </tbody>
                </table>
            </div>

        </div>
    </div>

</body>
</html>
