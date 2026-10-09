<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String ctx = request.getContextPath();
    String errorMsg = (String) request.getAttribute("errorMsg");
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Report Automation - DBA Monitor</title>

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
    .upload-row { display: flex; align-items: end; gap: 12px; flex-wrap: wrap; margin-top: 20px;}
    label { display: block; font-size: 11px; color: #94a3b8; font-weight: 900; text-transform: uppercase; margin-bottom: 6px; letter-spacing: 0.5px; }
    
    /* Styled the file input to match the text/date inputs from tablegrowth */
    input[type="file"] { 
        height: 42px; border: 1px dashed rgba(148,163,184,.40); 
        background: rgba(2,6,23,.58); color: #e5eefb; font-family: inherit;
        border-radius: 11px; padding: 9px 14px; outline: none; transition: 0.2s;
        width: 100%; max-width: 400px; cursor: pointer;
    }
    input[type="file"]:focus, input[type="file"]:hover { border-color: #22d3ee; background: rgba(2,6,23,.80); }
    
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
</style>
</head>
<body>

<div class="page">
    <div class="topbar">
        <div>
            <h1>Daily Report Automation</h1>
            <div class="subtitle">Automated EIS volume and health document generator</div>
        </div>
        <a class="back-link" href="<%= ctx %>/dashboard">← Back</a>
    </div>

    <% if (errorMsg != null && !errorMsg.isEmpty()) { %> 
        <div class="error"><%= errorMsg %></div> 
    <% } %>

    <div class="card">
        <h2 style="margin-top: 0; font-size: 22px; color: #e2e8f0;">Generate UAT Report</h2>
        <p style="color: #94a3b8; font-size: 14px; margin-bottom: 20px;">Select today's <strong>Book1.xlsx</strong> file to generate the completed Word document.</p>
        
        <!-- Action points directly to the Servlet we built -->
        <form action="<%= ctx %>/ReportGeneratorServlet" method="POST" enctype="multipart/form-data" class="upload-row">
            <div style="flex-grow: 1; max-width: 400px;">
                <label>Daily Excel Data</label>
                <input type="file" name="excelData" accept=".xlsx" required>
            </div>
            
            <button type="submit" onclick="this.innerText='Generating...';">Process Document</button>
        </form>
    </div>
</div>

</body>
</html>
