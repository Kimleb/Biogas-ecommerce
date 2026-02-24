import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../components/custom_button.dart';
import '../../../components/custom_form_field.dart';
import '../../../../utils/constants.dart';
import '../controllers/auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              40.verticalSpace,
              Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
                  ),
                  16.horizontalSpace,
                  Text(
                    'Welcome Back',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              40.verticalSpace,

              // Login Form
              Form(
                key: controller.loginFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Email',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    8.verticalSpace,
                    CustomFormField(
                      controller: controller.emailController,
                      hint: 'Enter your email',
                      prefixIcon:
                          Icon(Icons.email_outlined, color: theme.hintColor),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!GetUtils.isEmail(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    24.verticalSpace,

                    Text(
                      'Password',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    8.verticalSpace,
                    Obx(() => CustomFormField(
                          controller: controller.passwordController,
                          hint: 'Enter your password',
                          prefixIcon:
                              Icon(Icons.lock_outline, color: theme.hintColor),
                          obscureText: !controller.isPasswordVisible.value,
                          suffixIcon: IconButton(
                            onPressed: controller.togglePasswordVisibility,
                            icon: Icon(
                              controller.isPasswordVisible.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: theme.hintColor,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        )),
                    12.verticalSpace,

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: controller.onForgotPassword,
                        child: Text(
                          'Forgot Password?',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              40.verticalSpace,

              // Login Button
              Obx(() => CustomButton(
                    text: controller.isLoading.value ? '' : 'Sign In',
                    onPressed:
                        controller.isLoading.value ? null : controller.onLogin,
                    fontSize: 16.sp,
                    radius: 12.r,
                    verticalPadding: 16.h,
                    hasShadow: false,
                    disabled: controller.isLoading.value,
                    icon: controller.isLoading.value
                        ? SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : null,
                  )),

              24.verticalSpace,

              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: theme.dividerColor)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      'OR',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: theme.dividerColor)),
                ],
              ),

              24.verticalSpace,

              // Social Login
              Obx(() => CustomButton(
                    text: controller.isLoading.value
                        ? ''
                        : 'Continue with Google',
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.onGoogleSignIn,
                    fontSize: 16.sp,
                    radius: 12.r,
                    verticalPadding: 16.h,
                    hasShadow: false,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    disabled: controller.isLoading.value,
                    icon: controller.isLoading.value
                        ? SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.black87,
                              ),
                            ),
                          )
                        : Padding(
                            padding: EdgeInsets.only(left: 8.w),
                            child: SvgPicture.asset(Constants.googleLogo,
                                width: 20.w, height: 20.w),
                          ),
                  )),

              32.verticalSpace,

              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: theme.textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () => Get.toNamed('/auth/signup'),
                    child: Text(
                      'Sign Up',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
