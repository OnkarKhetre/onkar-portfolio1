<%@ page import="java.util.*" %>
<%@ page import="com.dba.models.TableConfig" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String errorMsg = (String) request.getAttribute("errorMsg");
    
    String successMsg = (String) request.getAttribute("successMsg");
    
    List<TableConfig> trackedTables = (List<TableConfig>) request.getAttribute("trackedTables");
    
    String[][] dbList = (String[][]) request.getAttribute("dbList");

    if (trackedTables == null) {
        trackedTables = new ArrayList<TableConfig>();
    }

    String ctx = request.getContextPath();
%>

<%!
    public String esc(Object value) {
        if (value == null) return "";
        return String.valueOf(value).replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Tracker Configuration - DBA Monitor</title>

<style>
    * { box-sizing: border-box; }
    
    body { 
        margin: 0; 
        font-family: "Segoe UI", Arial, sans-serif; 
        min-height: 100vh; 
        background: radial-gradient(circle at top left, rgba(34,211,238,.14), transparent 32%), 
                    linear-gradient(135deg, #08111f, #102033); 
        color: #e5eefb; 
    }
    
    .page { padding: 24px; max-width: 1200px; margin: 0 auto; }
    
    .topbar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 18px; }
    
    h1 { margin: 0; font-size: 30px; font-weight: 900; }
    
    .subtitle { margin-top: 6px; color: #94a3b8; font-size: 14px; font-weight: 600; }
    
    .back-link { 
        color: #22d3ee; text-decoration: none; font-weight: 900; 
        background: rgba(34,211,238,.12); border: 1px solid rgba(34,211,238,.25); 
        padding: 10px 14px; border-radius: 12px; 
    }
    
    .card { 
        background: rgba(15,23,42,.80); border: 1px solid rgba(148,163,184,.22); 
        border-radius: 20px; padding: 18px; margin-bottom: 18px; 
        box-shadow: 0 18px 50px rgba(0,0,0,.28); 
    }
    
    .filter-row { display: flex; align-items: end; gap: 12px; flex-wrap: wrap; }
    
    label { display: block; font-size: 12px; color: #cbd5e1; font-weight: 900; text-transform: uppercase; margin-bottom: 6px; }
    
    select, input[type="text"] { 
        height: 40px; border: 1px solid rgba(148,163,184,.30); 
        background: rgba(2,6,23,.58); color: #e5eefb; 
        border-radius: 11px; padding: 0 10px; outline: none; width: 250px;
    }
    
    button { 
        height: 40px; border: none; border-radius: 11px; 
        background: #22d3ee; color: #06202a; font-weight: 900; 
        padding: 0 16px; cursor: pointer; 
    }
    
    button:hover { filter: brightness(1.08); }
    
    .error { 
        background: rgba(239,68,68,.16); border: 1px solid rgba(239,68,68,.35); 
        color: #fecaca; padding: 12px; border-radius: 13px; 
        margin-bottom: 14px; font-weight: 800; 
    }
    
    .success { 
        background: rgba(34,197,94,.16); border: 1px solid rgba(34,197,94,.35); 
        color: #bbf7d0; padding: 12px; border-radius: 13px; 
        margin-bottom: 14px; font-weight: 800; 
    }
    
    table { width: 100%; border-collapse: collapse; margin-top: 15px; }
    
    th { text-align: left; padding: 12px; border-bottom: 2px solid rgba(148,163,184,.22); color: #94a3b8; font-size: 13px; text-transform: uppercase; }
    
    td { padding: 12px; border-bottom: 1px solid rgba(148,163,184,.12); font-size: 14px; }
    
    tr:hover { background: rgba(34,211,238,.05); }
    
    .badge-normal { 
        background: rgba(148,163,184,.18); color: #cbd5e1; 
        padding: 4px 8px; border-radius: 8px; font-size: 12px; font-weight: bold;
    }
</style>

<script>
    function prepareDbSelection() {
        
        var dbSelect = document.getElementById("dbSelect");
        var siteInput = document.getElementById("siteInput");
        var targetInput = document.getElementById("targetInput");
        
        if (!dbSelect || !dbSelect.value) { 
            alert("Please select database."); 
            return false; 
        }
        
        var parts = dbSelect.value.split("|");
        
        if (parts.length !== 2) { 
            alert("Invalid database selection."); 
            return false; 
        }
        
        siteInput.value = parts[0];
        targetInput.value = parts[1];
        
        return true;
    }
</script>
</head>

<body>
<div class="page">
    
    <div class="topbar">
        <div>
            <h1>Tracker Configuration</h1>
            <div class="subtitle">Add tables to the automated nightly growth tracking system</div>
        </div>
        <a class="back-link" href="<%= ctx %>/dashboard">← Back to Dashboard</a>
    </div>

    <% if (errorMsg != null) { %>
        <div class="error"><%= esc(errorMsg) %></div>
    <% } %>
    
    <% if (successMsg != null) { %>
        <div class="success"><%= esc(successMsg) %></div>
    <% } %>

    <!-- Add New Table Form -->
    <div class="card">
        <h2>Add Table to Monitor</h2>
        
        <form method="post" action="<%= ctx %>/tableconfig" class="filter-row" onsubmit="return prepareDbSelection();">
            
            <input type="hidden" name="site" id="siteInput" value="">
            <input type="hidden" name="target" id="targetInput" value="">
            
            <div>
                <label>Target Database</label>
                <select id="dbSelect" required>
                    <option value="">Select Database</option>
                    <% 
                        if (dbList != null) {
                            for (int i = 0; i < dbList.length; i++) {
                                String dbValue = dbList[i][0] + "|" + dbList[i][1];
                    %>
                                <option value="<%= esc(dbValue) %>">
                                    <%= esc(dbList[i][0]) %>-<%= esc(dbList[i][1]) %>
                                </option>
                    <% 
                            } 
                        } 
                    %>
                </select>
            </div>
            
            <div>
                <label>Table Name</label>
                <input type="text" name="tableName" placeholder="e.g. AUDIT_LOGS" required>
            </div>
            
            <button type="submit">Start Tracking</button>
            
        </form>
    </div>

    <!-- Currently Tracked Tables Grid -->
    <div class="card">
        <h2>Currently Tracked Tables</h2>
        
        <% if (trackedTables.isEmpty()) { %>
            <div style="color: #94a3b8; padding: 15px 0;">No tables are currently being monitored. Add one above!</div>
        <% } else { %>
            
            <table>
                <thead>
                    <tr>
                        <th>Database</th>
                        <th>Table Name</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (TableConfig table : trackedTables) { %>
                        <tr>
                            <td>
                                <b><%= esc(table.getTargetDb()) %></b>
                                <span style="font-size: 11px; color: #94a3b8; margin-left: 5px;">(<%= esc(table.getSite()) %>)</span>
                            </td>
                            <td style="font-family: Consolas, monospace; color: #fde68a;">
                                <%= esc(table.getTableName()) %>
                            </td>
                            <td>
                                <span class="badge-normal">Active</span>
                            </td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
            
        <% } %>
        
    </div>

</div>
</body>
</html>
