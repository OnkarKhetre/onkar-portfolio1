<%@ page import="java.util.*" %>
<%@ page import="com.dba.models.SchedulerJobRunInfo" %>
<%@ page import="com.dba.models.RunningSchedulerJobInfo" %>
<%@ page import="com.dba.models.DbmsJobInfo" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    List<SchedulerJobRunInfo> failedJobs =
            (List<SchedulerJobRunInfo>) request.getAttribute("failedJobs");

    List<SchedulerJobRunInfo> recentJobs =
            (List<SchedulerJobRunInfo>) request.getAttribute("recentJobs");

    List<RunningSchedulerJobInfo> runningJobs =
            (List<RunningSchedulerJobInfo>) request.getAttribute("runningJobs");

    List<DbmsJobInfo> brokenDbmsJobs =
            (List<DbmsJobInfo>) request.getAttribute("brokenDbmsJobs");

    String site = (String) request.getAttribute("site");
    String target = (String) request.getAttribute("target");
    String run = (String) request.getAttribute("run");
    String errorMsg = (String) request.getAttribute("errorMsg");

    Integer lastDaysObj = (Integer) request.getAttribute("lastDays");
    int lastDays = lastDaysObj == null ? 1 : lastDaysObj.intValue();

    String[][] dbList = (String[][]) request.getAttribute("dbList");

    if (failedJobs == null) failedJobs = new ArrayList<SchedulerJobRunInfo>();
    if (recentJobs == null) recentJobs = new ArrayList<SchedulerJobRunInfo>();
    if (runningJobs == null) runningJobs = new ArrayList<RunningSchedulerJobInfo>();
    if (brokenDbmsJobs == null) brokenDbmsJobs = new ArrayList<DbmsJobInfo>();

    if (site == null) site = "";
    if (target == null) target = "";
    if (run == null) run = "";

    String ctx = request.getContextPath();

    String selectedDb = "";
    if (!site.trim().equals("") && !target.trim().equals("")) {
        selectedDb = site + "|" + target;
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

    public String selected(String actual, String expected) {
        if (actual == null) actual = "";
        if (expected == null) expected = "";

        return actual.equalsIgnoreCase(expected) ? "selected" : "";
    }

    public String statusClass(String status) {
        if (status == null) return "badge-normal";

        if ("FAILED".equalsIgnoreCase(status)
                || "BROKEN".equalsIgnoreCase(status)
                || "STOPPED".equalsIgnoreCase(status)) {
            return "badge-danger";
        }

        if ("SUCCEEDED".equalsIgnoreCase(status)) {
            return "badge-good";
        }

        return "badge-warning";
    }

    public String brokenClass(String broken, int failures) {
        if ("Y".equalsIgnoreCase(broken) || failures > 0) {
            return "badge-danger";
        }

        return "badge-good";
    }
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Job Failure Monitor - DBA Monitor</title>

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
    font-size: 30px;
    font-weight: 900;
    letter-spacing: -0.5px;
}

