import 'package:flutter/material.dart';
import 'package:my_library/user_entry_point.dart';
import 'package:my_library/admin_entry_point.dart';
import 'screen_export.dart';

import 'package:my_library/models/product_model.dart';
import 'package:my_library/models/order_model.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    // 🔹 Onboarding
    case onbordingScreenRoute:
      return MaterialPageRoute(
        builder: (_) => const OnBordingScreen(),
      );

    // 🔹 Auth Screens
    case logInScreenRoute:
      return MaterialPageRoute(builder: (_) => const LoginScreen());
    case signUpScreenRoute:
      return MaterialPageRoute(builder: (_) => const SignUpScreen());
    case verificationMethodScreenRoute:
      return MaterialPageRoute(
          builder: (_) => const ChooseVerificationMethodScreen());
    case otpScreenRoute:
      return MaterialPageRoute(builder: (_) => const OtpScreen());
    case newPasswordScreenRoute:
      return MaterialPageRoute(builder: (_) => const SetNewPasswordScreen());
    case doneResetPasswordScreenRoute:
      return MaterialPageRoute(builder: (_) => const DoneResetPasswordScreen());
    case termsOfServicesScreenRoute:
      return MaterialPageRoute(
        builder: (_) => TermsOfServicesScreen(onAccepted: () {
          Navigator.pop(_);
        }),
      );
    case signUpOtpScreenRoute:
      final String contact = settings.arguments as String;
      return MaterialPageRoute(
          builder: (_) => SignUpOtpScreen(emailOrPhone: contact));
    case successfullySignedUpRoute:
      return MaterialPageRoute(
          builder: (_) => const SuccessfullySignedUpScreen());

    // 🔹 User App Entry
    case userEntryPointScreenRoute:
      return MaterialPageRoute(builder: (_) => const UserEntryPoint());
    case adminEntryPointScreenRoute:
      return MaterialPageRoute(builder: (_) => const AdminEntryPoint());

    // 🔹 User App Screens
    case homeScreenRoute:
      return MaterialPageRoute(builder: (_) => const HomeScreen());
    case discoverScreenRoute:
      return MaterialPageRoute(builder: (_) => const DiscoverScreen());
    case fictionScreenRoute:
      return MaterialPageRoute(builder: (_) => const FictionScreen());
    case nonFictionScreenRoute:
      return MaterialPageRoute(builder: (_) => const NonFictionScreen());
    case poetryScreenRoute:
      return MaterialPageRoute(builder: (_) => const PoetryScreen());
    case dramaScreenRoute:
      return MaterialPageRoute(builder: (_) => const DramaScreen());
    
    case bookmarkScreenRoute:
      return MaterialPageRoute(builder: (_) => const BookmarkScreen());
    case profileScreenRoute:
      return MaterialPageRoute(builder: (_) => const ProfileScreen());
    case profileSummaryRoute:
      return MaterialPageRoute(builder: (_) => const ProfileSummaryScreen());
    case editProfileRoute:
      return MaterialPageRoute(builder: (_) => const EditProfileScreen());

    // 🔹 Products
    // case productDetailsScreenRoute:
    //   final args = settings.arguments as Map<String, dynamic>? ?? {};
    //   final ProductModel product = args['product'] as ProductModel;
    //   final bool isProductAvailable =
    //       args['isProductAvailable'] as bool? ?? true;

    //   return MaterialPageRoute(
    //     builder: (_) => ProductDetailsScreen(
    //       product: product,
    //       isProductAvailable: isProductAvailable,
    //     ),
    //   );

    case productReviewsScreenRoute:
      {
        final args = settings.arguments;
        String productId = '';
        String productName = '';

        if (args is String) {
          // caller passed only productId
          productId = args;
        } else if (args is Map) {
          // caller passed a map — accept various key names safely
          productId = (args['productId'] ?? args['id'] ?? '').toString();
          productName = (args['productName'] ?? args['title'] ?? '').toString();
        }

        // guard: if productId is missing, show a small error screen instead of crashing
        if (productId.isEmpty) {
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(title: const Text('Invalid product')),
              body: const Center(child: Text('No product id provided')),
            ),
          );
        }

        return MaterialPageRoute(
          builder: (_) => ProductReviewsScreen(
            productId: productId,
            productName: productName,
          ),
        );
      }

    case addReviewsScreenRoute:
      {
        final args = settings.arguments;
        String productId = '';

        if (args is String) {
          productId = args;
        } else if (args is Map) {
          productId = (args['productId'] ?? args['id'] ?? '').toString();
        }

        if (productId.isEmpty) {
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(title: const Text('Invalid product')),
              body: const Center(child: Text('No product id provided')),
            ),
          );
        }

        return MaterialPageRoute(
          builder: (_) => AddReviewScreen(productId: productId),
        );
      }

    // 🔹 Orders & Cart
    case cartScreenRoute:
      return MaterialPageRoute(builder: (_) => const CartScreen());
    case checkoutScreenRoute:
      return MaterialPageRoute(builder: (_) => const CheckoutScreen());
    case paymentMethodScreenRoute:
      return MaterialPageRoute(builder: (_) => const PaymentMethodScreen());
    case thanksForOrderScreenRoute:
      return MaterialPageRoute(builder: (_) => const ThanksForOrderScreen());
    case ordersScreenRoute:
      return MaterialPageRoute(builder: (_) => const OrdersScreen());
    case orderProcessingScreenRoute:
      return MaterialPageRoute(builder: (_) => const OrderProcessingScreen());
    case cancleOrderScreenRoute:
      return MaterialPageRoute(builder: (_) => const CancleOrderScreen());
    case deliveredOrdersScreenRoute:
      return MaterialPageRoute(builder: (_) => const DeliveredOrdersScreen());
    
    // 🔹 Addresses
    case noAddressScreenRoute:
      return MaterialPageRoute(builder: (_) => const NoAddressScreen());
    case addressesScreenRoute:
      return MaterialPageRoute(builder: (_) => const AddressesScreen());
    case addNewAddressesScreenRoute:
      return MaterialPageRoute(builder: (_) => const AddNewAddressScreen());

    // 🔹 Admin Panel Entry
    case adminDashboardScreenRoute:
      return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
    case adminProductListScreenRoute:
      return MaterialPageRoute(builder: (_) => const AdminProductListScreen());
    case adminAddEditProductScreenRoute:
      return MaterialPageRoute(
          builder: (_) => const AdminProductAddEditScreen());
    case adminProductDetailScreenRoute:
      final product = settings.arguments as ProductModel;
      return MaterialPageRoute(
        builder: (_) => AdminProductDetailScreen(
          productId: product.id,
          initial: product, // optional, improves perceived speed
        ),
      );
    case adminProductCategoriesScreenRoute:
      return MaterialPageRoute(
          builder: (_) => const AdminProductCategoriesScreen());

    // 🔹 Admin Orders
    case adminAllOrdersTabScreenRoute:
      return MaterialPageRoute(builder: (_) => const AdminAllOrdersTabScreen());

    case adminOrderDetailScreenRoute:
      final order = settings.arguments as OrderModel;
      return MaterialPageRoute(
          builder: (_) => AdminOrderDetailScreen(orderId: order.id));
    case adminUpdateOrderStatusScreenRoute:
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (_) => AdminUpdateOrderStatusScreen(
          orderId: args['orderId'],
          initialStatus: args['initialStatus'],
        ),
      );

    // 🔹 Admin Users
// inside your generateRoute switch
    case adminUserListScreenRoute:
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const AdminUserListScreen(),
      );

    case adminUserDetailScreenRoute:
      // detail expects arguments (UserModel or id) — keep settings so screen reads it
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const AdminUserDetailScreen(),
      );

    case adminUserEditScreenRoute:
      return MaterialPageRoute(
        settings:
            settings, // <-- important so ModalRoute.of(context).settings.arguments is preserved
        builder: (_) => const AdminUserEditScreen(),
      );

    case adminUserAddScreenRoute:
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const AdminUserAddScreen(),
      );

    // 🔹 Admin Settings & Reviews

    case adminReviewListScreenRoute:
      return MaterialPageRoute(builder: (_) => const AdminReviewScreen());

    case adminauthorManagementScreenRoute:
      return MaterialPageRoute(
          builder: (_) => const AdminAuthorManagementScreen());

    // 🔹 Default Fallback
    default:
      return MaterialPageRoute(builder: (_) => const OnBordingScreen());
  }
}
