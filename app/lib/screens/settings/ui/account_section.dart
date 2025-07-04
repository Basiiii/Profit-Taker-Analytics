import 'package:flutter/material.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';

/// Builds the "Account" settings section in the app.
///
/// This section displays user account information and provides options for signing in,
/// signing up, or logging out depending on the current authentication state.
///
/// Parameters:
/// - [context]: The build context used for localization and UI rendering.
/// - [user]: The current user object from Supabase.
/// - [username]: The username of the current user.
/// - [onSignIn]: Callback function to handle sign in action.
/// - [onSignUp]: Callback function to handle sign up action.
/// - [onLogout]: Callback function to handle logout action.
///
/// Returns:
/// A [SettingsSection] containing account-related tiles.
SettingsSection buildAccountSection(
  BuildContext context,
  User? user,
  String? username,
  VoidCallback onSignIn,
  VoidCallback onSignUp,
  VoidCallback onLogout,
) {
  if (user != null && username != null) {
    return SettingsSection(
      title: Text(FlutterI18n.translate(context, "settings.account.title")),
      tiles: [
        SettingsTile(
          title: Text(FlutterI18n.translate(
              context, "settings.account.logged_in_as",
              translationParams: {"username": username})),
          leading: const Icon(Icons.account_circle),
          onPressed: (_) async {
            final url =
                Uri.parse('https://stats.profit-taker.com/profile/$username');
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
          },
        ),
        SettingsTile(
          title:
              Text(FlutterI18n.translate(context, "settings.account.my_runs")),
          leading: const Icon(Icons.list_alt),
          onPressed: (_) async {
            final url = Uri.parse('https://stats.profit-taker.com/my-runs');
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
          },
        ),
        SettingsTile(
          title:
              Text(FlutterI18n.translate(context, "settings.account.logout")),
          leading: const Icon(Icons.logout),
          onPressed: (_) => onLogout(),
        ),
      ],
    );
  } else {
    return SettingsSection(
      title: Text(FlutterI18n.translate(context, "settings.account.title")),
      tiles: [
        SettingsTile(
          title:
              Text(FlutterI18n.translate(context, "settings.general.sign_in")),
          leading: const Icon(Icons.login),
          onPressed: (_) => onSignIn(),
        ),
        SettingsTile(
          title:
              Text(FlutterI18n.translate(context, "settings.general.sign_up")),
          leading: const Icon(Icons.person_add),
          onPressed: (_) => onSignUp(),
        ),
      ],
    );
  }
}

/// A dialog widget for signing in to the application.
///
/// This dialog provides options for signing in with email/password or Discord OAuth.
/// It handles the authentication flow and displays appropriate error messages.
class SignInDialog extends StatefulWidget {
  const SignInDialog({super.key});

  @override
  State<SignInDialog> createState() => _SignInDialogState();
}

/// The state for [SignInDialog], managing the sign-in form and authentication logic.
class _SignInDialogState extends State<SignInDialog> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  /// Signs in the user with email and password.
  Future<void> _signInWithEmail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      if (response.user == null) {
        setState(() {
          _error = 'Invalid credentials';
        });
      } else {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Signs in the user with Discord OAuth.
  Future<void> _signInWithDiscord() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.discord,
        redirectTo: 'pta://auth-callback',
      );

      await windowManager.close();
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Opens the forgot password page in the browser.
  void _forgotPassword() async {
    final url =
        Uri.parse('https://stats.profit-taker.com/auth/forgot-password');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Sign In'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
          ),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _forgotPassword,
              child: Text('Forgot password?'),
            ),
          ),
          if (_error != null) ...[
            SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: Colors.red)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _signInWithEmail,
          child: _isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Text('Sign In'),
        ),
        OutlinedButton.icon(
          onPressed: _isLoading ? null : _signInWithDiscord,
          icon: Icon(Icons.discord),
          label: Text('Discord'),
        ),
      ],
    );
  }
}
