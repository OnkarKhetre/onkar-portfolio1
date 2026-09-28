<%@ page import="java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String site = (String) request.getAttribute("site");
    
    String target = (String) request.getAttribute("target");
    
    String tableName = (String) request.getAttribute("tableName");
    
    String run = (String) request.getAttribute("run");
    
    String errorMsg = (String) request.getAttribute("errorMsg");
    
    String chartLabels = (String) request.getAttribute("chartLabels");
    
    String chartData = (String) request.getAttribute("chartData");
    
    String[][] dbList = (String[][]) request.getAttribute("dbList");

    String ctx = request.getContextPath();
    
    String selectedDb = "";
    
    if (site != null && target != null) {
        selectedDb = site + "|" + target;
    }
    
    if (tableName == null) {
        tableName = "";
    }
%>

<%!
    public String esc(Object value) {
        if (value == null) return "";
        return String.valueOf(value).replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
    
    public String selected(String actual, String expected) {
        return (actual != null && actual.equalsIgnoreCase(expected)) ? "selected" : "";
    }
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Table Growth Tracker - DBA Monitor</title>

<!-- Import Chart.js Library -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

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
    
    .page { padding: 24px; }
    
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
        border-radius: 11px; padding: 0 10px; outline: none; 
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
    
    .chart-container {
        position: relative;
        height: 500px;
        width: 100%;
        margin-top: 20px;
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
            <h1>Table Growth Tracker</h1>
            <div class="subtitle">Daily historical size mapping for critical tables</div>
        </div>
        <a class="back-link" href="<%= ctx %>/dashboard">← Back to Dashboard</a>
    </div>

    <% if (errorMsg != null) { %>
        <div class="error"><%= esc(errorMsg) %></div>
    <% } %>

    <div class="card">
        
        <form method="get" action="<%= ctx %>/tablegrowth" class="filter-row" onsubmit="return prepareDbSelection();">
            
            <input type="hidden" name="run" value="Y">
            <input type="hidden" name="site" id="siteInput" value="<%= esc(site) %>">
            <input type="hidden" name="target" id="targetInput" value="<%= esc(target) %>">
            
            <div>
                <label>Database</label>
                <select id="dbSelect" required>
                    <option value="">Select Database</option>
                    <% 
                        if (dbList != null) {
                            for (int i = 0; i < dbList.length; i++) {
                                String dbValue = dbList[i][0] + "|" + dbList[i][1];
                    %>
                                <option value="<%= esc(dbValue) %>" <%= selected(selectedDb, dbValue) %>>
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
                <input type="text" name="tableName" value="<%= esc(tableName) %>" placeholder="e.g. TRANSACTION_LOG" required>
            </div>
            
            <button type="submit">Generate Graph</button>
            
        </form>
    </div>

    <% if ("Y".equalsIgnoreCase(run) && chartLabels != null && !chartLabels.isEmpty()) { %>
        
        <div class="card">
            <h2>Growth Trend: <%= esc(tableName.toUpperCase()) %></h2>
            
            <div class="chart-container">
                <canvas id="growthChart"></canvas>
            </div>
            
        </div>

        <script>
            // This script physically draws the interactive chart
            var ctx = document.getElementById('growthChart').getContext('2d');
            
            var growthChart = new Chart(ctx, {
                type: 'line',
                data: {
                    // Injecting the dates from our Servlet here
                    labels: [<%= chartLabels %>], 
                    datasets: [{
                        label: 'Table Size (MB)',
                        // Injecting the megabyte sizes here
                        data: [<%= chartData %>],
                        borderColor: '#22d3ee',
                        backgroundColor: 'rgba(34, 211, 238, 0.2)',
                        borderWidth: 3,
                        pointBackgroundColor: '#fbbf24',
                        pointBorderColor: '#fff',
                        pointRadius: 5,
                        fill: true,
                        tension: 0.3 // Gives the line a nice smooth curve
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    scales: {
                        y: {
                            beginAtZero: false,
                            grid: { color: 'rgba(148,163,184,0.1)' },
                            ticks: { color: '#94a3b8' },
                            title: { display: true, text: 'Size in Megabytes (MB)', color: '#cbd5e1' }
                        },
                        x: {
                            grid: { color: 'rgba(148,163,184,0.1)' },
                            ticks: { color: '#94a3b8' }
                        }
                    },
                    plugins: {
                        legend: { labels: { color: '#e5eefb' } }
                    }
                }
            });
        </script>
        
    <% } %>

</div>

</body>
</html>
