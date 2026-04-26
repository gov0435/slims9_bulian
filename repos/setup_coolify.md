# Setup SLiMS Database - Coolify Deployment

## Environment Variables

```env
DB_HOST=123XYZ                          # container ID or hostname
DB_PORT=3306
DB_NAME=default
DB_USER=mariadb
DB_PASSWORD=passw                       # default password
APP_ENV=development
HTTP_PORT=8881
SERVICE_URL_SLIMS=http://pustaka.sslip.io
SERVICE_FQDN_SLIMS=pustaka.sslip.io
```

## Database Import Guide

### ⚠️ IMPORTANT: Use senayan_ddl.sql (NOT senayan.sql)

**senayan_ddl.sql** contains complete schema with all tables including:
- `deleted_at` column in plugins table
- `user_tokens` table for session management

### Step 1: Import Database Schema

## copy db dari service slims
```
docker cp d23f71a73297:/var/www/html/install/senayan_ddl.sql /tmp/senayan_ddl.sql
```

#### Option : Docker/Container Environment

```bash
docker exec 68a33e3b61e4 mysql -u mariadb -p'passwdd' default < /temp/senayan_ddl.sql
```

### Step 2: Verify Tables Created

Check these critical tables exist:

```sql
-- Run in MySQL/MariaDB
SHOW TABLES;

-- Should include:
-- - plugins (with deleted_at column)
-- - user_tokens
-- - users
-- - loan, member, biblio, etc.
```

### Step 3: Optional - Load Sample Data

If needed, also import sample data:

```bash
mysql -h <DB_HOST> -u <DB_USER> -p<DB_PASSWORD> <DB_NAME> < install/sampledata.sql
```

---

## Common Issues & Solutions

### Error: Unknown column 'deleted_at' in 'WHERE'

**Cause**: Used old `senayan.sql` instead of `senayan_ddl.sql`

**Solution**: 
```bash
# Drop and reimport with correct file
mysql -h <DB_HOST> -u <DB_USER> -p<DB_PASSWORD> -e "DROP DATABASE <DB_NAME>; CREATE DATABASE <DB_NAME>;"
mysql -h <DB_HOST> -u <DB_USER> -p<DB_PASSWORD> <DB_NAME> < install/senayan_ddl.sql
```

### Error: Table 'user_tokens' doesn't exist

**Cause**: Incomplete database schema

**Solution**: Ensure `senayan_ddl.sql` is fully imported (all tables created)

---

## Troubleshooting

### Test Database Connection

```bash
curl -v http://localhost/ 2>&1
```

### Check Database Logs

```bash
docker logs <mariadb_container_id>
```

### Reset Database (Development Only)

```sql
-- Backup first, then:
DROP DATABASE default;
CREATE DATABASE default;
-- Re-import senayan_ddl.sql
```