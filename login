<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
String error = request.getParameter("error");
String logout = request.getParameter("logout");

String message = "";

if("1".equals(error)){
    message = "Invalid username or password.";
}else if("db".equals(error)){
    message = "MySQL login is currently unavailable. Use emergency login only if approved.";
}else if("system".equals(error)){
    message = "Login system error. Please check server logs.";
}else if("1".equals(logout)){
    message = "You have logged out successfully.";
}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Login - DBA Monitor</title>

<style>
*{
    margin:0;
    padding:0;
    box-sizing:border-box;
    font-family:"Segoe UI", Arial, sans-serif;
}

body{
    height:100vh;
    background:
        radial-gradient(circle at top left, rgba(34,211,238,.24), transparent 35%),
        radial-gradient(circle at bottom right, rgba(14,165,233,.24), transparent 35%),
        linear-gradient(135deg,#08111f,#102033);
    display:flex;
    align-items:center;
    justify-content:center;
    color:#f8fafc;
}

.login-card{
    width:430px;
    background:rgba(15,23,42,.94);
    border:1px solid rgba(255,255,255,.12);
    border-radius:24px;
    box-shadow:0 24px 70px rgba(0,0,0,.38);
    padding:34px;
}

.logo{
    display:flex;
    align-items:center;
    gap:12px;
    margin-bottom:24px;
}

.logo-icon{
    width:44px;
    height:44px;
    border-radius:14px;
    background:linear-gradient(135deg,#22d3ee,#0284c7);
    display:flex;
    align-items:center;
    justify-content:center;
    font-weight:900;
    box-shadow:0 12px 25px rgba(34,211,238,.28);
}

.logo h1{
    font-size:24px;
    letter-spacing:.4px;
}

.logo span{
    color:#67e8f9;
}

.subtitle{
    color:#b7c4d5;
    font-size:14px;
    margin-bottom:24px;
}

.form-group{
    margin-bottom:16px;
}

label{
    display:block;
    margin-bottom:7px;
    color:#cbd5e1;
    font-weight:800;
    font-size:14px;
}

input{
    width:100%;
    height:46px;
    border-radius:13px;
    border:1px solid #334155;
    background:#111827;
    color:#fff;
    padding:0 14px;
    font-size:15px;
    outline:none;
}

input:focus{
    border-color:#22d3ee;
    box-shadow:0 0 0 3px rgba(34,211,238,.13);
}

button{
    width:100%;
    height:46px;
    margin-top:8px;
    border:none;
    border-radius:13px;
    background:linear-gradient(135deg,#0ea5e9,#22d3ee);
    color:white;
    font-size:15px;
    font-weight:900;
    cursor:pointer;
    box-shadow:0 12px 24px rgba(14,165,233,.25);
}

.message{
    margin-bottom:16px;
    padding:11px 13px;
    border-radius:12px;
    background:rgba(14,165,233,.12);
    border:1px solid rgba(14,165,233,.28);
    color:#e0f2fe;
    font-size:14px;
    font-weight:700;
}

.error{
    background:rgba(239,68,68,.12);
    border-color:rgba(239,68,68,.35);
    color:#fecaca;
}

.footer{
    margin-top:22px;
    text-align:center;
    color:#94a3b8;
    font-size:12px;
}
</style>
</head>

<body>

<div class="login-card">

    <div class="logo">
        <div class="logo-icon">DB</div>
        <div>
            <h1>DBA <span>MONITOR</span></h1>
            <div class="subtitle">Secure login for monitoring dashboard</div>
        </div>
    </div>

    <% if(message != null && !message.trim().equals("")){ %>
        <div class="message <%= ("1".equals(error) || "db".equals(error) || "system".equals(error)) ? "error" : "" %>">
            <%= message %>
        </div>
    <% } %>

    <form action="<%= request.getContextPath() %>/login" method="post">

        <div class="form-group">
            <label>Username</label>
            <input type="text" name="username" autocomplete="username" required>
        </div>

        <div class="form-group">
            <label>Password</label>
            <input type="password" name="password" autocomplete="current-password" required>
        </div>

        <button type="submit">Login</button>

    </form>

    <div class="footer">
        SBI DBA internal dashboard
    </div>

</div>

</body>
</html>