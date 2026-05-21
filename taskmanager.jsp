<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String site = (String) request.getAttribute("site");
    String target = (String) request.getAttribute("target");
    String instId = (String) request.getAttribute("instId");
    String sqlId = (String) request.getAttribute("sqlId");
    String sqlText = (String) request.getAttribute("sqlText");
    String errorMsg = (String) request.getAttribute("errorMsg");

    String ctx = request.getContextPath();

    if (site == null) site = "";
    if (target == null) target = "";
    if (instId == null) instId = "";
    if (sqlId == null) sqlId = "";
    if (sqlText == null) sqlText = "";
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
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>SQL Text - DBA Monitor</title>

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

.meta-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 12px;
}

.meta-box {
    background: rgba(2,6,23,.45);
    border: 1px solid rgba(148,163,184,.18);
    border-radius: 14px;
    padding: 12px;
}

.meta-label {
    font-size: 11px;
    color: #94a3b8;
    font-weight: 900;
    text-transform: uppercase;
}

.meta-value {
    margin-top: 5px;
    font-size: 15px;
    font-weight: 900;
    color: #f8fafc;
    word-break: break-word;
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

.sql-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 12px;
    margin-bottom: 12px;
}

.sql-header h2 {
    margin: 0;
    font-size: 20px;
}

.copy-btn {
    height: 38px;
    border: none;
    border-radius: 11px;
    background: #22d3ee;
    color: #06202a;
    font-weight: 900;
    padding: 0 15px;
    cursor: pointer;
}

.copy-btn:hover {
    filter: brightness(1.08);
}

.sql-box {
    width: 100%;
    min-height: 420px;
    background: rgba(2,6,23,.82);
    border: 1px solid rgba(148,163,184,.24);
    border-radius: 16px;
    color: #fde68a;
    padding: 18px;
    font-family: Consolas, "Courier New", monospace;
    font-size: 14px;
    line-height: 1.6;
    white-space: pre-wrap;
    word-break: break-word;
    overflow: auto;
}

.note {
    color: #94a3b8;
    font-size: 13px;
    margin-top: 10px;
    line-height: 1.5;
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

@media(max-width: 900px) {
    .topbar {
        flex-direction: column;
        align-items: flex-start;
    }

    .meta-grid {
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
            <h1>SQL Text Viewer</h1>
            <div class="subtitle">
                View SQL text from GV$SQL using SQL ID and RAC instance.
            </div>
        </div>

        <a class="back-link" href="javascript:history.back()">← Back to Session Monitor</a>
    </div>

    <% if (errorMsg != null) { %>
        <div class="error"><%= esc(errorMsg) %></div>
    <% } %>

    <div class="card">
        <div class="meta-grid">
            <div class="meta-box">
                <div class="meta-label">Database</div>
                <div class="meta-value"><%= esc(site) %>-<%= esc(target) %></div>
            </div>

            <div class="meta-box">
                <div class="meta-label">Instance</div>
                <div class="meta-value"><%= esc(instId) %></div>
            </div>

            <div class="meta-box">
                <div class="meta-label">SQL ID</div>
                <div class="meta-value"><%= esc(sqlId) %></div>
            </div>

            <div class="meta-box">
                <div class="meta-label">Source</div>
                <div class="meta-value">GV$SQL</div>
            </div>
        </div>

        <div class="note">
            If SQL text is not found, it may have aged out from shared pool.
        </div>
    </div>

    <div class="warning-note">
        This page only displays SQL text. It does not execute, modify, or kill any session.
    </div>

    <div class="card">
        <div class="sql-header">
            <h2>SQL Text</h2>
            <button class="copy-btn" type="button" onclick="copySqlText()">Copy SQL</button>
        </div>

        <pre class="sql-box" id="sqlTextBox"><%= esc(sqlText) %></pre>
    </div>

</div>

<script>
function copySqlText() {
    var box = document.getElementById("sqlTextBox");

    if (!box) {
        alert("SQL text not found.");
        return;
    }

    var text = box.innerText || box.textContent;

    if (!text || text.trim() === "") {
        alert("No SQL text to copy.");
        return;
    }

    if (navigator.clipboard) {
        navigator.clipboard.writeText(text).then(function() {
            alert("SQL copied.");
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
    alert("SQL copied.");
}
</script>

</body>
</html>