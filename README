# easeflow

**easeflow** is a cross‑platform task‑management & profile app aimed at helping autistic
children become more independent.  
A guardian signs up, links one or more children, and then creates simple, step‑by‑step
tasks for them. Children have a very light UI with big buttons and can mark tasks as
completed. The app also allows storing personalised profile information (reading level,
preferred tone, emoji usage, etc.) that can later be used by other parts of the system.

> The project was built during 2024‑2025 by Dimitar Binev and the code is released under
> the MIT licence.

---

## Key ideas

* **Role‑based accounts** – “guardian” and “child” users share the same Firebase
  authentication but see different screens.
* **Task management** – guardians can create tasks and add ordered steps (with emoji /
  image support). Children can view and check off tasks.
* **Profiles for children** – the guardian enters information to tailor the experience:
  tone, step length, reading level, colour preferences, etc.
* **Lightweight, accessible UI** – large buttons, simple navigation, and optional dark/
  light theme switching. Mobile UI is responsive and also built for desktop
  (Windows/Linux/macOS) via Flutter’s multi‑platform support.
* **Backend‑as‑service** – an Express server uses Firebase Admin to manage users,
  profiles and tasks, with token verification middleware. There is even a simple
  AI endpoint (`/ai/generate`) powered by a Flan‑T5 model for generating text prompts,
  though it’s optional.

The primary audience is autistic children and their guardians; the goal is to provide a
structured but flexible “to‑do list” experience that encourages independence.

---

## Project structure

```
/backend          ← Express + Firebase Admin API
    server.ts
    config/firbase.ts
    controllers/
      authControllers.ts
      taskController.ts
      userController.ts
      …
    middleware/middleware.ts
    routes/
      authRoutes.ts
      taskRoutes.ts
      profileRoutes.ts
      aiRoutes.ts
/mobile/easeflow  ← Flutter multi‑platform client
    lib/           ← Dart source
      pages/       ← UI screens
      widgets/     ← common scaffolds
      models/      ← TaskModel etc.
      firebase_options.dart
      main.dart
    android/ ios/ linux/ macos/ web/ windows/ …  ← platform projects
    pubspec.yaml
```

---

## Features at a glance

* **Authentication** via Firebase (email/password).
* **Signup flow** with role selection (guardian/child) and guardian linking.
* **Guardian dashboard**: create/manage tasks, view linked children, edit profiles.
* **Child dashboard**: big “TASKS” button, simple list with completion toggles.
* **Settings**: logout, change password, switch theme.
* **Profile screen** for entering child information used by the backend.
* **Backend routes**:
  * `POST /auth/sign_up` – create user & Firestore document
  * `GET /auth/me` – fetch profile
  * `POST /tasks` – create task
  * `POST /tasks/:taskId/steps` – add step
  * `GET /tasks/child/:childUid` – list tasks
  * `POST /profile` – save child profile
  * `POST /ai/generate` – (optional) text‑generation helper
* **Middleware** for token verification and error handling (`verifyToken`, `catch_async`).

---

## Technology stack

* **Backend**: Node.js, Express, TypeScript, Firebase Admin SDK, Firestore.
* **Mobile/desktop**: Flutter (Dart) with packages:
  * `firebase_auth`, `firebase_core`
  * `http`
  * `flutter_dotenv`
* **AI service**: `@xenova/transformers` with a Flan‑T5 model.
* **Cross‑platform build**: standard Flutter CMake projects for Windows/Linux/macOS.

---

## Getting started

1. **Firebase setup**
   * Create a Firebase project and download the service account key as
     `backend/serviceAccountKey.json`.
   * Add your `FIREBASE_WEB_API_KEY` to a `.env` file in `backend/`.
   * In the Flutter client, set the corresponding values in
     `lib/firebase_options.dart` or use `flutterfire` CLI to regenerate.

2. **Backend**
   ```sh
   cd backend
   npm install
   npm run build          # compile TypeScript
   npm start              # or `npm run dev` for nodemon
   ```
   The server listens on `PORT` (default `3000`). Use `testing.rest` with
   VS Code’s REST Client extension for quick manual requests.

3. **Mobile client**
   ```sh
   cd mobile/easeflow
   flutter pub get
   flutter run            # specify a device or platform (e.g. `-d windows`)
   ```

   Ensure you have a `.env` file at the project root containing the backend
   URL (`BACKEND_URL` or hard‑coded strings in the Dart sources).  
   Alternatively, update the `baseUrl` constants directly in the Dart pages.

4. **Desktop builds**
   * **Windows**: open the generated Visual Studio solution under
     `mobile/easeflow/windows/` or use `flutter build windows`.
   * **Linux/macOS**: run `flutter build linux` or `flutter build macos`.

5. **Usage**
   * Sign up as a guardian, or as a child (enter guardian ID).
   * Guardians create tasks for each child using the drawer menu.
   * Children log in and complete their tasks; profiles can be edited via
     the “Person Info” page.

---

## Extending & development notes

* **Adding plugins** – the platform CMake files already include generated
  plugin registrants (`generated_plugin_registrant.*`), just run
  `flutter pub get` and `flutter clean` when adding new pub packages.
* **Firestore structure**
  * `users` collection: stores role/links.
  * `tasks` collection: each doc has `steps` subcollection.
  * `child_profiles` collection for extra settings.
* **Error handling** – backend uses `catch_async` to wrap controllers; add more
  loggers as needed.
* **AI endpoint** – located in `backend/src/services/flan.services.ts`; you can
  swap the model or expose more parameters.

---

## License

This project is released under the [MIT License](LICENSE).

---

Thank you for building easeflow – helping autistic individuals take control of
their daily routine, one task at a time.  
Feel free to contribute or adapt the code to better serve your community.# easeflow

