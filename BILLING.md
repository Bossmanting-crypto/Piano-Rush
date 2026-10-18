# Payments

No payment path is wired up. `Billing.provider` is null, buy buttons report
that purchases are unavailable, and nothing is granted without a provider.
Pick one of the options below when building the Android app.

## Products

Three one-time products, one per song pack:

| Product ID | Pack |
|---|---|
| `pack_classics` | Classics Pack |
| `pack_masters` | Masters Pack |
| `pack_pop` | Pop Favourites |

Create them in Play Console as one-time products, not consumables. Don't set
prices in the app — Play handles local currency. M-Pesa is an accepted Play
payment method in Kenya, so Play billing doesn't cost local reach.

Notes are earned only, never sold. Selling currency means tracking balances,
restores, refunds on unspent notes and a shutdown plan.

## Option A — Trusted Web Activity

```bash
npm i -g @bubblewrap/cli
bubblewrap init --manifest https://yourdomain/manifest.json
# enable Play Billing when prompted
bubblewrap build
```

Already handled in code: `getDigitalGoodsService('https://play.google.com/billing')`,
`getDetails` for prices, `PaymentRequest` to buy, `listPurchases` to restore.
Needs the game served over HTTPS with Digital Asset Links.

## Option B — Capacitor / native bridge

Expose `AndroidBilling` on the WebView:

```js
window.AndroidBilling = {
  getPrices(),            // JSON: {"pack_classics":"KSh 250", ...}
  async purchase(sku),    // resolves {sku, token}
  async getOwned()        // JSON array of owned SKUs
}
```

Back it with the Play Billing Library, or RevenueCat to avoid running a server.

## Server verification

`Billing.verifyAndGrant()` has the hook. Before unlocking:

1. POST `{sku, token}` to the backend
2. Call `purchases.products.get` (Play Developer API) to confirm the purchase
3. Acknowledge it — unacknowledged purchases are auto-refunded after 3 days
4. Unlock on the client

Client-side grants can be faked on a rooted device.

## Entitlements

Unlocks live in `localStorage`, which is cleared by "clear data" and doesn't
move to a new device. Restore covers paid unlocks; notes-bought unlocks are
lost. Play Games Services sign-in plus server-side entitlements fixes this.

## Checklist

- Payments profile created (Kenya is a supported merchant location)
- Products active and tested from a closed test track
- Licence-tester accounts added
- Data safety form and privacy policy URL live
