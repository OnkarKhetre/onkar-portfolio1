<%@ page import="java.util.*" %>
<%@ page import="com.dba.models.TaskPerformance" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    List<TaskPerformance> performanceList =
            (List<TaskPerformance>) request.getAttribute("performanceList");

    List<String> users = (List<String>) request.getAttribute("users");

    String fromDate = (String) request.getAttribute("fromDate");
    String toDate = (String) request.getAttribute("toDate");
    String userFilter = (String) request.getAttribute("userFilter");
    String errorMsg = (String) request.getAttribute("errorMsg");

    if (performanceList == null) performanceList = new ArrayList<TaskPerformance>();
    if (users == null) users = new ArrayList<String>();
    if (fromDate == null) fromDate = "";
    if (toDate == null) toDate = "";
    if (userFilter == null) userFilter = "ALL";

    String ctx = request.getContextPath();

    int totalCompleted = 0;
    int totalPending = 0;
    int totalAssigned = 0;
    int totalCritical = 0;

    for (TaskPerformance p : performanceList) {
        totalCompleted += p.getCompletedTasks();
        totalPending += p.getPendingTasks();
        totalAssigned += p.getAssignedTasks();
        totalCritical += p.getCriticalCompleted();
    }
%>

<%!
    public String esc(Object value) {
        if (value == null) return "";

        return String.valueOf(value)
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    public String formatHours(double value) {
        return String.format("%.2f", value);
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Task Performance - DBA Monitor</title>

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            font-family: "Segoe UI", Arial, sans-serif;
            min-height: 100vh;
            background:
                radial-gradient(circle at top left, rgba(34,211,238,.14), transparent 32%),
                linear-gradient(135deg, #08111f, #102033);
            color: #e5eefb;
        }

        .page {
            padding: 26px;
        }

        .topbar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 14px;
            margin-bottom: 20px;
        }

        h1 {
            margin: 0;
            font-size: 28px;
        }

        .subtitle {
            color: #94a3b8;
            font-size: 14px;
            margin-top: 6px;
        }

        .back-link {
            color: #22d3ee;
            text-decoration: none;
            font-weight: 900;
            background: rgba(34,211,238,.12);
            border: 1px solid rgba(34,211,238,.25);
            padding: 10px 14px;
            border-radius: 12px;
        }

        .summary-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 14px;
            margin-bottom: 18px;
        }

        .summary-card {
            background: rgba(15,23,42,.78);
            border: 1px solid rgba(148,163,184,.22);
            border-radius: 18px;
            padding: 16px;
            box-shadow: 0 18px 50px rgba(0,0,0,.25);
        }

        .summary-label {
            color: #94a3b8;
            font-size: 13px;
            font-weight: 800;
            text-transform: uppercase;
        }

        .summary-value {
            font-size: 32px;
            font-weight: 900;
            margin-top: 7px;
        }

        .card {
            background: rgba(15,23,42,.78);
            border: 1px solid rgba(148,163,184,.22);
            border-radius: 20px;
            padding: 18px;
            box-shadow: 0 18px 50px rgba(0,0,0,.28);
        }

        .filter-row {
            display: flex;
            align-items: end;
            gap: 12px;
            margin-bottom: 16px;
            flex-wrap: wrap;
        }

        label {
            display: block;
            color: #cbd5e1;
            font-size: 12px;
            font-weight: 900;
            text-transform: uppercase;
            margin-bottom: 6px;
        }

        input, select {
            height: 40px;
            border-radius: 11px;
            border: 1px solid rgba(148,163,184,.30);
            background: rgba(2,6,23,.58);
            color: #e5eefb;
            padding: 0 12px;
            outline: none;
        }

        button {
            height: 40px;
            border: none;
            border-radius: 11px;
            background: #22d3ee;
            color: #06202a;
            font-weight: 900;
            padding: 0 16px;
            cursor: pointer;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            overflow: hidden;
            border-radius: 14px;
        }

        th, td {
            padding: 12px;
            border-bottom: 1px solid rgba(148,163,184,.18);
            font-size: 14px;
            text-align: left;
        }

        th {
            background: rgba(2,6,23,.65);
            color: #cbd5e1;
            text-transform: uppercase;
            font-size: 12px;
        }

        .badge {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-width: 45px;
            padding: 6px 10px;
            border-radius: 999px;
            font-size: 12px;
            font-weight: 900;
        }

        .good {
            background: rgba(34,197,94,.16);
            color: #86efac;
        }

        .warn {
            background: rgba(245,158,11,.18);
            color: #fbbf24;
        }

        .danger {
            background: rgba(239,68,68,.18);
            color: #fecaca;
        }

        .normal {
            background: rgba(148,163,184,.18);
            color: #cbd5e1;
        }

        .empty {
            padding: 26px;
            text-align: center;
            color: #94a3b8;
            border: 1px dashed rgba(148,163,184,.30);
            border-radius: 16px;
        }

        .error {
            background: rgba(239,68,68,.16);
            border: 1px solid rgba(239,68,68,.35);
            color: #fecaca;
            padding: 12px;
            border-radius: 13px;
            margin-bottom: 14px;
        }

        @media(max-width: 900px) {
            .summary-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>

<body>

<div class="page">

    <div class="topbar">
        <div>
            <h1>Task Performance</h1>
            <div class="subtitle">
                Team lead view for task completion, pending work and reassignment count.
            </div>
        </div>

        <a class="back-link" href="<%= ctx %>/refreshstats">← Back to Dashboard</a>
    </div>

    <% if (errorMsg != null) { %>
        <div class="error"><%= esc(errorMsg) %></div>
    <% } %>

    <div class="summary-grid">
        <div class="summary-card">
            <div class="summary-label">Assigned Tasks</div>
            <div class="summary-value"><%= totalAssigned %></div>
        </div>

        <div class="summary-card">
            <div class="summary-label">Completed Tasks</div>
            <div class="summary-value" style="color:#86efac;"><%= totalCompleted %></div>
        </div>

        <div class="summary-card">
            <div class="summary-label">Pending Tasks</div>
            <div class="summary-value" style="color:#fecaca;"><%= totalPending %></div>
        </div>

        <div class="summary-card">
            <div class="summary-label">Critical Completed</div>
            <div class="summary-value" style="color:#fbbf24;"><%= totalCritical %></div>
        </div>
    </div>

    <div class="card">

        <form method="get" action="<%= ctx %>/taskperformance" class="filter-row">
            <div>
                <label>From Date</label>
                <input type="date" name="fromDate" value="<%= esc(fromDate) %>">
            </div>

            <div>
                <label>To Date</label>
                <input type="date" name="toDate" value="<%= esc(toDate) %>">
            </div>

            <div>
                <label>User</label>
                <select name="user">
                    <option value="ALL" <%= "ALL".equalsIgnoreCase(userFilter) ? "selected" : "" %>>All</option>
                    <% for (String u : users) { %>
                        <option value="<%= esc(u) %>" <%= u.equalsIgnoreCase(userFilter) ? "selected" : "" %>><%= esc(u) %></option>
                    <% } %>
                </select>
            </div>

            <button type="submit">Filter</button>
            <a class="back-link" href="<%= ctx %>/taskperformance">Last 7 Days</a>
        </form>

        <% if (performanceList.isEmpty()) { %>

            <div class="empty">
                No task performance data found.
            </div>

        <% } else { %>

            <table>
                <thead>
                    <tr>
                        <th>User</th>
                        <th>Created</th>
                        <th>Assigned</th>
                        <th>Completed</th>
                        <th>Pending</th>
                        <th>Critical Done</th>
                        <th>High Done</th>
                        <th>Reassign Count</th>
                        <th>Avg Completion Hours</th>
                    </tr>
                </thead>

                <tbody>
                <% for (TaskPerformance p : performanceList) { %>
                    <tr>
                        <td><b><%= esc(p.getUsername()) %></b></td>
                        <td><span class="badge normal"><%= p.getCreatedTasks() %></span></td>
                        <td><span class="badge normal"><%= p.getAssignedTasks() %></span></td>
                        <td><span class="badge good"><%= p.getCompletedTasks() %></span></td>
                        <td><span class="badge <%= p.getPendingTasks() > 0 ? "danger" : "good" %>"><%= p.getPendingTasks() %></span></td>
                        <td><span class="badge warn"><%= p.getCriticalCompleted() %></span></td>
                        <td><span class="badge warn"><%= p.getHighCompleted() %></span></td>
                        <td><span class="badge <%= p.getTotalReassignCount() > 0 ? "warn" : "normal" %>"><%= p.getTotalReassignCount() %></span></td>
                        <td><span class="badge normal"><%= formatHours(p.getAvgCompletionHours()) %></span></td>
                    </tr>
                <% } %>
                </tbody>
            </table>

        <% } %>

    </div>

</div>

</body>
</html>