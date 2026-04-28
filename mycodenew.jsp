<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.dba.models.*" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>

<%
    dbsize sizeobj = (dbsize) request.getAttribute("sizeobj");
    List<fra> fraData = (List<fra>) request.getAttribute("fraData");
    instanceinfo instInfo = (instanceinfo) request.getAttribute("instInfo");
    String status = (String) request.getAttribute("status");
    if (status == null) status = "Ready";
%>

<!DOCTYPE html>
<html>
<head>
    <title>SBI DBA MONITORING TOOL</title>
    <style>
        body { margin: 0; font-family: 'Segoe UI', sans-serif; display: flex; height: 100vh; background: #f0f2f5; }
        
        /* Left Sidebar - Navigation Menu */
        .sidebar-nav { width: 240px; background: #2c3e50; color: white; display: flex; flex-direction: column; }
        .sidebar-header { padding: 20px; font-weight: bold; font-size: 18px; background: #1a252f; border-bottom: 1px solid #34495e; }
        .nav-category { padding: 15px 20px 5px; font-size: 12px; color: #95a5a6; text-transform: uppercase; }
        .nav-item { padding: 12px 30px; cursor: pointer; transition: 0.3s; font-size: 14px; color: #bdc3c7; text-decoration: none; display: block;}
        .nav-item:hover { background: #34495e; color: white; }
        .nav-item.active { background: #3498db; color: white; border-left: 4px solid #fff; }

        /* Main View Container */
        .view-container { flex: 1; display: flex; flex-direction: column; overflow: hidden; }

        /* Top Bar - Connection Controls */
        .top-bar { height: 70px; background: white; border-bottom: 1px solid #ddd; display: flex; align-items: center; padding: 0 25px; gap: 15px; }
        .top-bar select, .top-bar button { padding: 8px; border: 1px solid #ccc; border-radius: 4px; }
        .btn-connect { background: #27ae60; color: white; border: none !important; padding: 8px 20px !important; cursor: pointer; font-weight: bold; }
        
        /* Content Area */
        .content-body { padding: 25px; overflow-y: auto; flex: 1; }
        .card-row { display: flex; gap: 20px; margin-bottom: 25px; }
        .card { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); flex: 1; border-top: 4px solid #3498db; }
        .card h3 { margin: 0; color: #7f8c8d; font-size: 13px; text-transform: uppercase; }
        .card-val { font-size: 28px; font-weight: bold; margin: 10px 0; color: #2c3e50; }

        /* Table Styling */
        table { width: 100%; border-collapse: collapse; background: white; border-radius: 8px; overflow: hidden; }
        th { background: #f8f9fa; padding: 12px; text-align: left; border-bottom: 2px solid #dee2e6; color: #495057; font-size: 13px; }
        td { padding: 12px; border-bottom: 1px solid #eee; font-size: 14px; }
        tr:hover { background: #f1f4f7; }
        .status-dot { height: 10px; width: 10px; border-radius: 50%; display: inline-block; margin-right: 5px; }
    </style>
</head>
<body>

    <div class="sidebar-nav">
        <div class="sidebar-header">DBA TOOL v1.0</div>
        
        <div class="nav-category">Database Health</div>
        <a href="#" class="nav-item active">Stats / FRA</a>
        <a href="tablespaces.jsp" class="nav-item">Tablespaces</a>
        <a href="alertlogs.jsp" class="nav-item">Alert Logs</a>
        <a href="gglag.jsp" class="nav-item">GG Lag</a>

        <div class="nav-category">User Management</div>
        <a href="users.jsp" class="nav-item">All Users</a>
        <a href="sessions.jsp" class="nav-item">Active Sessions</a>
    </div>

    <div class="view-container">
        <div class="top-bar">
            <form action="fetchDashboard" method="get" style="display: flex; align-items: center; gap: 15px; margin: 0;">
                <label style="font-weight: bold; font-size: 13px;">SITE:</label>
                <select name="site">
                    <option value="PR">PR (Production)</option>
                    <option value="DR">DR (Disaster)</option>
                </select>

                <label style="font-weight: bold; font-size: 13px;">TARGET:</label>
                <select name="target">
                    <option value="MIDB">MIDB</option>
                    <option value="HIDB">HIDB</option>
                    <option value="SBISI">SBISI</option>
                    <option value="REPORT">REPORT</option>
                </select>

                <button type="submit" class="btn-connect">CONNECT</button>
            </form>
            <div style="margin-left: auto; font-size: 13px;">
                Status: <span style="color: <%= status.contains("Error") ? "red" : "#27ae60" %>; font-weight: bold;"><%= status %></span>
            </div>
        </div>

        <div class="content-body">
            
            <div class="card-row">
                <div class="card">
                    <h3>DB Total Size</h3>
                    <div class="card-val">
                        <%= (sizeobj != null) ? sizeobj.getSizeTb() + " TB" : "0.00 TB" %>
                    </div>
                </div>

                <div class="card">
                    <h3>Instance Details</h3>
                    <% if (instInfo != null) { %>
                        <div style="font-size: 14px; margin-top: 5px;">
                            <span class="status-dot" style="background: #27ae60;"></span>
                            <b><%= instInfo.getInstanceName() %></b> on <%= instInfo.getHostName() %><br>
                            <small>Started: <%= instInfo.getStartupTime() %></small>
                        </div>
                    <% } else { %>
                        <div style="color: #999;">Offline</div>
                    <% } %>
                </div>
            </div>

            <div class="card" style="border-top-color: #f39c12;">
                <h3>FRA Usage (Flash Recovery Area)</h3>
                <table style="margin-top: 15px;">
                    <thead>
                        <tr>
                            <th>NAME</th>
                            <th>LIMIT (MB)</th>
                            <th>USED (MB)</th>
                            <th>RECLAIMABLE</th>
                            <th>USAGE %</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (fraData != null) { 
                            for (fra f : fraData) { %>
                            <tr>
                                <td><b><%= f.getName() %></b></td>
                                <td><%= String.format("%.2f", (double) f.getSpacelimitmb()) %></td>
                                <td><%= String.format("%.2f", (double) f.getSpaceusedmb()) %></td>
                                <td><%= String.format("%.2f", (double) f.getSpacereclaimablemb()) %></td>
                                <td style="font-weight: bold; color: <%= (f.getPercentused() > 80) ? "#e74c3c" : "#2c3e50" %>">
                                    <%= f.getPercentused() %>%
                                </td>
                            </tr>
                        <% } } else { %>
                            <tr><td colspan="5" style="text-align: center; color: #95a5a6;">Connect to view FRA metrics</td></tr>
                        <% } %>
                    </tbody>
                </table>
            </div>

        </div>
    </div>
</body>
</html>
