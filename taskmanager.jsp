<%@ page import="java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    List<String> users = (List<String>) request.getAttribute("users");
    Map<String, String> rosterMap = (Map<String, String>) request.getAttribute("rosterMap");

    Integer yearObj = (Integer) request.getAttribute("year");
    Integer monthObj = (Integer) request.getAttribute("month");
    Integer daysObj = (Integer) request.getAttribute("daysInMonth");

    String currentShift = (String) request.getAttribute("currentShift");
    List<String> currentShiftUsers = (List<String>) request.getAttribute("currentShiftUsers");

    String errorMsg = (String) request.getAttribute("errorMsg");
    String saved = request.getParameter("saved");

    if (users == null) users = new ArrayList<String>();
    if (rosterMap == null) rosterMap = new HashMap<String, String>();
    if (currentShiftUsers == null) currentShiftUsers = new ArrayList<String>();

    int year = yearObj == null ? 2026 : yearObj.intValue();
    int month = monthObj == null ? 5 : monthObj.intValue();
    int daysInMonth = daysObj == null ? 31 : daysObj.intValue();

    String ctx = request.getContextPath();
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

    public String selected(String actual, String expected) {
        if (actual == null) actual = "NA";
        return actual.equalsIgnoreCase(expected) ? "selected" : "";
    }

    public String shiftName(String code) {
        if ("M".equalsIgnoreCase(code)) return "Morning";
        if ("S".equalsIgnoreCase(code)) return "Second";
        if ("N".equalsIgnoreCase(code)) return "Night";
        if ("G".equalsIgnoreCase(code)) return "General";
        if ("WO".equalsIgnoreCase(code)) return "Week Off";
        if ("L".equalsIgnoreCase(code)) return "Leave";
        return "Not Assigned";
    }
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Shift Roster - DBA Monitor</title>

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
    padding: 24px;
}

.topbar {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 16px;
    margin-bottom: 18px;
}

h1 {
    margin: 0;
    font-size: 28px;
}

