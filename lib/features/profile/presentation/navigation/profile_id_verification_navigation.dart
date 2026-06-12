import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/layout/app_breakpoints.dart';
import '../widgets/id_verification/id_verification_dialog.dart';

/// Opens ID verification from profile: dialog on web, full route on mobile.
abstract final class ProfileIdVerificationNavigation {
  ProfileIdVerificationNavigation._();

  static void open(BuildContext context) {
    if (AppBreakpoints.useWebShell(context)) {
      showProfileIdVerificationDialog(context);
      return;
    }
    context.pushNamed(RouteConstants.idVerification);
  }
}