.subtitle {
    margin-top: 6px;
    color: #94a3b8;
    font-size: 14px;
    font-weight: 600;
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

.back-link:hover {
    background: rgba(34,211,238,.20);
}

.card {
    background: rgba(15,23,42,.80);
    border: 1px solid rgba(148,163,184,.22);
    border-radius: 20px;
    padding: 18px;
    box-shadow: 0 18px 50px rgba(0,0,0,.28);
    margin-bottom: 18px;
}

.card h2 {
    margin: 0 0 14px;
    font-size: 20px;
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
    height: 40px;
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

.error {
    background: rgba(239,68,68,.16);
    border: 1px solid rgba(239,68,68,.35);
    color: #fecaca;
    padding: 12px;
    border-radius: 13px;
    margin-bottom: 14px;
    font-weight: 800;
}

.note {
    color: #94a3b8;
    font-size: 13px;
    margin-top: 10px;
    line-height: 1.5;
}

.summary-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 14px;
    margin-bottom: 18px;
}

.summary-card {
    background: rgba(15,23,42,.80);
    border: 1px solid rgba(148,163,184,.22);
    border-radius: 18px;
    padding: 16px;
    box-shadow: 0 18px 50px rgba(0,0,0,.22);
}

.summary-label {
    color: #94a3b8;
    font-size: 13px;
    font-weight: 900;
    text-transform: uppercase;
}

.summary-value {
    font-size: 32px;
    font-weight: 900;
    margin-top: 7px;
}

.table-wrap {
    overflow: auto;
    border: 1px solid rgba(148,163,184,.20);
    border-radius: 16px;
}

table {
    width: 100%;
    min-width: 1250px;
    border-collapse: collapse;
}

th, td {
    border-bottom: 1px solid rgba(148,163,184,.16);
    padding: 11px;
    text-align: left;
    vertical-align: top;
    font-size: 13px;
}

th {
    background: rgba(2,6,23,.75);
    color: #cbd5e1;
    text-transform: uppercase;
    font-size: 12px;
    font-weight: 900;
    position: sticky;
    top: 0;
    z-index: 2;
}

.badge {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    padding: 5px 9px;
    border-radius: 999px;
    font-size: 11px;
    font-weight: 900;
    white-space: nowrap;
}

.badge-good {
    background: rgba(34,197,94,.16);
    color: #86efac;
}

.badge-warning {
    background: rgba(245,158,11,.18);
    color: #fbbf24;
}

.badge-danger {
    background: rgba(239,68,68,.18);
    color: #fecaca;
}

.badge-normal {
    background: rgba(148,163,184,.18);
    color: #cbd5e1;
}

.info-box {
    font-family: Consolas, "Courier New", monospace;
    background: rgba(2,6,23,.72);
    border: 1px solid rgba(148,163,184,.22);
    border-radius: 10px;
    padding: 8px;
    color: #fde68a;
    max-width: 520px;
    max-height: 170px;
    overflow: auto;
    white-space: pre-wrap;
    word-break: break-word;
}

.empty {
    padding: 24px;
    text-align: center;
    color: #94a3b8;
    border: 1px dashed rgba(148,163,184,.30);
    border-radius: 16px;
}

.section-title-row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 12px;
    margin-bottom: 12px;
}

@media(max-width: 900px) {
    .topbar {
        align-items: flex-start;
        flex-direction: column;
    }

    .summary-grid {
        grid-template-columns: 1fr;
    }

    .page {
        padding: 16px;
    }
}
</style>
</head>

<body>