.subtitle {
    margin-top: 6px;
    color: #94a3b8;
    font-size: 14px;
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

.card {
    background: rgba(15,23,42,.80);
    border: 1px solid rgba(148,163,184,.22);
    border-radius: 20px;
    padding: 18px;
    box-shadow: 0 18px 50px rgba(0,0,0,.28);
    margin-bottom: 18px;
}

.filter-row {
    display: flex;
    align-items: end;
    gap: 12px;
    flex-wrap: wrap;
}

label {
    display: block;
    font-size: 12px;
    color: #cbd5e1;
    font-weight: 900;
    text-transform: uppercase;
    margin-bottom: 6px;
}

select, input {
    height: 39px;
    border: 1px solid rgba(148,163,184,.30);
    background: rgba(2,6,23,.58);
    color: #e5eefb;
    border-radius: 11px;
    padding: 0 10px;
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

button:hover {
    filter: brightness(1.08);
}

.legend {
    display: flex;
    gap: 8px;
    flex-wrap: wrap;
    margin-top: 14px;
}

.badge {
    display: inline-flex;
    align-items: center;
    padding: 6px 10px;
    border-radius: 999px;
    font-size: 12px;
    font-weight: 900;
}

.M {
    background: rgba(59,130,246,.25);
    color: #bfdbfe;
}

.S {
    background: rgba(34,197,94,.22);
    color: #bbf7d0;
}

.N {
    background: rgba(168,85,247,.24);
    color: #e9d5ff;
}

.G {
    background: rgba(14,165,233,.20);
    color: #bae6fd;
}

.WO {
    background: rgba(100,116,139,.35);
    color: #e2e8f0;
}

.L {
    background: rgba(239,68,68,.25);
    color: #fecaca;
}

.NA {
    background: rgba(148,163,184,.12);
    color: #cbd5e1;
}

.notice {
    background: rgba(34,197,94,.16);
    border: 1px solid rgba(34,197,94,.35);
    color: #bbf7d0;
    padding: 12px;
    border-radius: 13px;
    margin-bottom: 14px;
}

.error {
    background: rgba(239,68,68,.16);
    border: 1px solid rgba(239,68,68,.35);
    color: #fecaca;
    padding: 12px;
    border-radius: 13px;
    margin-bottom: 14px;
}

.current-box {
    display: flex;
    gap: 12px;
    align-items: center;
    flex-wrap: wrap;
}

.table-wrap {
    overflow: auto;
    border: 1px solid rgba(148,163,184,.20);
    border-radius: 16px;
    max-height: 70vh;
}

table {
    border-collapse: separate;
    border-spacing: 0;
    min-width: 1250px;
    width: max-content;
}

th, td {
    border-bottom: 1px solid rgba(148,163,184,.16);
    border-right: 1px solid rgba(148,163,184,.12);
    padding: 7px;
    text-align: center;
    white-space: nowrap;
}

th {
    background: rgba(2,6,23,.88);
    color: #cbd5e1;
    position: sticky;
    top: 0;
    z-index: 5;
    font-size: 12px;
}

.name-col {
    position: sticky;
    left: 0;
    z-index: 6;
    background: rgba(15,23,42,.98);
    text-align: left;
    min-width: 170px;
    font-weight: 900;
}

th.name-col {
    z-index: 8;
    background: rgba(2,6,23,.98);
}

.shift-select {
    width: 66px;
    height: 32px;
    border-radius: 9px;
    font-size: 12px;
    font-weight: 900;
    padding: 0 5px;
    color: #ffffff;
}

.shift-select.M {
    background: rgba(37,99,235,.75);
}

.shift-select.S {
    background: rgba(22,163,74,.72);
}

.shift-select.N {
    background: rgba(126,34,206,.72);
}

.shift-select.G {
    background: rgba(2,132,199,.72);
}

.shift-select.WO {
    background: rgba(71,85,105,.80);
}

.shift-select.L {
    background: rgba(220,38,38,.78);
}

.shift-select.NA {
    background: rgba(30,41,59,.88);
}

.actions {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-top: 14px;
    gap: 12px;
}

.small-text {
    color: #94a3b8;
    font-size: 13px;
}
</style>
</head>

<body>

<div class="page">

    <div class="topbar">
        <div>
            <h1>Shift Roster</h1>
            <div class="subtitle">Monthly Excel-style roster for DBA team shifts.</div>
        </div>

        <a class="back-link" href="<%= ctx %>/refreshstats">← Back to Dashboard</a>
    </div>

    <% if ("1".equals(saved)) { %>
        <div class="notice">Roster saved successfully.</div>
    <% } %>

    <% if (errorMsg != null) { %>
        <div class="error"><%= esc(errorMsg) %></div>
    <% } %>

    <div class="card">
        <form method="get" action="<%= ctx %>/shiftroster" class="filter-row">
            <div>
                <label>Month</label>
                <select name="month">
                    <% for(int m = 1; m <= 12; m++){ %>
                        <option value="<%= m %>" <%= m == month ? "selected" : "" %>><%= m %></option>
                    <% } %>
                </select>
            </div>

            <div>
                <label>Year</label>
                <input type="number" name="year" value="<%= year %>" min="2024" max="2035">
            </div>

            <button type="submit">Load Roster</button>
        </form>

        <div class="legend">
            <span class="badge M">M = Morning 7:30 - 3:30</span>
            <span class="badge S">S = Second 2 - 10</span>
            <span class="badge N">N = Night 10 - 7</span>
            <span class="badge G">G = General</span>
            <span class="badge WO">WO = Week Off</span>
            <span class="badge L">L = Leave</span>
            <span class="badge NA">NA = Not Assigned</span>
        </div>
    </div>

    <div class="card">
        <div class="current-box">
            <span class="badge <%= esc(currentShift) %>">
                Current Shift: <%= esc(currentShift) %> - <%= shiftName(currentShift) %>
            </span>

            <span class="small-text">
                Working now:
                <% if(currentShiftUsers.isEmpty()){ %>
                    <b>No roster found</b>
                <% } else { %>
                    <b><%= esc(currentShiftUsers) %></b>
                <% } %>
            </span>
        </div>
    </div>

    <form method="post" action="<%= ctx %>/shiftroster">

        <input type="hidden" name="month" value="<%= month %>">
        <input type="hidden" name="year" value="<%= year %>">

        <div class="card">
            <div class="table-wrap">
                <table>
                    <thead>
                        <tr>
                            <th class="name-col">Team Member</th>
                            <% for(int day = 1; day <= daysInMonth; day++){ %>
                                <th><%= day %></th>
                            <% } %>
                        </tr>
                    </thead>

                    <tbody>
                        <% for(int i = 0; i < users.size(); i++){ 
                            String username = users.get(i);
                        %>
                            <tr>
                                <td class="name-col"><%= esc(username) %></td>

                                <% for(int day = 1; day <= daysInMonth; day++){ 
                                    String key = username + "#" + day;
                                    String shift = rosterMap.get(key);
                                    if(shift == null || shift.trim().equals("")) shift = "NA";
                                %>
                                    <td>
                                        <select name="shift_<%= i %>_<%= day %>"
                                                class="shift-select <%= esc(shift) %>"
                                                onchange="updateShiftColor(this)">
                                            <option value="NA" <%= selected(shift, "NA") %>>NA</option>
                                            <option value="M" <%= selected(shift, "M") %>>M</option>
                                            <option value="S" <%= selected(shift, "S") %>>S</option>
                                            <option value="N" <%= selected(shift, "N") %>>N</option>
                                            <option value="G" <%= selected(shift, "G") %>>G</option>
                                            <option value="WO" <%= selected(shift, "WO") %>>WO</option>
                                            <option value="L" <%= selected(shift, "L") %>>L</option>
                                        </select>
                                    </td>
                                <% } %>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>

            <div class="actions">
                <div class="small-text">
                    Save after filling the monthly roster.
                </div>

                <button type="submit">Save Roster</button>
            </div>
        </div>

    </form>

</div>

<script>
function updateShiftColor(select){
    select.className = "shift-select " + select.value;
}
</script>

</body>
</html>