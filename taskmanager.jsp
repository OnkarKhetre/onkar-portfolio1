<%@ page import="java.util.*" %>
<%@ page import="com.dba.models.TableConfig" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String site = (String) request.getAttribute("site");
    String target = (String) request.getAttribute("target");
    String tableName = (String) request.getAttribute("tableName");
    String startDate = (String) request.getAttribute("startDate");
    String endDate = (String) request.getAttribute("endDate");
    String run = (String) request.getAttribute("run");
    String errorMsg = (String) request.getAttribute("errorMsg");
    String chartLabels = (String) request.getAttribute("chartLabels");
    String chartData = (String) request.getAttribute("chartData");
    String incrementStr = (String) request.getAttribute("incrementStr");
    String statusColor = (String) request.getAttribute("statusColor");
    String[][] dbList = (String[][]) request.getAttribute("dbList");
    List<TableConfig> trackedTables = (List<TableConfig>) request.getAttribute("trackedTables");

    if (trackedTables == null) trackedTables = new ArrayList<TableConfig>();
    String ctx = request.getContextPath();
    String selectedDb = (site != null && target != null) ? site + "|" + target : "";
    if (tableName == null) tableName = "";
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
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<style>
    * { box-sizing: border-box; }
    body { 
        margin: 0; font-family: "Segoe UI", Arial, sans-serif; min-height: 100vh; 
        background: radial-gradient(circle at top left, rgba(34,211,238,.14), transparent 32%), 
                    linear-gradient(135deg, #08111f, #102033); 
        color: #e5eefb; 
    }
    .page { padding: 24px; max-width: 1400px; margin: 0 auto; }
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
        border-radius: 20px; padding: 24px; margin-bottom: 18px; 
        box-shadow: 0 18px 50px rgba(0,0,0,.28); 
    }
    .filter-row { display: flex; align-items: end; gap: 12px; flex-wrap: wrap; }
    label { display: block; font-size: 11px; color: #94a3b8; font-weight: 900; text-transform: uppercase; margin-bottom: 6px; letter-spacing: 0.5px; }
    select, input[type="text"], input[type="date"] { 
        height: 42px; border: 1px solid rgba(148,163,184,.30); 
        background: rgba(2,6,23,.58); color: #e5eefb; font-family: inherit;
        border-radius: 11px; padding: 0 14px; outline: none; transition: 0.2s;
    }
    select:focus, input[type="date"]:focus { border-color: #22d3ee; }
    button { 
        height: 42px; border: none; border-radius: 11px; 
        background: linear-gradient(135deg, #22d3ee, #0ea5e9); color: #0f172a; 
        font-weight: 900; padding: 0 20px; cursor: pointer; transition: 0.3s;
    }
    button:hover { transform: translateY(-2px); box-shadow: 0 4px 15px rgba(34,211,238,0.4); }
    .error { 
        background: rgba(239,68,68,.16); border: 1px solid rgba(239,68,68,.35); 
        color: #fecaca; padding: 12px; border-radius: 13px; margin-bottom: 14px; font-weight: 800; 
    }
    
    /* Premium Increment Display styling */
    .dashboard-grid { display: grid; grid-template-columns: 1fr 300px; gap: 18px; margin-top: 20px; }
    .chart-container { position: relative; height: 500px; width: 100%; }
    .metric-card { 
        background: rgba(2,6,23,.4); border: 1px solid rgba(148,163,184,.15); 
        border-radius: 16px; padding: 24px; display: flex; flex-direction: column; 
        justify-content: center; align-items: center; text-align: center;
    }
    .metric-title { font-size: 14px; color: #94a3b8; text-transform: uppercase; font-weight: 900; letter-spacing: 1px; margin-bottom: 12px; }
    .metric-value { font-size: 38px; font-weight: 900; color: #fff; text-shadow: 0 0 20px rgba(255,255,255,0.2); }
    .metric-subtitle { font-size: 13px; color: #64748b; margin-top: 10px; }
</style>

<script>
    function filterTables() {
        var dbSelect = document.getElementById("dbSelect");
        var tableSelect = document.getElementById("tableSelect");
        if (!dbSelect || !tableSelect) return;
        
        var selectedDbString = dbSelect.value;
        var selectedTarget = selectedDbString.split("|")[1];
        var options = tableSelect.getElementsByTagName("option");
        
        for (var i = 0; i < options.length; i++) {
            var opt = options[i];
            var optDb = opt.getAttribute("data-db");
            if (!optDb || optDb === selectedTarget) {
                opt.style.display = "";
            } else {
                opt.style.display = "none";
            }
        }
    }

    window.onload = function() {
        var dbSelect = document.getElementById("dbSelect");
        if (dbSelect) {
            dbSelect.addEventListener("change", filterTables);
            filterTables();
        }
    };
    
    function prepareDbSelection() {
        var dbSelect = document.getElementById("dbSelect");
        var siteInput = document.getElementById("siteInput");
        var targetInput = document.getElementById("targetInput");
        if (!dbSelect.value) { alert("Please select database."); return false; }
        var parts = dbSelect.value.split("|");
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
            <div class="subtitle">Time-series volume forecasting & analytics</div>
        </div>
        <a class="back-link" href="<%= ctx %>/dashboard">← Back</a>
    </div>

    <% if (errorMsg != null) { %> <div class="error"><%= esc(errorMsg) %></div> <% } %>

    <div class="card">
        <form method="get" action="<%= ctx %>/tablegrowth" class="filter-row" onsubmit="return prepareDbSelection();">
            <input type="hidden" name="run" value="Y">
            <input type="hidden" name="site" id="siteInput" value="<%= esc(site) %>">
            <input type="hidden" name="target" id="targetInput" value="<%= esc(target) %>">
            
            <div>
                <label>Target DB</label>
                <select id="dbSelect" required>
                    <option value="">Select Database</option>
                    <% if (dbList != null) {
                        for (int i = 0; i < dbList.length; i++) {
                            String dbValue = dbList[i][0] + "|" + dbList[i][1]; %>
                            <option value="<%= esc(dbValue) %>" <%= selected(selectedDb, dbValue) %>>
                                <%= esc(dbList[i][0]) %>-<%= esc(dbList[i][1]) %>
                            </option>
                    <% } } %>
                </select>
            </div>
            
            <div>
                <label>Tracked Table</label>
                <select name="tableName" id="tableSelect" required>
                    <option value="">Select Table</option>
                    <% for (TableConfig tc : trackedTables) { %>
                        <option value="<%= esc(tc.getTableName()) %>" data-db="<%= esc(tc.getTargetDb()) %>" <%= selected(tableName, tc.getTableName()) %>>
                            <%= esc(tc.getTableName()) %>
                        </option>
                    <% } %>
                </select>
            </div>

            <div>
                <label>From Date</label>
                <input type="date" name="startDate" value="<%= esc(startDate) %>" required>
            </div>
            
            <div>
                <label>To Date</label>
                <input type="date" name="endDate" value="<%= esc(endDate) %>" required>
            </div>
            
            <button type="submit">Analyze Trend</button>
        </form>
    </div>

    <% if ("Y".equalsIgnoreCase(run) && chartLabels != null && !chartLabels.isEmpty()) { %>
        
        <div class="card">
            <h2 style="margin-top: 0; font-size: 22px; color: #e2e8f0;">Growth Analytics: <span style="color: #22d3ee;"><%= esc(tableName.toUpperCase()) %></span></h2>
            
            <div class="dashboard-grid">
                
                <!-- The Premium Chart -->
                <div class="chart-container">
                    <canvas id="growthChart"></canvas>
                </div>
                
                <!-- The Increment Dashboard Card -->
                <div class="metric-card">
                    <div class="metric-title">Volume Shift</div>
                    <div class="metric-value" style="color: <%= statusColor %>;">
                        <%= incrementStr %>
                    </div>
                    <div class="metric-subtitle">
                        Change between <%= esc(startDate) %> and <%= esc(endDate) %>
                    </div>
                </div>

            </div>
        </div>

        <script>
            var ctx = document.getElementById('growthChart').getContext('2d');
            
            // Create a glowing gradient for the fill under the line
            var gradient = ctx.createLinearGradient(0, 0, 0, 400);
            gradient.addColorStop(0, 'rgba(34, 211, 238, 0.5)');
            gradient.addColorStop(1, 'rgba(34, 211, 238, 0.0)');

            var growthChart = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: [<%= chartLabels %>], 
                    datasets: [{
                        label: 'Table Size (TB)',
                        data: [<%= chartData %>],
                        borderColor: '#22d3ee',
                        backgroundColor: gradient,
                        borderWidth: 3,
                        pointBackgroundColor: '#0f172a',
                        pointBorderColor: '#22d3ee',
                        pointBorderWidth: 2,
                        pointRadius: 4,
                        pointHoverRadius: 7,
                        pointHoverBackgroundColor: '#22d3ee',
                        fill: true,
                        tension: 0.4 // Creates a premium, smooth bezier curve
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    interaction: {
                        mode: 'index',
                        intersect: false,
                    },
                    plugins: {
                        legend: { display: false },
                        tooltip: {
                            backgroundColor: 'rgba(15, 23, 42, 0.9)',
                            titleColor: '#94a3b8',
                            bodyColor: '#fff',
                            bodyFont: { size: 14, weight: 'bold' },
                            borderColor: 'rgba(34, 211, 238, 0.3)',
                            borderWidth: 1,
                            padding: 12,
                            displayColors: false,
                            callbacks: {
                                label: function(context) {
                                    return context.parsed.y + ' TB';
                                }
                            }
                        }
                    },
                    scales: {
                        y: {
                            grid: { color: 'rgba(148,163,184,0.05)', drawBorder: false },
                            ticks: { 
                                color: '#64748b',
                                font: { size: 11, family: "'Segoe UI', sans-serif" },
                                callback: function(value) { return value + ' TB'; }
                            }
                        },
                        x: {
                            grid: { display: false },
                            ticks: { color: '#64748b', font: { size: 11 } }
                        }
                    }
                }
            });
        </script>
        
    <% } %>

</div>
</body>
</html>
