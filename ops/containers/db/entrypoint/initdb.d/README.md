# MySQL Init Scripts

This directory contains initialization scripts executed by the MySQL container on first startup.

## Files

- `001-bootstrap.sh` - Creates the primary app database, the app user, and the optional queue database.

## Notes

- Keep these scripts focused on bootstrap only.
- Avoid application logic here.