**easeflow** is a cross‑platform task‑management & profile app aimed at helping autistic
children become more independent.  
A guardian signs up, links one or more children, and then creates simple, step‑by‑step
tasks for them. Children have a very light UI with big buttons and can mark tasks as
completed. The app also allows storing personalised profile information (reading level,
preferred tone, emoji usage, etc.) that can later be used by other parts of the system.

> The project was built during 2024‑2025 by Dimitar Binev and the code is released under
> the MIT licence.

---

## Key ideas

* **Role‑based accounts** – “guardian” and “child” users share the same Firebase
  authentication but see different screens.
* **Task management** – guardians can create tasks and add ordered steps (with emoji /
  image support). Children can view and check off tasks.
* **Profiles for children** – the guardian enters information to tailor the experience:
  tone, step length, reading level, colour preferences, etc.
* **Lightweight, accessible UI** – large buttons, simple navigation, and optional dark/
  light theme switching. Mobile UI is responsive and also built for desktop
  (Windows/Linux/macOS) via Flutter’s multi‑platform support.
* **Backend‑as‑service** – an Express server uses Firebase Admin to manage users,
  profiles and tasks, with token verification middleware. There is even a simple
  AI endpoint (`/ai/generate`) powered by a Flan‑T5 model for generating text prompts,
  though it’s optional.

The primary audience is autistic children and their guardians; the goal is to provide a
structured but flexible “to‑do list” experience that encourages independence.

---

## Project structure

```
/backend          ← Express + Firebase Admin API
    server.ts
    config/firbase.ts
    controllers/
      authControllers.ts
      taskController.ts
      userController.ts
      …
    middleware/middleware.ts
    routes/
      authRoutes.ts
      taskRoutes.ts
      profileRoutes.ts
      aiRoutes.ts
/mobile/easeflow  ← Flutter multi‑platform client
    lib/           ← Dart source
      pages/       ← UI screens
      widgets/     ← common scaffolds
      models/      ← TaskModel etc.
      firebase_options.dart
      main.dart
    android/ ios/ linux/ macos/ web/ windows/ …  ← platform projects
    pubspec.yaml
```

---

## Features at a glance

* **Authentication** via Firebase (email/password).
* **Signup flow** with role selection (guardian/child) and guardian linking.
* **Guardian dashboard**: create/manage tasks, view linked children, edit profiles.
* **Child dashboard**: big “TASKS” button, simple list with completion toggles.
* **Settings**: logout, change password, switch theme.
* **Profile screen** for entering child information used by the backend.
* **Backend routes**:
  * `POST /auth/sign_up` – create user & Firestore document
  * `GET /auth/me` – fetch profile
  * `POST /tasks` – create task
  * `POST /tasks/:taskId/steps` – add step
  * `GET /tasks/child/:childUid` – list tasks
  * `POST /profile` – save child profile
  * `POST /ai/generate` – (optional) text‑generation helper
* **Middleware** for token verification and error handling (`verifyToken`, `catch_async`).

---

## Technology stack

* **Backend**: Node.js, Express, TypeScript, Firebase Admin SDK, Firestore.
* **Mobile/desktop**: Flutter (Dart) with packages:
  * `firebase_auth`, `firebase_core`
  * `http`
  * `flutter_dotenv`
* **AI service**: `@xenova/transformers` with a Flan‑T5 model.
* **Cross‑platform build**: standard Flutter CMake projects for Windows/Linux/macOS.

---

## Getting started

1. **Firebase setup**
   * Create a Firebase project and download the service account key as
     `backend/serviceAccountKey.json`.
   * Add your `FIREBASE_WEB_API_KEY` to a `.env` file in `backend/`.
   * In the Flutter client, set the corresponding values in
     `lib/firebase_options.dart` or use `flutterfire` CLI to regenerate.

2. **Backend**
   ```sh
   cd backend
   npm install
   npm run build          # compile TypeScript
   npm start              # or `npm run dev` for nodemon
   ```
   The server listens on `PORT` (default `3000`). Use `testing.rest` with
   VS Code’s REST Client extension for quick manual requests.

3. **Mobile client**
   ```sh
   cd mobile/easeflow
   flutter pub get
   flutter run            # specify a device or platform (e.g. `-d windows`)
   ```

   Ensure you have a `.env` file at the project root containing the backend
   URL (`BACKEND_URL` or hard‑coded strings in the Dart sources).  
   Alternatively, update the `baseUrl` constants directly in the Dart pages.

4. **Desktop builds**
   * **Windows**: open the generated Visual Studio solution under
     `mobile/easeflow/windows/` or use `flutter build windows`.
   * **Linux/macOS**: run `flutter build linux` or `flutter build macos`.

5. **Usage**
   * Sign up as a guardian, or as a child (enter guardian ID).
   * Guardians create tasks for each child using the drawer menu.
   * Children log in and complete their tasks; profiles can be edited via
     the “Person Info” page.

---

## Extending & development notes

* **Adding plugins** – the platform CMake files already include generated
  plugin registrants (`generated_plugin_registrant.*`), just run
  `flutter pub get` and `flutter clean` when adding new pub packages.
* **Firestore structure**
  * `users` collection: stores role/links.
  * `tasks` collection: each doc has `steps` subcollection.
  * `child_profiles` collection for extra settings.
* **Error handling** – backend uses `catch_async` to wrap controllers; add more
  loggers as needed.
* **AI endpoint** – located in `backend/src/services/flan.services.ts`; you can
  swap the model or expose more parameters.

---

## License

This project is released under the [MIT License](LICENSE).

---

Thank you for building easeflow – helping autistic individuals take control of
their daily routine, one task at a time.  
Feel free to contribute