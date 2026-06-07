## Troubleshooting

### WordPress Behind Traefik (Gutenberg / REST API Fix)

If you encounter the error **"Updating failed. Could not get a valid response from the server."** when trying to publish or update posts, it means WordPress cannot properly detect that it is running over HTTPS behind the Traefik reverse proxy.

To resolve this SSL header issue, open your `wp-config.php` file and add the following line at the very top, right after the opening `<?php` tag:

```php
<?php
/** Fix for WordPress behind Traefik Reverse Proxy */
$_SERVER['HTTPS'] = 'on';

// ... rest of your wp-config.php code
