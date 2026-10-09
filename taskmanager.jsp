<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>EIS Report Automation</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Verdana, sans-serif; background-color: #f4f6f9; padding: 40px; }
        .dashboard-container { max-width: 500px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1); border-top: 5px solid #2f5496; }
        h2 { color: #333; margin-top: 0; }
        .upload-section { margin: 25px 0; padding: 20px; border: 2px dashed #ccc; border-radius: 6px; text-align: center; background-color: #fafafa; }
        .generate-btn { background-color: #2f5496; color: white; padding: 12px 24px; border: none; border-radius: 4px; font-size: 16px; font-weight: bold; cursor: pointer; width: 100%; transition: 0.3s; }
        .generate-btn:hover { background-color: #1a365d; }
    </style>
</head>
<body>
    <div class="dashboard-container">
        <h2>Daily UAT Report Generator</h2>
        <p>Upload today's <strong>Book1.xlsx</strong> to generate the completed Word document.</p>
        
        <!-- Enctype is required for handling file uploads in servlets -->
        <form action="ReportGeneratorServlet" method="POST" enctype="multipart/form-data">
            <div class="upload-section">
                <input type="file" name="excelData" accept=".xlsx" required />
            </div>
            <button type="submit" class="generate-btn" onclick="this.innerText='Generating... Please wait';">Generate Report</button>
        </form>
    </div>
</body>
</html>
