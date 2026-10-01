# royal-seed-app-version

Latest published version of the Royal Seed mobile app on each store.

The app reads `version.json` on launch and prompts the user once when a newer
version is available:

```
https://raw.githubusercontent.com/QoSz/royal-seed-app-version/main/version.json
```

## How it stays current

`.github/workflows/update.yml` runs `update.sh` every hour. The script reads the
live version from the App Store (iTunes lookup API) and the Play Store (store
page) and commits `version.json` when either changes. No manual step is needed
after a release goes live.

If a store cannot be read, that platform keeps its previous value and the
workflow run fails, which sends a GitHub notification. The Play Store value is
parsed from the page HTML, so a page redesign can break it; fix the pattern in
`update.sh`, or edit `version.json` by hand in the meantime.

Run it on demand from the Actions tab, or locally with `./update.sh` (needs
`curl` and `jq`).
