<%@ page import="java.util.*" %>
<%@ page import="com.dba.models.AdminUser" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    List<AdminUser> users = (List<AdminUser>) request.getAttribute("users");
    String errorMsg = (String) request.getAttribute("errorMsg");
    String saved = request.getParameter("saved");
    String error = request.getParameter("error");

    if (users == null) {
        users = new ArrayList<AdminUser>();
    }

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
        if (actual == null) return "";
        return actual.equalsIgnoreCase(expected) ? "selected" : "";
    }

    public String activeText(String active) {
        if ("Y".equalsIgnoreCase(active)) {
            return "Active";
        }
        return "Inactive";
    }

    public String activeClass(String active) {
        if ("Y".equalsIgnoreCase(active)) {
            return "badge-active";
        }
        return "badge-inactive";
    }

    public String roleClass(String role) {
        if ("ADMIN".equalsIgnoreCase(role)) return "badge-admin";
        if ("TEAM_LEAD".equalsIgnoreCase(role)) return "badge-lead";
        return "badge-user";
    }
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>User Management - DBA Monitor</title>

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

.notice {
    background: rgba(34,197,94,.16);
    border: 1px solid rgba(34,197,94,.35);
    color: #bbf7d0;
    padding: 12px;
    border-radius: 13px;
    margin-bottom: 14px;
    font-weight: 800;
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

.form-grid {
    display: grid;
    grid-template-columns: 1.1fr 1.1fr 1fr 1.1fr auto;
    gap: 12px;
    align-items: end;
}

label {
    display: block;
    font-size: 12px;
    color: #cbd5e1;
    font-weight: 900;
    text-transform: uppercase;
    margin-bottom: 6px;
}

input, select {
    width: 100%;
    height: 40px;
    border: 1px solid rgba(148,163,184,.30);
    background: rgba(2,6,23,.58);
    color: #e5eefb;
    border-radius: 11px;
    padding: 0 10px;
    outline: none;
}

input::placeholder {
    color: #64748b;
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
    white-space: nowrap;
}

button:hover {
    filter: brightness(1.08);
}

.btn-small {
    height: 32px;
    padding: 0 10px;
    border-radius: 9px;
    font-size: 12px;
}

.btn-secondary {
    background: rgba(148,163,184,.16);
    color: #e5eefb;
    border: 1px solid rgba(148,163,184,.25);
}

.btn-danger {
    background: #ef4444;
    color: white;
}

.btn-success {
    background: #22c55e;
    color: #052e16;
}

.table-wrap {
    overflow: auto;
    border: 1px solid rgba(148,163,184,.20);
    border-radius: 16px;
}

table {
    width: 100%;
    min-width: 1050px;
    border-collapse: collapse;
}

th, td {
    border-bottom: 1px solid rgba(148,163,184,.16);
    padding: 12px;
    text-align: left;
    vertical-align: top;
    font-size: 14px;
}

th {
    background: rgba(2,6,23,.75);
    color: #cbd5e1;
    text-transform: uppercase;
    font-size: 12px;
    font-weight: 900;
}

.user-main {
    font-weight: 900;
    color: #f8fafc;
}

.user-sub {
    margin-top: 4px;
    color: #94a3b8;
    font-size: 12px;
}

.badge {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    padding: 6px 10px;
    border-radius: 999px;
    font-size: 12px;
    font-weight: 900;
}

.badge-active {
    background: rgba(34,197,94,.16);
    color: #86efac;
}

.badge-inactive {
    background: rgba(239,68,68,.18);
    color: #fecaca;
}

.badge-admin {
    background: rgba(168,85,247,.20);
    color: #e9d5ff;
}

.badge-lead {
    background: rgba(59,130,246,.20);
    color: #bfdbfe;
}

.badge-user {
    background: rgba(34,211,238,.16);
    color: #a5f3fc;
}

.inline-form {
    display: flex;
    gap: 7px;
    align-items: center;
    margin: 0;
}

.inline-form input {
    width: 145px;
    height: 32px;
    border-radius: 9px;
    font-size: 12px;
}

.inline-form select {
    width: 120px;
    height: 32px;
    border-radius: 9px;
    font-size: 12px;
}

.action-stack {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
}

.empty {
    padding: 26px;
    text-align: center;
    color: #94a3b8;
    border: 1px dashed rgba(148,163,184,.30);
    border-radius: 16px;
}

.info-note {
    color: #94a3b8;
    font-size: 13px;
    margin-top: 10px;
    line-height: 1.5;
}

@media(max-width: 1100px) {
    .form-grid {
        grid-template-columns: 1fr 1fr;
    }
}

@media(max-width: 750px) {
    .topbar {
        align-items: flex-start;
        flex-direction: column;
    }

    .page {
        padding: 16px;
    }

    .form-grid {
        grid-template-columns: 1fr;
    }
}
</style>
</head>

<body>

<div class="page">

    <div class="topbar">
        <div>
            <h1>User Management</h1>
            <div class="subtitle">
                Admin panel to create users, reset passwords, change roles, and activate/deactivate access.
            </div>
        </div>

        <a class="back-link" href="<%= ctx %>/refreshstats">← Back to Dashboard</a>
    </div>

    <% if ("1".equals(saved)) { %>
        <div class="notice">User changes saved successfully.</div>
    <% } %>

    <% if ("selfDeactivate".equals(error)) { %>
        <div class="error">You cannot deactivate your own currently logged-in account.</div>
    <% } %>

    <% if (errorMsg != null) { %>
        <div class="error"><%= esc(errorMsg) %></div>
    <% } %>

    <div class="card">
        <h2>Create New User</h2>

        <form method="post" action="<%= ctx %>/usermanagement" onsubmit="return validateCreateUser(this);">
            <input type="hidden" name="action" value="create">

            <div class="form-grid">
                <div>
                    <label>Username</label>
                    <input type="text" name="username" placeholder="Example: v1022483" required>
                </div>

                <div>
                    <label>Password</label>
                    <input type="password" name="password" placeholder="Temporary password" required>
                </div>

                <div>
                    <label>Role</label>
                    <select name="role" required>
                        <option value="USER">USER</option>
                        <option value="TEAM_LEAD">TEAM_LEAD</option>
                        <option value="ADMIN">ADMIN</option>
                    </select>
                </div>

                <div>
                    <label>Display Name</label>
                    <input type="text" name="displayName" placeholder="Optional name">
                </div>

                <div>
                    <button type="submit">Create User</button>
                </div>
            </div>

            <div class="info-note">
                Usernames are used internally for login, task assignment, roster, monitoring audit and reports.
                Do not delete users; deactivate them if access should be removed.
            </div>
        </form>
    </div>

    <div class="card">
        <h2>Existing Users</h2>

        <% if (users.isEmpty()) { %>

            <div class="empty">No users found.</div>

        <% } else { %>

            <div class="table-wrap">
                <table>
                    <thead>
                        <tr>
                            <th>User</th>
                            <th>Role</th>
                            <th>Status</th>
                            <th>Created At</th>
                            <th>Update Display Name</th>
                            <th>Change Role</th>
                            <th>Reset Password</th>
                            <th>Access</th>
                        </tr>
                    </thead>

                    <tbody>
                    <% for (AdminUser u : users) { %>
                        <tr>
                            <td>
                                <div class="user-main"><%= esc(u.getUsername()) %></div>
                                <div class="user-sub">
                                    Display: <%= esc(u.getDisplayName()) %>
                                </div>
                            </td>

                            <td>
                                <span class="badge <%= roleClass(u.getRole()) %>">
                                    <%= esc(u.getRole()) %>
                                </span>
                            </td>

                            <td>
                                <span class="badge <%= activeClass(u.getActive()) %>">
                                    <%= activeText(u.getActive()) %>
                                </span>
                            </td>

                            <td>
                                <%= esc(u.getCreatedAt()) %>
                            </td>

                            <td>
                                <form method="post" action="<%= ctx %>/usermanagement" class="inline-form">
                                    <input type="hidden" name="action" value="updateDisplayName">
                                    <input type="hidden" name="id" value="<%= u.getId() %>">
                                    <input type="text" name="displayName" value="<%= esc(u.getDisplayName()) %>" placeholder="Display name">
                                    <button class="btn-small btn-secondary" type="submit">Save</button>
                                </form>
                            </td>

                            <td>
                                <form method="post" action="<%= ctx %>/usermanagement" class="inline-form">
                                    <input type="hidden" name="action" value="updateRole">
                                    <input type="hidden" name="id" value="<%= u.getId() %>">

                                    <select name="role">
                                        <option value="USER" <%= selected(u.getRole(), "USER") %>>USER</option>
                                        <option value="TEAM_LEAD" <%= selected(u.getRole(), "TEAM_LEAD") %>>TEAM_LEAD</option>
                                        <option value="ADMIN" <%= selected(u.getRole(), "ADMIN") %>>ADMIN</option>
                                    </select>

                                    <button class="btn-small btn-secondary" type="submit">Update</button>
                                </form>
                            </td>

                            <td>
                                <form method="post" action="<%= ctx %>/usermanagement" class="inline-form"
                                      onsubmit="return validateResetPassword(this);">
                                    <input type="hidden" name="action" value="resetPassword">
                                    <input type="hidden" name="id" value="<%= u.getId() %>">
                                    <input type="password" name="newPassword" placeholder="New password">
                                    <button class="btn-small btn-secondary" type="submit">Reset</button>
                                </form>
                            </td>

                            <td>
                                <div class="action-stack">
                                    <% if ("Y".equalsIgnoreCase(u.getActive())) { %>
                                        <form method="post" action="<%= ctx %>/usermanagement" style="margin:0;"
                                              onsubmit="return confirm('Deactivate user <%= esc(u.getUsername()) %>?');">
                                            <input type="hidden" name="action" value="deactivate">
                                            <input type="hidden" name="id" value="<%= u.getId() %>">
                                            <button class="btn-small btn-danger" type="submit">Deactivate</button>
                                        </form>
                                    <% } else { %>
                                        <form method="post" action="<%= ctx %>/usermanagement" style="margin:0;">
                                            <input type="hidden" name="action" value="activate">
                                            <input type="hidden" name="id" value="<%= u.getId() %>">
                                            <button class="btn-small btn-success" type="submit">Activate</button>
                                        </form>
                                    <% } %>
                                </div>
                            </td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>

        <% } %>
    </div>

</div>

<script>
function validateCreateUser(form) {
    var username = form.username.value.trim();
    var password = form.password.value.trim();

    if (username.length < 3) {
        alert("Username should be at least 3 characters.");
        return false;
    }

    if (password.length < 4) {
        alert("Password should be at least 4 characters.");
        return false;
    }

    return true;
}

function validateResetPassword(form) {
    var password = form.newPassword.value.trim();

    if (password.length < 4) {
        alert("New password should be at least 4 characters.");
        return false;
    }

    return confirm("Reset password for this user?");
}
</script>

</body>
</html>