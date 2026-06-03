<%@ page import="java.util.*" %>
<%@ page import="com.dba.models.DatafileInfo" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    List<DatafileInfo> datafiles =
            (List<DatafileInfo>) request.getAttribute("datafiles");

    String site = (String) request.getAttribute("site");
    String target = (String) request.getAttribute("target");
    String tablespaceName = (String) request.getAttribute("tablespaceName");
    String run = (String) request.getAttribute("run");
    String errorMsg = (String) request.getAttribute("errorMsg");

    String addDatafileCommand = (String) request.getAttribute("addDatafileCommand");
    String addTempfileCommand = (String) request.getAttribute("addTempfileCommand");

    String[][] dbList = (String[][]) request.getAttribute("dbList");

    if (datafiles == null) datafiles = new ArrayList<DatafileInfo>();

    if (site == null) site = "";
    if (target == null) target = "";
    if (tablespaceName == null) tablespaceName = "";
    if (run == null) run = "";
    if (addDatafileCommand == null) addDatafileCommand = "";
    if (addTempfileCommand == null) addTempfileCommand = "";

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

    public String ynClass(String value) {
        if ("YES".equalsIgnoreCase(value)) {
            return "badge-good";
        }

        return "badge-warning";
    }

    public String fileTypeClass(String value) {
        if ("TEMPFILE".equalsIgnoreCase(value)) {
            return "badge-temp";
        }

        return "badge-data";
    }

    public String fmt(double value) {
        return String.format("%.2f", value);
    }
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Tablespace Datafiles - DBA Monitor</title>

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

