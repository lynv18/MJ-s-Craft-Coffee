# MJS Craft Coffee App

Isang cross-platform mobile application para sa **MJS Craft Coffee**, na ginawa gamit ang **Flutter** at pinapagana ng **Supabase** backend kasama ang **Xendit** payment gateway integration para sa online ordering at checkout.

---

## Mga Pangunahing Feature
- **User Authentication:** Secure sign up at login gamit ang Supabase Auth.
- **Dynamic Product Catalog:** Real-time na listahan ng mga kape na naka-synchronize sa Supabase database na may mga kategorya at presyo ayon sa size (Small, Medium, Large).
- **Interactive Cart System:** Madaling pagdaragdag at pagbawas ng dami at sukat ng mga inuming napili.
- **Xendit Payment Integration:** Suporta sa online payments gamit ang mga generated invoice at secure web redirection.
- **Order Tracking:** Awtomatikong pag-save ng mga order sa database para sa pamamahala ng mga benta.

---

## Tech Stack
- **Frontend:** Flutter (Dart)
- **Backend & Database:** Supabase (PostgreSQL)
- **Payment Gateway:** Xendit API
- **Packages/Plugins:** `supabase_flutter`, `url_launcher`, `provider` / `ChangeNotifier`

---

## Gabay sa Pag-install (Installation Guide)

Sundan ang mga hakbang na ito para ma-clone at mapagana ang proyektong ito sa iyong local development environment.

### Mga Kailangan (Prerequisites)
Siguraduhing naka-install ang mga sumusunod sa iyong computer:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Latest stable version)
- Android Studio / VS Code na may mga Flutter extensions
- Isang active internet connection (para sa Supabase at Xendit API calls)

### 1. I-clone ang Repository
Buksan ang iyong terminal o command prompt at i-clone ang repository na ito:
```bash
git clone [https://github.com/lynv18/MJ-s-Craft-Coffee.git](https://github.com/lynv18/MJ-s-Craft-Coffee.git)
cd mjs_craft_coffee