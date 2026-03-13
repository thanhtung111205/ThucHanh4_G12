# lib/ README

This folder contains the main app code organized for a Mini E-Commerce Flutter app.

Structure overview:

- `models/` — data models (`product.dart`, `cart_item.dart`, `order.dart`).
- `services/` — network / API related code (`api_service.dart`).
- `providers/` — state management providers (`cart_provider.dart`, `order_provider.dart`).
- `screens/` — UI screens grouped by feature (`home`, `product`, `cart`, `checkout`).
- `widgets/` — reusable UI components (`product_card.dart`, `cart_item_widget.dart`, ...).
- `utils/` — utilities and formatters (`formatter.dart`).
- `main.dart` — app entry point (sample provided).

Notes:
- Files created are placeholders; implement models, providers and screens as needed.
- Replace the sample `main.dart` home with your `HomeScreen` implementation when ready.
