# dira-map – מפת דירות להשכרה (צפון תל אביב)

Static Leaflet site: `index.html` + `listings.json`. No build step.

## Daily update
1. Edit **only** `listings.json`:
   - `meta.prev_updated_at` ← the old `meta.updated_at`; `meta.updated_at` ← now, ISO with offset (e.g. `2026-11-01T09:00:00+02:00`).
   - New listing: append an object with the same fields (id, addr, hood, area = north|aviv|ne, price, rooms, sqm, floor, ad, posted, cond, notes, url, site, extra_url, lat, lon, coord_source, coord_unverified, walk_m, walk_min, line_m, status:"active") and `first_seen` = today (YYYY-MM-DD).
     Coordinates must come from the ad / a geocoder (Nominatim) – never guessed. Walking distance: OSRM foot route to the school.
   - Gone listing: set `"status": "removed"` (it is hidden) or delete it.
   - "חדש" badge = `first_seen` later than the date of `meta.prev_updated_at` (null ⇒ no badges).
2. Redeploy: `/workspace/dira-map/deploy.sh`

## Hosting
GitHub Pages, repo `dira-map`, branch main, root.
URL: https://<github-user>.github.io/dira-map/

## Local test
`cd /workspace/dira-map && python3 -m http.server 8765` → http://localhost:8765/
Screenshots: `node /tmp/pp/shot.js <url>/index.html /workspace/dira-map/previews <prefix>` (puppeteer-core in /tmp/pp, forces dark mode to prove the page stays light).

Map tiles © OpenStreetMap contributors.
