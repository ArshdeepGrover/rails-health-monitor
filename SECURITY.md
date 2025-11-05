# Security

## Authentication

The health dashboard is protected by HTTP Basic Authentication to prevent unauthorized access to sensitive application information.

### Default Credentials
- **Username:** `admin`
- **Password:** `health123`

### Custom Credentials
Set environment variables to use custom credentials:

```bash
export HEALTH_USERNAME=your_username
export HEALTH_PASSWORD=your_secure_password
```

### Security Considerations

1. **Change Default Password:** Always change the default password in production
2. **Use Strong Passwords:** Use complex passwords with mixed characters
3. **Environment Variables:** Store credentials in environment variables, not in code
4. **HTTPS Only:** Use HTTPS in production to encrypt authentication headers
5. **Access Logs:** Monitor access to health endpoints

### Endpoints Protected

- `/health` - Main health dashboard

### What Information is Exposed

The health dashboard shows:
- Rails and Ruby versions
- Database connection status
- Gem dependencies and versions
- Security vulnerabilities (outdated gems)
- Background job status
- System configuration details

**Note:** This information should only be accessible to authorized personnel.