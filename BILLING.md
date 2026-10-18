# Piano Rush — wiring up real payments

The game ships with no working payment path. `Billing.provider` is `null`, every
buy button says so honestly, and nothing is ever granted for free. Pick one of
the two options below when you build the Android app.

## What you are selling

Three one-time products, one per song pack:

| Play Console product ID | Pack |
|---|---|
| `pack_classics` | Classics Pack |
| `pack_masters` | Masters Pack |
| `pack_pop` | Pop Favourites |

Create them in Play Console as **one-time products**, not consumables, and do not
set prices in the app — Play converts and displays local currency itself. Kenyan
players can pay with M-Pesa inside Play, so using Play billing costs you no
local reach.

There is no purchasable currency. Notes are earned only, which keeps you out of
balance-tracking, refunds on unspent currency, and shutdown obligations.

## Option A — Trusted Web Activity (least work)

Wrap the HTML with [Bubblewrap](https://github.com/GoogleChromeLabs/bubblewrap)
and enable Play Billing:

```bash
npm i -g @bubblewrap/cli
bubblewrap init --manifest https://yourdomain/manifest.json
# answer "yes" to: Do you want to enable Play Billing?
bubblewrap build
```

The game already detects this path: it calls `getDigitalGoodsService('https://play.google.com/billing')`,
reads prices with `getDetails`, buys with `PaymentRequest`, and restores with
`listPurchases`. No code changes needed. Requires your content to be served from
a real HTTPS domain with Digital Asset Links.

## Option B — Capacitor / native bridge (more control)

Wrap with Capacitor and expose an object named `AndroidBilling` on the WebView
with three methods:

```js
window.AndroidBilling = {
  getPrices(),            // returns JSON: {"pack_classics":"KSh 250", ...}
  async purchase(sku),    // launches Play's sheet, resolves {sku, token}
  async getOwned()        // returns JSON array of owned SKUs
}
```

That is the whole contract the game expects. Underneath, use the Play Billing
Library, or RevenueCat if you would rather not run a server.

## The server step — do not skip it

`Billing.verifyAndGrant()` has the hook marked. Before unlocking a pack:

1. POST `{sku, token}` to your backend.
2. Backend calls Play Developer API `purchases.products.get` with a service
   account to confirm the purchase is real and unconsumed.
3. Backend **acknowledges** the purchase. Google auto-refunds anything not
   acknowledged within three days.
4. Only then does the client unlock.

Granting on the client alone is trivially faked on a rooted phone.

## Entitlements and reinstalls

Unlocks currently live in `localStorage`, which is wiped by "clear data" and
does not follow the player to a new phone. `Restore purchases` covers money
purchases through the store. Notes-bought unlocks are lost. If that matters,
add a lightweight account (Play Games Services sign-in is enough) and store
entitlements server-side keyed to the player ID.

## Play Console checklist for payments

- Payments profile created; Kenya is a supported merchant location.
- Products active, and tested through a **closed test track** — billing does not
  work on locally installed debug builds.
- License-tester accounts added so you can buy without being charged.
- Data safety form filled in, privacy policy URL live.
