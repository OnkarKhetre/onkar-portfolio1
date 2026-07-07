<%@ page import="java.util.*" %>
<%@ page import="com.dba.models.LockNode" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    // 1. Retrieve attributes passed from the Servlet
    List<LockNode> lockTreeList = (List<LockNode>) request.getAttribute("lockTreeList");
    
    String site = (String) request.getAttribute("site");
    
    String target = (String) request.getAttribute("target");
    
    String run = (String) request.getAttribute("run");
    
    String errorMsg = (String) request.getAttribute("errorMsg");
    
    String[][] dbList = (String[][]) request.getAttribute("dbList");

    // Prevent null pointer exceptions if accessed for the first time
    if (lockTreeList == null) {
        lockTreeList = new ArrayList<LockNode>();
    }
    
    String ctx = request.getContextPath();
    
    String selectedDb = "";
    
    if (site != null && target != null) {
        selectedDb = site + "|" + target;
    }
%>

<%!
    // 2. Helper method to safely escape HTML characters
    public String esc(Object value) {
        
        if (value == null) {
            return "";
        }
        
        return String.valueOf(value)
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#39;");
    }
    
    // Helper method to keep dropdown selections active
    public String selected(String actual, String expected) {
        
        if (actual != null && actual.equalsIgnoreCase(expected)) {
            return "selected";
        }
        
        return "";
    }
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Lock Tree - DBA Monitor</title>

<style>
    /* 3. Base Dashboard Styles */
    * { 
        box-sizing: border-box; 
    }
    
    body { 
        margin: 0; 
        font-family: "Segoe UI", Arial, sans-serif; 
        min-height: 100vh; 
        background: radial-gradient(circle at top left, rgba(34,211,238,.14), transparent 32%), 
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
    
    .card { 
        background: rgba(15,23,42,.80); 
        border: 1px solid rgba(148,163,184,.22); 
        border-radius: 20px; 
        padding: 18px; 
        margin-bottom: 18px; 
        box-shadow: 0 18px 50px rgba(0,0,0,.28); 
    }
    
    /* 4. Form Styles */
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
    
    select { 
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
    
    .empty { 
        padding: 24px; 
        text-align: center; 
        color: #94a3b8; 
        border: 1px dashed rgba(148,163,184,.30); 
        border-radius: 16px; 
    }
    
    /* 5. Badge Styles */
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
    
    .badge-critical { 
        background: rgba(239,68,68,.18); 
        color: #fecaca; 
    }
    
    .badge-warning { 
        background: rgba(245,158,11,.18); 
        color: #fbbf24; 
    }
    
    .badge-normal { 
        background: rgba(148,163,184,.18); 
        color: #cbd5e1; 
    }
    
    /* 6. Specific Tree Layout Styles */
    .tree-node {
        position: relative; 
        padding: 14px; 
        margin-top: 8px; 
        background: rgba(2,6,23,.58);
        border: 1px solid rgba(148,163,184,.16); 
        border-radius: 12px;
        border-left: 4px solid #fbbf24; 
        display: flex; 
        flex-wrap: wrap; 
        gap: 15px; 
        align-items: center; 
        font-size: 13px;
    }
    
    .root-node { 
        background: rgba(239,68,68,.10); 
        border-color: rgba(239,68,68,.35); 
        border-left: 6px solid #ef4444; 
    }
    
    .sql-box { 
        font-family: Consolas, monospace; 
        background: rgba(2,6,23,.72); 
        border: 1px solid rgba(148,163,184,.22); 
        border-radius: 10px; 
        padding: 8px; 
        color: #fde68a; 
        max-width: 360px; 
        word-break: break-word; 
    }
    
    .copy-btn { 
        height: 30px; 
        padding: 0 9px; 
        border-radius: 8px; 
        font-size: 12px; 
        background: rgba(34,211,238,.18); 
        color: #67e8f9; 
        border: 1px solid rgba(34,211,238,.25); 
        margin-left: auto; 
    }
</style>

<script>
    // 7. JavaScript Functions
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
        
        if (!el) return;
        
        var text = el.innerText || el.textContent;
        
        if (navigator.clipboard) { 
            navigator.clipboard.writeText(text).then(function() { 
                alert("Copied."); 
            }); 
        }
    }
</script>
</head>

<body>
<div class="page">

    <div class="topbar">
        <div>
            <h1>Lock Dependency Tree</h1>
            <div class="subtitle">Hierarchical mapping of database wait chains via GV$SESSION</div>
        </div>
        
        <a class="back-link" href="<%= ctx %>/dashboard">← Back to Dashboard</a>
    </div>

    <% if (errorMsg != null) { %>
        <div class="error"><%= esc(errorMsg) %></div>
    <% } %>

    <div class="card">
        
        <form method="get" action="<%= ctx %>/locktree" class="filter-row" onsubmit="return prepareDbSelection();">
            
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
            
            <button type="submit">Analyze Locks</button>
            
        </form>
    </div>

    <% if ("Y".equalsIgnoreCase(run)) { %>
        
        <div class="card">
            <h2>Active Lock Chain</h2>
            
            <% if (lockTreeList.isEmpty()) { %>
                
                <div class="empty">No blocking sessions found.</div>
                
            <% } else { 
                
                for (LockNode node : lockTreeList) {
                    
                    boolean isRoot = (node.getLevel() == 1);
                    
                    // Indent by 45 pixels for every level deep in the hierarchy
                    int indent = (node.getLevel() - 1) * 45; 
            %>
                
                <div class="tree-node <%= isRoot ? "root-node" : "" %>" style="margin-left: <%= indent %>px;">
                    
                    <div>
                        <% if (isRoot) { %>
                            <span class="badge badge-critical">ROOT BLOCKER</span>
                        <% } else { %>
                            <span class="badge badge-warning">↳ WAITING</span>
                        <% } %>
                    </div>
                    
                    <div>
                        <span class="badge badge-normal">Inst <%= esc(node.getInstId()) %></span>
                    </div>
                    
                    <div>
                        SID: <b><%= esc(node.getSid()) %></b> , <%= esc(node.getSerial()) %>
                    </div>
                    
                    <div>
                        <b><%= esc(node.getUsername()) %></b><br>
                        <span style="color:#94a3b8;"><%= esc(node.getProgram()) %></span>
                    </div>
                    
                    <div>
                        <%= esc(node.getEvent()) %><br>
                        <span style="color:#fbbf24;"><%= node.getSecondsInWait() %>s wait</span>
                    </div>
                    
                    <div class="sql-box" id="kill_<%= esc(node.getInstId()) %>_<%= esc(node.getSid()) %>">
                        <%= esc(node.getKillCommand()) %>
                    </div>
                    
                    <button class="copy-btn" type="button" 
                            onclick="copyText('kill_<%= esc(node.getInstId()) %>_<%= esc(node.getSid()) %>')">
                        Copy
                    </button>
                    
                </div>
                
            <%  
                } 
            } 
            %>
        </div>
        
    <% } %>

</div>
</body>
</html>
