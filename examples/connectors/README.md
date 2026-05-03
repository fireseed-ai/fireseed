# Sample OpenAPI specs for the connector admin

Paste any of these into **Admin → APIs → Add connector** with auth type
**No auth**:

| File | Upstream | Why use it |
|---|---|---|
| `cat-facts.json` | https://catfact.ninja | Smallest possible test. `GET /fact` returns one fact. Verifies the no-auth proxy path end-to-end. |
| `open-meteo.json` | https://api.open-meteo.com/v1 | Real, useful API for weather-app demos. Forecast endpoint with `current`, `hourly`, `daily` variables. |

Quick verify after adding (replace `<connector>` with the slug you used):

```bash
curl -H "Authorization: Bearer $FIRESEED_PROJECT_TOKEN" \
  https://fireseed.lamb-mirach.ts.net/api/proxy/<connector>/fact
```

Or read the spec back via the new spec endpoint:

```bash
curl -H "Authorization: Bearer $FIRESEED_PROJECT_TOKEN" \
  https://fireseed.lamb-mirach.ts.net/api/connectors/<connector>/openapi.json
```
