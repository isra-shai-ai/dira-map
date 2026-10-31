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

## v2 data fields (listings.json)
- `price_history`: `[{date, price}]`. Seeded with `first_seen`. **The daily update appends `{date: today, price}` whenever a listing's price changes.** It never rewrites older entries. When the latest price is lower than the previous one, the card shows a "⬇ ירד" badge and the listing is caught by the "רק ירידות מחיר" filter.
- `building_check`: `{status, source_url, checked_at, note}`. `status` is one of `פינוי-בינוי` | `תמ"א 38` | `לא נמצא` | `לא נבדק`.
  - Sources: TLV GIS (`gisn.tel-aviv.gov.il/arcgis/rest/services/IView2/MapServer`). Layer 772 holds building requests and permits (`sw_tama_38`, `tochen_bakasha`). Layer 528 holds plans (`sw_hitchadshut_ironit`). Then check iplan/mavat.
  - Optional `nearby_plan`: a renewal plan close to (but not covering) the building. The card shows a muted "לברר" tag for it.
  - `לא נמצא` means only that nothing was found. **It does not mean the building is verified clear.**
  - If a building is confirmed inside an approved פינוי-בינוי plan, set `removed: true`, `removed_reason` and `removed_at`, and mention it in the daily report.
- `meta.market`: benchmark per neighbourhood: `{source, url, fetched, n, basis, median, refs}`. It holds the median asking price of active 3-room ads on Realta. If n<6, `median` is null and the card falls back to "ביחס לדירות במפה", the median of the listings on the map. Refresh it every few weeks and never invent numbers. `meta.market_rule` sets the thresholds for below/above market.

## kids.geojson
Playgrounds, named parks, kindergartens and community centres from OpenStreetMap, fetched via Overpass (ODbL). The bbox is in `meta`. The layer is off by default (toggle "שכבת ילדים"), and each card shows the number of playgrounds within 400 m. Refresh it rarely by running the same Overpass query (`leisure=playground|park`, `amenity=kindergarten|community_centre`) over the bbox.

## Personal data stays on the device
- Status marks (מעניין / פניתי / ראיתי / לא רלוונטי) are kept in browser `localStorage` under `dira.status.v1`, with `dira.hideNo` alongside. Score weights are kept under `dira.weights.v1`.
- Export/import writes or reads a local JSON file only. **Never commit statuses or personal details to this public repo.**
- Score (0–100) = weighted price (≤7,000 ₪), condition, walk time, and ממ"ד/מקלט + elevator + parking. Unknown values count as neutral (0.5).

## Card design
The tap card is calm: address, then price with score, walk time and sqm, then status buttons. Status buttons are text-only, and tapping the selected one again clears it. The same muted color appears as a small dot on the map marker. At most 2 muted attention tags appear, only when relevant: תמ"א 38 in the building, a nearby פינוי-בינוי plan, or a price drop. Everything else sits under "פרטים נוספים".

## Round 3 – visual polish
- **Markers:** clean white price pills (dark text). A tiny colored dot shows your status mark; a subtle "חדש" tag appears only on new listings. The legend was removed.
- **Selection:** the selected pill turns dark and grows; all other pills fade to ~40% until the card is closed.
- **Basemap:** OSM tiles rendered in soft grayscale via a CSS filter (stays light even in forced dark mode).
- **Swipe / arrows:** with a card open, swipe horizontally (RTL: finger right → next) or use ‹ › in the card header to move through listings in the current filter + sort order; the map pans and the highlight follows. Horizontal overscroll/back-gesture is disabled on the card.
- **Photos:** `image` in listings.json is the first photo of the ad on the Yad2 CDN (img.yad2.co.il, hotlinked, checked HTTP 200 image/jpeg). If it is missing or fails to load, a gray placeholder is shown. Listings whose ad has no photos have no `image` field.
