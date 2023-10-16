Project Scope:
  - It is needed to create an API for simple hotel reservation app that allows users to
    reserve rooms when these rooms are available

Project features:
  1. Registration
      - User should be able to register with name, email and password
  2. Sign in
      - User should be able to sign in with previously registered email and password.
  3. Listing all rooms
  4. create room
  5. update specific room details
  6. create reservation for a specific room for a definite period of time
  7. show all reservation in a specific period of time
  8. cancel reservation

Steps to set up the project:
  - run `docker-compose up --build` to start the app

List of endpoint to use the app:
  1. registration  POST /auth
      request body {name: 'hadi', email: 'hadi@hadi.com', password: 'hadi1234'}

  2. sign-in  POST /auth/sign_in (this method generates the headers required to access other endpoint)
      request body {email: 'hadi@hadi.com', password: 'hadi1234'}
      this request return in the headers these attributes which are required to be sent in the headers of any request
      that requires authentication [access-token, token-type, client, uid, expiry]

  3. List rooms GET /rooms requires authentication using request num 2
      all users can list all rooms
      request headers {access-token: '', token-type: '', client: '', uid: '', expiry: ''}

  4. create room POST /rooms requires authentication using request num 2
      only admins can create rooms
      request headers {access-token: '', token-type: '', client: '', uid: '', expiry: ''}
      request body { room: { price_per_night: DECIMAL, capacity: INTEGER. description: TEXT } }

  5. update room (PATCH/PUT) /rooms/:room_id requires authentication using request num 2
      only admins can update rooms
      request headers {access-token: '', token-type: '', client: '', uid: '', expiry: ''}
      request body { room: { price_per_night: DECIMAL, capacity: INTEGER. description: TEXT } }

  6. create room_reservation POST /room_reservations requires authentication using request num 2
      admin can create to any user but guest users can only create their own
      request headers {access-token: '', token-type: '', client: '', uid: '', expiry: ''}
      request body { room_reservation: { check_in: DATE, check_out: DATE. room_id: ROOM_REFERENCE } }

  7. list room_reservations for a specific period GET /room_reservations/within_range?room_reservation[check_in]=DATE&room_reservation[check_out]=date requires authentication using request num 2
      admin can fetch reservations of any user but guest users can only fetch their own
      request headers {access-token: '', token-type: '', client: '', uid: '', expiry: ''}

  8. cancel room_reservation POST /room_reservations/:room_id/cancel requires authentication using request num 2
      admin can cancel reservations of any user but guest users can only cancel their own 
      request body { room: { price_per_night: DECIMAL, capacity: INTEGER. description: TEXT } }
