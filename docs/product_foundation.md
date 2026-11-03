# FlyCalm product and monetization foundation

## Codebase audit

- Flutter application using Riverpod, GoRouter and SharedPreferences.
- Core content and three MP3 tracks are bundled; there are no remote API dependencies or advertising SDKs.
- Existing features before this iteration: onboarding, active-flight timer, breathing, turbulence reassurance, settings and bundled audio.
- Added foundation: local analytics queue, returning-user counters, next-flight planning/countdown, takeoff/panic/landing support, contextual Premium screen, Play lifetime purchase/restore, durable offline entitlement and official in-app review flow.

## Event dictionary

Only enumerated selections, counts, booleans, durations and coarse context names may be attached. Never attach free-text anxiety descriptions, route text, dates, names, email addresses or other personal data.

The implemented event surface covers `app_open`, onboarding, fear selection, next flight, breathing, grounding, flight modes, preparation, flight completion and the complete Premium funnel. Events are stored locally first in `analytics_pending_events_v1`, capped at 500 events. A production transport still needs to be configured to upload queued events to the selected analytics backend.

Suggested dashboard funnel:

1. `onboarding_started` → `onboarding_completed`
2. completion → first `breathing_completed` or `grounding_completed`
3. first useful action → later `app_open` with `returning_user = true`
4. retained use → `premium_screen_viewed` → `premium_cta_clicked`
5. CTA → `purchase_started` → `purchase_completed`

## Measurement scorecard

| Area | Weekly metrics |
|---|---|
| Acquisition | Play listing visitors, listing conversion, installs |
| Activation | Onboarding completion, first exercise completion, next-flight creation |
| Engagement | DAU/MAU, exercises completed, modes used |
| Retention | Returning users, repeat pre-flight usage |
| Monetization | Premium views, purchase starts/completions/failures, paywall conversion, gross/net revenue |

Record the current baseline (87 installs per 28 days, 26.8% listing conversion) before releasing. Review cohorts at 150, 300 and 500 monthly installs. Treat 3.5% purchase conversion and 10 sales/month as hypotheses, not forecasts.

## Play Console setup

1. Create a one-time in-app product with the exact ID `flycalm_premium_lifetime`.
2. Set localized prices in Play Console; the UI reads the price returned by Google Play and does not hard-code €9.99.
3. Upload a signed App Bundle to an internal testing track and add license testers.
4. Test purchase success, cancellation, pending purchase, refund/revocation and restore after reinstall.
5. Before production scale, verify purchase tokens on a trusted backend. The current client-side entitlement is an initial foundation, not fraud-resistant verification.

## Offline release checklist

Run on a physical Android device from a release-like build:

1. Complete onboarding and save a next flight while online.
2. Verify Premium through Play, then force-stop the app.
3. Disable Wi-Fi and mobile data; enable airplane mode.
4. Relaunch and verify home, countdown, preparation, breathing, grounding, takeoff, turbulence, panic, landing, bundled audio, settings and Premium entitlement.
5. Keep each mode open for five minutes, rotate/background/restore, and confirm there are no spinners, broken loading states, freezes or crashes.
6. Reconnect and confirm queued analytics upload after the production transport is added.

Automated tests confirm local persistence and date/countdown behavior, but they do not replace this device checklist.

## Store listing draft (review only)

- Title concept: **FlyCalm: Fear of Flying**
- Short description: **Flight anxiety support for takeoff, turbulence and panic.**
- Core message: **Fly with a plan, not with fear.**
- Screenshot sequence: nervous about your next flight; prepare before takeoff; stay grounded during turbulence; panic—one tap, start breathing; understand sounds and sensations; calming tools work offline; fly with a plan, not with fear.

Do not publish these changes without reviewing Play metadata limits, screenshots on real devices and current policy requirements.
