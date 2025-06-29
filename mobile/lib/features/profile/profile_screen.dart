import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/models/auth_models.dart';
import 'theme_settings_screen.dart';
import 'player_settings_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final currentUser = ref.watch(currentUserProvider);
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Profile',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: false,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // User Profile Card
                _buildUserProfileCard(context, authState, currentUser),
                
                const SizedBox(height: 24),
                
                // Settings Sections
                _buildSettingsSection(context),
                
                const SizedBox(height: 24),
                
                // About Section
                _buildAboutSection(context),
                
                const SizedBox(height: 32),
                
                // Sign Out Button (if authenticated)
                if (authState.isAuthenticated) _buildSignOutButton(context, ref),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfileCard(BuildContext context, AuthState authState, TMDBUser? currentUser) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => _buildUserProfilePage(context),
          ),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Profile Avatar
              CircleAvatar(
                radius: 30,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: currentUser?.avatar?.tmdb?.avatarPath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.network(
                          'https://image.tmdb.org/t/p/w200${currentUser!.avatar!.tmdb!.avatarPath}',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(
                                Icons.person,
                                size: 30,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                        ),
                      )
                    : currentUser?.avatar?.gravatar?.hash != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Image.network(
                              'https://www.gravatar.com/avatar/${currentUser!.avatar!.gravatar!.hash}?s=200',
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                    Icons.person,
                                    size: 30,
                                    color: Theme.of(context).colorScheme.onPrimary,
                                  ),
                            ),
                          )
                        : Icon(
                            Icons.person,
                            size: 30,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
              ),
              
              const SizedBox(width: 16),
              
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authState.isAuthenticated 
                          ? (currentUser?.name ?? 'User')
                          : 'Guest User',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      authState.isAuthenticated 
                          ? 'Manage your account'
                          : 'Sign in to sync your data',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Preferences',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          child: Column(
            children: [
              _buildSettingsTile(
                context: context,
                icon: Icons.palette_outlined,
                title: 'Theme & Appearance',
                subtitle: 'Colors, dark mode, and display options',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ThemeSettingsScreen(),
                  ),
                ),
              ),
              const Divider(height: 1, indent: 72),
              _buildSettingsTile(
                context: context,
                icon: Icons.play_circle_outline,
                title: 'Video Player',
                subtitle: 'Playback, controls, and quality settings',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const PlayerSettingsScreen(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'About',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          child: Column(
            children: [
              _buildSettingsTile(
                context: context,
                icon: Icons.info_outline,
                title: 'About Cinemer',
                subtitle: 'Version, licenses, and app information',
                onTap: () => _showAboutDialog(context),
              ),
              const Divider(height: 1, indent: 72),
              _buildSettingsTile(
                context: context,
                icon: Icons.code_outlined,
                title: 'View on GitHub',
                subtitle: 'Source code and development',
                onTap: () => _launchGitHub(),
              ),
              const Divider(height: 1, indent: 72),
              _buildSettingsTile(
                context: context,
                icon: Icons.bug_report_outlined,
                title: 'Report Issues',
                subtitle: 'Found a bug? Let us know',
                onTap: () => _launchIssues(),
              ),
              const Divider(height: 1, indent: 72),
              _buildSettingsTile(
                context: context,
                icon: Icons.favorite_outline,
                title: 'Support Development',
                subtitle: 'Star the project on GitHub',
                onTap: () => _launchGitHub(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  Widget _buildSignOutButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showSignOutDialog(context, ref),
        icon: const Icon(Icons.logout),
        label: const Text('Sign Out'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.error,
          side: BorderSide(color: Theme.of(context).colorScheme.error),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildUserProfilePage(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final authState = ref.watch(authProvider);
        final currentUser = ref.watch(currentUserProvider);
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Account'),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Profile Picture
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: currentUser?.avatar?.tmdb?.avatarPath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: Image.network(
                            'https://image.tmdb.org/t/p/w200${currentUser!.avatar!.tmdb!.avatarPath}',
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                          ),
                        )
                      : currentUser?.avatar?.gravatar?.hash != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(60),
                              child: Image.network(
                                'https://www.gravatar.com/avatar/${currentUser!.avatar!.gravatar!.hash}?s=200',
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Theme.of(context).colorScheme.onPrimary,
                                    ),
                              ),
                            )
                          : Icon(
                              Icons.person,
                              size: 60,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                ),
                
                const SizedBox(height: 32),
                
                // User Info
                if (authState.isAuthenticated && currentUser != null) ...[
                  Text(
                    currentUser.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '@${currentUser.username}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Account Actions
                  Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.logout),
                          title: const Text('Sign Out'),
                          subtitle: const Text('Sign out of your account'),
                          onTap: () => _showSignOutDialog(context, ref),
                        ),
                        const Divider(height: 1, indent: 72),
                        ListTile(
                          leading: const Icon(Icons.person_add),
                          title: const Text('Add Account'),
                          subtitle: const Text('Sign in with a different account'),
                          onTap: () => _showAddAccountDialog(context, ref),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Guest user
                  Text(
                    'Guest User',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to sync your data across devices',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
                  // Sign In Button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _showSignInDialog(context),
                      icon: const Icon(Icons.login),
                      label: const Text('Sign In'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddAccountDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Account'),
        content: const Text(
          'Adding a new account will sign you out of the current one. '
          'Are you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(authProvider.notifier).logout();
              _showSignInDialog(context);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showSignInDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign In'),
        content: const Text(
          'Sign in functionality will be implemented here. '
          'This would typically involve TMDB authentication.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Cinemer',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).colorScheme.primary,
        ),
        child: Icon(
          Icons.movie,
          size: 32,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      children: [
        const SizedBox(height: 16),
        Text(
          'A modern movie and TV show discovery app built with Flutter. '
          'Discover trending content, manage your watchlist, and enjoy '
          'a beautiful Material 3 interface.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        Text(
          'Features:',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '• Discover movies, TV shows, and anime\n'
          '• Advanced video player with gestures\n'
          '• Watchlist and favorites\n'
          '• Download trailers for offline viewing\n'
          '• Material 3 design with dynamic colors\n'
          '• Dark mode and AMOLED themes\n'
          '• Cross-platform support',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        Text(
          'Built with ❤️ using Flutter and powered by TMDB API.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text(
          'Are you sure you want to sign out? Your local data will be preserved, '
          'but you\'ll need to sign in again to sync across devices.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(authProvider.notifier).logout();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Signed out successfully'),
                ),
              );
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchGitHub() async {
    final uri = Uri.parse('https://github.com/your-username/cinemer');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchIssues() async {
    final uri = Uri.parse('https://github.com/your-username/cinemer/issues');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