input {
    min-width: 260px;
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

.warning-note {
    background: rgba(245,158,11,.12);
    border: 1px solid rgba(245,158,11,.30);
    color: #fde68a;
    padding: 12px;
    border-radius: 13px;
    margin-bottom: 14px;
    font-size: 13px;
    font-weight: 700;
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
    font-size: 28px;
    font-weight: 900;
    margin-top: 7px;
    color: #67e8f9;
}

.table-wrap {
    overflow: auto;
    border: 1px solid rgba(148,163,184,.20);
    border-radius: 16px;
}

table {
    width: 100%;
    min-width: 1350px;
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

.file-name {
    font-family: Consolas, "Courier New", monospace;
    color: #f8fafc;
    word-break: break-word;
    max-width: 430px;
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

.badge-data {
    background: rgba(34,211,238,.16);
    color: #a5f3fc;
}

.badge-temp {
    background: rgba(168,85,247,.20);
    color: #e9d5ff;
}

.badge-normal {
    background: rgba(148,163,184,.18);
    color: #cbd5e1;
}

.command-box {
    font-family: Consolas, "Courier New", monospace;
    background: rgba(2,6,23,.72);
    border: 1px solid rgba(148,163,184,.22);
    border-radius: 10px;
    padding: 8px;
    color: #fde68a;
    max-width: 420px;
    white-space: normal;
    word-break: break-word;
}

.copy-btn {
    height: 30px;
    padding: 0 9px;
    border-radius: 8px;
    font-size: 12px;
    margin-top: 6px;
    background: rgba(34,211,238,.18);
    color: #67e8f9;
    border: 1px solid rgba(34,211,238,.25);
}

.empty {
    padding: 24px;
    text-align: center;
    color: #94a3b8;
    border: 1px dashed rgba(148,163,184,.30);
    border-radius: 16px;
}

.command-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 14px;
}

.command-title {
    font-size: 14px;
    font-weight: 900;
    color: #f8fafc;
    margin-bottom: 8px;
}

@media(max-width: 900px) {
    .topbar {
        align-items: flex-start;
        flex-direction: column;
    }

    .summary-grid {
        grid-template-columns: 1fr;
    }

    .command-grid {
        grid-template-columns: 1fr;
    }

    .page {
        padding: 16px;
    }

    input {
        min-width: 100%;
    }
}
</style>
</head>

<body>

<div class="page">

    <div class="topbar">
        <div>
            <h1>Tablespace Datafiles</h1>
            <div class="subtitle">
                View datafiles/tempfiles for one tablespace and generate safe DBA command templates.
            </div>
        </div>

        <a class="back-link" href="<%= ctx %>/dashboard">← Back to Dashboard</a>
    </div>

    <% if (errorMsg != null) { %>
        <div class="error"><%= esc(errorMsg) %></div>
    <% } %>

    <div class="card">
        <form method="get" action="<%= ctx %>/tablespacedatafiles" class="filter-row" onsubmit="return prepareDbSelection();">
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
                <label>Tablespace Name</label>
                <input type="text"
                       name="tablespaceName"
                       value="<%= esc(tablespaceName) %>"
                       placeholder="Example: EISAPP"
                       required>
            </div>

            <button type="submit">Check Datafiles</button>
        </form>

        <div class="note">
            This page checks only the selected tablespace. It does not scan all tablespaces, so it is safer for large databases like ARCHIVALDB.
        </div>
    </div>

    <div class="warning-note">
        This page only generates command templates. Do not execute any command without verifying ASM/storage space, standard size policy, and senior DBA approval.
    </div>

    <% if ("Y".equalsIgnoreCase(run)) { %>

        <%
            int totalFiles = datafiles.size();
            int autoExtendYes = 0;
            int autoExtendNo = 0;
            double totalSizeGb = 0;

            for (DatafileInfo d : datafiles) {
                totalSizeGb += d.getSizeGb();

                if ("YES".equalsIgnoreCase(d.getAutoExtensible())) {
                    autoExtendYes++;
                } else {
                    autoExtendNo++;
                }
            }
        %>

        <div class="summary-grid">
            <div class="summary-card">
                <div class="summary-label">Tablespace</div>
                <div class="summary-value"><%= esc(tablespaceName.toUpperCase()) %></div>
            </div>

            <div class="summary-card">
                <div class="summary-label">Files Found</div>
                <div class="summary-value"><%= totalFiles %></div>
            </div>

            <div class="summary-card">
                <div class="summary-label">Total Size GB</div>
                <div class="summary-value"><%= fmt(totalSizeGb) %></div>
            </div>

            <div class="summary-card">
                <div class="summary-label">Autoextend OFF</div>
                <div class="summary-value" style="color:<%= autoExtendNo > 0 ? "#fbbf24" : "#86efac" %>;">
                    <%= autoExtendNo %>
                </div>
            </div>
        </div>

        <div class="card">
            <h2>Datafiles / Tempfiles</h2>

            <% if (datafiles.isEmpty()) { %>

                <div class="empty">
                    No datafiles or tempfiles found for tablespace
                    <b><%= esc(tablespaceName.toUpperCase()) %></b>.
                    Check spelling and database selection.
                </div>

            <% } else { %>

                <div class="table-wrap">
                    <table>
                        <thead>
                            <tr>
                                <th>Type</th>
                                <th>Tablespace</th>
                                <th>File Name</th>
                                <th>Size GB</th>
                                <th>Autoextend</th>
                                <th>Max Size GB</th>
                                <th>Increment MB</th>
                                <th>Status</th>
                                <th>Enable Autoextend Command</th>
                                <th>Resize Command</th>
                            </tr>
                        </thead>

                        <tbody>
                        <% for (int i = 0; i < datafiles.size(); i++) {
                            DatafileInfo d = datafiles.get(i);
                            String autoId = "auto_cmd_" + i;
                            String resizeId = "resize_cmd_" + i;
                        %>
                            <tr>
                                <td>
                                    <span class="badge <%= fileTypeClass(d.getFileType()) %>">
                                        <%= esc(d.getFileType()) %>
                                    </span>
                                </td>

                                <td><%= esc(d.getTablespaceName()) %></td>

                                <td>
                                    <div class="file-name"><%= esc(d.getFileName()) %></div>
                                </td>

                                <td><b><%= fmt(d.getSizeGb()) %></b></td>

                                <td>
                                    <span class="badge <%= ynClass(d.getAutoExtensible()) %>">
                                        <%= esc(d.getAutoExtensible()) %>
                                    </span>
                                </td>

                                <td><%= fmt(d.getMaxSizeGb()) %></td>

                                <td><%= fmt(d.getIncrementMb()) %></td>

                                <td>
                                    <span class="badge badge-normal">
                                        <%= esc(d.getStatus()) %>
                                    </span>
                                </td>

                                <td>
                                    <div class="command-box" id="<%= autoId %>">
                                        <%= esc(d.getAutoExtendCommand()) %>
                                    </div>
                                    <button class="copy-btn" type="button" onclick="copyText('<%= autoId %>')">
                                        Copy
                                    </button>
                                </td>

                                <td>
                                    <div class="command-box" id="<%= resizeId %>">
                                        <%= esc(d.getResizeCommand()) %>
                                    </div>
                                    <button class="copy-btn" type="button" onclick="copyText('<%= resizeId %>')">
                                        Copy
                                    </button>
                                </td>
                            </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>

            <% } %>
        </div>

        <div class="card">
            <h2>Add File Command Templates</h2>

            <div class="command-grid">
                <div>
                    <div class="command-title">Add Datafile</div>
                    <div class="command-box" id="addDatafileCommand"><%= esc(addDatafileCommand) %></div>
                    <button class="copy-btn" type="button" onclick="copyText('addDatafileCommand')">
                        Copy
                    </button>
                </div>

                <div>
                    <div class="command-title">Add Tempfile</div>
                    <div class="command-box" id="addTempfileCommand"><%= esc(addTempfileCommand) %></div>
                    <button class="copy-btn" type="button" onclick="copyText('addTempfileCommand')">
                        Copy
                    </button>
                </div>
            </div>

            <div class="note">
                Use Add Datafile for normal permanent tablespaces. Use Add Tempfile only for temporary tablespaces like TEMP.
                Replace <b>+DATA</b> with the correct ASM diskgroup if required.
            </div>
        </div>

    <% } else { %>

        <div class="card">
            <div class="empty">
                Select a database and enter a tablespace name to view datafiles/tempfiles.
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

function copyText(elementId) {
    var el = document.getElementById(elementId);

    if (!el) {
        alert("Text not found.");
        return;
    }

    var text = el.innerText || el.textContent;

    if (!text || text.trim() === "") {
        alert("Nothing to copy.");
        return;
    }

    if (navigator.clipboard) {
        navigator.clipboard.writeText(text).then(function() {
            alert("Copied.");
        }).catch(function() {
            fallbackCopy(text);
        });
    } else {
        fallbackCopy(text);
    }
}

function fallbackCopy(text) {
    var temp = document.createElement("textarea");
    temp.value = text;
    document.body.appendChild(temp);
    temp.select();
    document.execCommand("copy");
    document.body.removeChild(temp);
    alert("Copied.");
}
</script>

</body>
</html>