UI widgets (reusable)

RideCard — shows route, price per seat, seats left, ETA

MapView — wrapper for Google Map + markers + polyline

SeatSelector — pick number of seats

RoutePreview — shows route polyline and stops

PrimaryButton, PrimaryInput, ConfirmDialog, Badge (for counts)

API design recommendations (server-side must-haves)

Your client heavily depends on the backend correctness. Tell backend folks to implement:

Atomic seat reservation: endpoint POST /offers/:id/reserve must use DB transaction and return updated RideOffer or error "no seats".

Socket events: ride.created, ride.updated, ride.requested, ride.started, ride.completed

Filtering/search: server accepts fromLat, fromLng, radius, departureTimeWindow, toLat, toLng and returns matches

In-transit acceptance: endpoint to request pickup in-route; driver can accept via POST /offers/:id/requests

Verification workflow: driver uploads docs -> store & manual/auto verification -> driver status on profile

Authorization: JWT tokens; check driver vs passenger role

Payments: Reserve-charge flow if using prepayment (or collect on trip end)

Important UX rules & behaviours

Driver sets totalSeats and pricePerSeat when creating ride.

Driver can choose to autoStart when X seats filled or manually start.

Accept-in-transit logic should handle detour distance threshold and driver confirmation UI.

Show countdown / hold time for pending passenger requests.

Show clear status badges (Waiting / Boarding / OnTrip / Completed / Cancelled).

Edge cases & robustness

Race conditions: always trust server result after optimistic UI update; rollback if server rejects.

Offline: queue actions (e.g., photo upload for verification) or show offline warning.

Location accuracy & permissions — request high-accuracy and show fallback.

Security — store JWT in flutter_secure_storage; never in SharedPreferences.

Testing: unit test providers, integration test end-to-end (create offer -> passenger reserve -> driver start).

Quick example: how a driver creates a ride (flow)

Driver -> CreateRideScreen (fill start/end, seats, price, time)

UI calls rideProvider.createOffer(payload) -> RideService.createOffer -> POST to server

Server returns created offer and broadcasts ride.created to sockets

Nearby passengers receive a push/socket notification and see the offer in SearchRidesScreen

Passengers request/accept seat -> server updates offer and broadcasts ride.updated

Driver sees requests in RideRequestsScreen and accepts them (or auto-accept if configured)

When ready driver clicks Start -> call rideService.startRide -> server sets status active and notifies passengers

Prioritization (what to build first)

RideOffer model + ride_service.createOffer + create_ride_screen (driver create flow)

search_rides_screen + ride_card + ride_service.searchOffers (passenger discovery)

Socket infra (socket_service) for real-time updates

acceptSeat atomic flow + optimistic UI + backend seat reservation

ride_requests_screen (driver accepts in-transit) + detour/accept logic

Driver verification screen + backend doc upload

History & earnings

Final notes — pragmatic tips

Keep auth screens in screens/auth (you already have them). Make AuthProvider expose token and user and inject token into services via storage_service.

Keep RideService stateless — pass token from provider or use interceptor.

Reuse components: RideCard for both driver and passenger lists.

Use StreamProvider for socket-driven real-time updates where needed.

Keep UI accessible (big buttons for drivers while driving).

If you want, I’ll do one of the following right now (pick one, no waiting required — I’ll produce code immediately):

Scaffold providers/ride_provider.dart full file

Scaffold services/socket_service.dart full file

Implement screens/driver/create_ride_screen.dart UI + form + provider hooks

Generate JSON API example payloads for server devs

Say which one you want me to drop into the chat and I’ll paste a ready-to-paste Dart file. No fluff — just code.