<div class="page">

    <div class="topbar">
        <div>
            <h1>Job Failure Monitor</h1>
            <div class="subtitle">
                Check failed scheduler jobs, currently running jobs and broken DBMS_JOB jobs.
            </div>
        </div>

        <a class="back-link" href="<%= ctx %>/dashboard">← Back to Dashboard</a>
    </div>

    <% if (errorMsg != null) { %>
        <div class="error"><%= esc(errorMsg) %></div>
    <% } %>

    <div class="card">
        <form method="get" action="<%= ctx %>/jobfailuremonitor" class="filter-row" onsubmit="return prepareDbSelection();">
            <input type="hidden" name="run" value="Y">
            <input type="hidden" name="site" id="siteInput" value="<%= esc(site) %>">
            <input type="hidden" name="target" id="targetInput" value="<%= esc(target) %>">

            <div>
                <label>Database</label>
                <select id="dbSelect" required>
                    <option value="">Select Database</option>

                    <% if (dbList != null) {
                        for (int i = 0; i < dbList.length; i++) {
                            String dbSite = dbList[i][0];
                            String dbTarget = dbList[i][1];
                            String dbValue = dbSite + "|" + dbTarget;
                    %>
                        <option value="<%= esc(dbValue) %>" <%= selected(selectedDb, dbValue) %>>
                            <%= esc(dbSite) %>-<%= esc(dbTarget) %>
                        </option>
                    <%  }
                    } %>
                </select>
            </div>

            <div>
                <label>Last Days</label>
                <input type="number" name="lastDays" value="<%= lastDays %>" min="1" max="30">
            </div>

            <button type="submit">Check Jobs</button>
        </form>

        <div class="note">
            Recommended for daily/night shift checks. First try Last Days = 1. Increase only if needed.
        </div>
    </div>

    <% if ("Y".equalsIgnoreCase(run)) { %>

        <div class="summary-grid">
            <div class="summary-card">
                <div class="summary-label">Failed Scheduler Jobs</div>
                <div class="summary-value" style="color:<%= failedJobs.size() > 0 ? "#fecaca" : "#86efac" %>;">
                    <%= failedJobs.size() %>
                </div>
            </div>

            <div class="summary-card">
                <div class="summary-label">Running Jobs</div>
                <div class="summary-value" style="color:#67e8f9;">
                    <%= runningJobs.size() %>
                </div>
            </div>

            <div class="summary-card">
                <div class="summary-label">Broken DBMS_JOB</div>
                <div class="summary-value" style="color:<%= brokenDbmsJobs.size() > 0 ? "#fecaca" : "#86efac" %>;">
                    <%= brokenDbmsJobs.size() %>
                </div>
            </div>

            <div class="summary-card">
                <div class="summary-label">Recent Job History</div>
                <div class="summary-value" style="color:#cbd5e1;">
                    <%= recentJobs.size() %>
                </div>
            </div>
        </div>

        <div class="card">
            <div class="section-title-row">
                <h2>Failed Scheduler Jobs</h2>
                <span class="badge <%= failedJobs.size() > 0 ? "badge-danger" : "badge-good" %>">
                    <%= failedJobs.size() > 0 ? "Check Required" : "No Failures" %>
                </span>
            </div>

            <% if (failedJobs.isEmpty()) { %>

                <div class="empty">No failed/stopped/broken scheduler jobs found in last <%= lastDays %> day(s).</div>

            <% } else { %>

                <div class="table-wrap">
                    <table>
                        <thead>
                            <tr>
                                <th>Owner</th>
                                <th>Job Name</th>
                                <th>Status</th>
                                <th>Error#</th>
                                <th>Log Date</th>
                                <th>Start Date</th>
                                <th>Duration</th>
                                <th>Instance</th>
                                <th>Additional Info</th>
                            </tr>
                        </thead>

                        <tbody>
                        <% for (SchedulerJobRunInfo j : failedJobs) { %>
                            <tr>
                                <td><%= esc(j.getOwner()) %></td>
                                <td><b><%= esc(j.getJobName()) %></b></td>
                                <td><span class="badge <%= statusClass(j.getStatus()) %>"><%= esc(j.getStatus()) %></span></td>
                                <td><%= esc(j.getErrorNumber()) %></td>
                                <td><%= esc(j.getLogDate()) %></td>
                                <td><%= esc(j.getActualStartDate()) %></td>
                                <td><%= esc(j.getRunDuration()) %></td>
                                <td><%= esc(j.getInstanceId()) %></td>
                                <td><div class="info-box"><%= esc(j.getAdditionalInfo()) %></div></td>
                            </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>

            <% } %>
        </div>

        <div class="card">
            <div class="section-title-row">
                <h2>Currently Running Scheduler Jobs</h2>
                <span class="badge badge-normal">Running: <%= runningJobs.size() %></span>
            </div>

            <% if (runningJobs.isEmpty()) { %>

                <div class="empty">No scheduler jobs are currently running.</div>

            <% } else { %>

                <div class="table-wrap">
                    <table>
                        <thead>
                            <tr>
                                <th>Owner</th>
                                <th>Job Name</th>
                                <th>Session ID</th>
                                <th>Running Instance</th>
                                <th>Elapsed Time</th>
                                <th>CPU Used</th>
                            </tr>
                        </thead>

                        <tbody>
                        <% for (RunningSchedulerJobInfo r : runningJobs) { %>
                            <tr>
                                <td><%= esc(r.getOwner()) %></td>
                                <td><b><%= esc(r.getJobName()) %></b></td>
                                <td><%= esc(r.getSessionId()) %></td>
                                <td><%= esc(r.getRunningInstance()) %></td>
                                <td><%= esc(r.getElapsedTime()) %></td>
                                <td><%= esc(r.getCpuUsed()) %></td>
                            </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>

            <% } %>
        </div>

        <div class="card">
            <div class="section-title-row">
                <h2>Broken / Failed DBMS_JOB Jobs</h2>
                <span class="badge <%= brokenDbmsJobs.size() > 0 ? "badge-danger" : "badge-good" %>">
                    <%= brokenDbmsJobs.size() > 0 ? "Check Required" : "No Broken Jobs" %>
                </span>
            </div>

            <% if (brokenDbmsJobs.isEmpty()) { %>

                <div class="empty">No broken or failed DBMS_JOB jobs found.</div>

            <% } else { %>

                <div class="table-wrap">
                    <table>
                        <thead>
                            <tr>
                                <th>Job ID</th>
                                <th>Schema User</th>
                                <th>Broken</th>
                                <th>Failures</th>
                                <th>Last Date</th>
                                <th>Next Date</th>
                                <th>What</th>
                            </tr>
                        </thead>

                        <tbody>
                        <% for (DbmsJobInfo d : brokenDbmsJobs) { %>
                            <tr>
                                <td><b><%= d.getJobId() %></b></td>
                                <td><%= esc(d.getSchemaUser()) %></td>
                                <td><span class="badge <%= brokenClass(d.getBroken(), d.getFailures()) %>"><%= esc(d.getBroken()) %></span></td>
                                <td><%= d.getFailures() %></td>
                                <td><%= esc(d.getLastDate()) %></td>
                                <td><%= esc(d.getNextDate()) %></td>
                                <td><div class="info-box"><%= esc(d.getWhat()) %></div></td>
                            </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>

            <% } %>
        </div>

        <div class="card">
            <div class="section-title-row">
                <h2>Recent Scheduler Job History</h2>
                <span class="badge badge-normal">Latest 100 rows</span>
            </div>

            <% if (recentJobs.isEmpty()) { %>

                <div class="empty">No scheduler job history found in last <%= lastDays %> day(s).</div>

            <% } else { %>

                <div class="table-wrap">
                    <table>
                        <thead>
                            <tr>
                                <th>Owner</th>
                                <th>Job Name</th>
                                <th>Status</th>
                                <th>Error#</th>
                                <th>Log Date</th>
                                <th>Start Date</th>
                                <th>Duration</th>
                                <th>Instance</th>
                                <th>Additional Info</th>
                            </tr>
                        </thead>

                        <tbody>
                        <% for (SchedulerJobRunInfo j : recentJobs) { %>
                            <tr>
                                <td><%= esc(j.getOwner()) %></td>
                                <td><b><%= esc(j.getJobName()) %></b></td>
                                <td><span class="badge <%= statusClass(j.getStatus()) %>"><%= esc(j.getStatus()) %></span></td>
                                <td><%= esc(j.getErrorNumber()) %></td>
                                <td><%= esc(j.getLogDate()) %></td>
                                <td><%= esc(j.getActualStartDate()) %></td>
                                <td><%= esc(j.getRunDuration()) %></td>
                                <td><%= esc(j.getInstanceId()) %></td>
                                <td><div class="info-box"><%= esc(j.getAdditionalInfo()) %></div></td>
                            </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>

            <% } %>
        </div>

    <% } else { %>

        <div class="card">
            <div class="empty">
                Select a database and click <b>Check Jobs</b> to view failed jobs, running jobs and broken DBMS_JOB jobs.
            </div>
        </div>

    <% } %>

</div>

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

</body>
</html>