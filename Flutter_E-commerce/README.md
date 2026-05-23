# Clothes E-Commerce 🛒

A modern, elegant e-commerce mobile application built with Flutter that provides a seamless shopping experience with a clean and intuitive user interface.

## 📱 Screenshots

<div align="center">
  <img src="screenshots/sign_in.png" alt="Login Screen" width="250" height="500">
  <img src="screenshots/sign up.png" alt="Sign Up Screen" width="250" height="500">
  <img src="screenshots/home.png" alt="Home Screen" width="250" height="500">
  <img src="screenshots/cart.png" alt="cart Screen" width="250" height="500">
  <img src="screenshots/Item_Details.png" alt="Item_Details Screen" width="250" height="500">
</div>

## ✨ Features

### Core Functionality
- **User Authentication** - Login and Sign Up screens with form validation
- **Product Catalog** - Browse through a curated collection of products
- **Product Details** - Detailed view with product information and pricing
- **Shopping Cart** - Add/remove items with quantity management
- **Cart Calculations** - Automatic subtotal, tax, and total calculations
- **Navigation** - Smooth navigation between screens using GoRouter


### State Management
- **Provider Pattern** - Efficient cart state management
- **Real-time Updates** - Cart updates reflect across all screens
- **Form Validation** - Comprehensive input validation for authentication

### Models
- **ProductModel**: Handles product data structure and static product list
- **CartItem & CartProvider**: Manages cart functionality with Provider pattern

### Screens
- **LoginScreen**: User authentication with email/password validation
- **SignUpScreen**: New user registration with form validation
- **HomeScreen**: Main product catalog with search and filter
- **ProductDetailsScreen**: Detailed product view with add to cart
- **CartScreen**: Shopping cart with quantity controls and checkout
- **WrapperScreen**: Bottom navigation container

### Navigation
- **GoRouter**: Declarative routing with the following routes:
  - `/` - Login Screen
  - `/signup` - Sign Up Screen
  - `/wrapper` - Main App (Home, Shop, Wishlist, Cart, Profile)
  - `/product-details/:productId` - Product Details
  - `/cart` - Cart Screen

## 🏗️ Architecture

The app follows a clean architecture pattern with clear separation of concerns:

```
lib/
├── Models/
│   ├── CartItem.dart          # Cart item model and provider
│   └── product_model.dart     # Product data model
├── views/
│   ├── screens/
│   │   ├── login_screen.dart
│   │   ├── signUp_screen.dart
│   │   ├── wrapper_screen.dart
│   │   ├── Home_Screen.dart
│   │   ├── product_details_screen.dart
│   │   ├── cart_screen.dart
│   │   ├── shop_screen.dart
│   │   ├── wishlist_screen.dart
│   │   └── profile_screen.dart
│   └── widgets/
│       └── grid_product_item_widget.dart
└── main.dart                  # App entry point and routing
```

