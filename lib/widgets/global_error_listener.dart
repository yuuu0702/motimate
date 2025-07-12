import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../core/error/error_handler.dart';
import 'error_dialog.dart';

class GlobalErrorListener extends HookConsumerWidget {
  final Widget child;
  final bool showAsDialog;
  final bool showAsSnackBar;

  const GlobalErrorListener({
    super.key,
    required this.child,
    this.showAsDialog = true,
    this.showAsSnackBar = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final error = ref.watch(errorProvider);
    
    useEffect(() {
      if (error != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (showAsDialog) {
            ErrorDialog.show(
              context,
              error,
              onDismiss: () => ref.read(errorProvider.notifier).clearError(),
              onRetry: error.type == ErrorType.network
                  ? () {
                      ref.read(errorProvider.notifier).clearError();
                    }
                  : null,
            );
          } else if (showAsSnackBar) {
            ErrorSnackBar.show(
              context,
              error,
              onRetry: error.type == ErrorType.network
                  ? () {
                      ref.read(errorProvider.notifier).clearError();
                    }
                  : null,
            );
            ref.read(errorProvider.notifier).clearError();
          }
        });
      }
      return null;
    }, [error]);

    return child;
  }
}