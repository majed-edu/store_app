# Store App

A Flutter shopping app built on [FakeStoreAPI](https://fakestoreapi.com), with two types of users:

- **Shopper:** browse products, save favorites, manage a cart, place orders, and track them.
- **Merchant:** manage products and update order status.

There are no predefined accounts. Create one from the app and choose whether you want to shop or sell.

## Main features

- Product browsing, search, categories, sorting, and product details
- Favorites, cart, checkout, and order tracking
- Merchant dashboard with products and orders
- Login and sign up, with the session remembered
- Account, cart, favorites, and orders stored locally on the device

## Run the app

Make sure Flutter is installed, then run:

```bash
flutter pub get
flutter run
```

## Test the app

```bash
flutter test
```

## Create an account

1. Open the app and select **Create an account**.
2. Enter your details.
3. Choose **Shop** or **Sell**.
4. Log in with the username and password you created.

## Good to know

- FakeStoreAPI is a mock API: it accepts requests but does not save anything. New accounts, orders, and merchant changes are stored on the device only and are not shared between devices.
- The store is a single shared catalog: all merchants see and manage the same products and orders. A multi-vendor model is out of scope for this project.

## Project structure

```text
lib/
  core/       configuration, validation, formatting, and routing
  helper/     HTTP helper
  models/     product, user, and order models
  services/   API services
  providers/  application state
  storage/    local storage
  theme/      colors and typography
  widgets/    reusable UI components
  screens/    authentication, shopper, merchant, and shared screens
```

