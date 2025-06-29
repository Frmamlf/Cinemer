import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/models/auth_models.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  final _nameController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    // Initialize with current user data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeUserData();
    });
  }

  Future<void> _initializeUserData() async {
    final currentUser = ref.read(currentUserProvider);
    
    if (currentUser != null) {
      // For authenticated users, use TMDB name but check for local display name override
      final localDisplayName = await _getDisplayNameLocally();
      _nameController.text = localDisplayName ?? currentUser.name;
    } else {
      // For guest users, use saved local display name or default
      final localDisplayName = await _getDisplayNameLocally();
      _nameController.text = localDisplayName ?? 'Guest User';
    }
    
    // Trigger rebuild to show the loaded name
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final currentUser = ref.watch(currentUserProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        centerTitle: true,
        actions: [
          if (authState.isAuthenticated && !_isEditing)
            IconButton(
              onPressed: () => setState(() => _isEditing = true),
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Profile',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile Picture Section
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: _buildProfileImage(currentUser),
                  ),
                  if (authState.isAuthenticated && _isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.surface,
                            width: 2,
                          ),
                        ),
                        child: IconButton(
                          onPressed: _changeProfilePicture,
                          icon: Icon(
                            Icons.camera_alt,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                          iconSize: 20,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Account Information
            if (authState.isAuthenticated) ...[
              _buildAccountInfo(currentUser),
            ] else ...[
              _buildGuestInfo(),
            ],
            
            const SizedBox(height: 32),
            
            // Action Buttons
            _buildActionButtons(authState),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(TMDBUser? currentUser) {
    if (currentUser?.avatar?.tmdb?.avatarPath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(60),
        child: Image.network(
          'https://image.tmdb.org/t/p/w200${currentUser!.avatar!.tmdb!.avatarPath}',
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.person,
            size: 60,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      );
    } else if (currentUser?.avatar?.gravatar?.hash != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(60),
        child: Image.network(
          'https://www.gravatar.com/avatar/${currentUser!.avatar!.gravatar!.hash}?s=400',
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.person,
            size: 60,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      );
    } else {
      return Icon(
        Icons.person,
        size: 60,
        color: Theme.of(context).colorScheme.onPrimary,
      );
    }
  }

  Widget _buildAccountInfo(TMDBUser? currentUser) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            // Name Field
            _buildInfoField(
              label: 'Name',
              value: currentUser?.name ?? 'User',
              isEditable: _isEditing,
              controller: _nameController,
            ),
            
            const SizedBox(height: 16),
            
            // Username Field
            _buildInfoField(
              label: 'Username',
              value: currentUser?.username ?? 'Unknown',
              isEditable: false,
            ),
            
            const SizedBox(height: 16),
            
            // User ID Field
            _buildInfoField(
              label: 'User ID',
              value: currentUser?.id.toString() ?? '0',
              isEditable: false,
            ),
            
            // Display Name Update Info
            FutureBuilder<String?>(
              future: _getDisplayNameUpdatedTime(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  return Column(
                    children: [
                      const SizedBox(height: 16),
                      _buildInfoField(
                        label: 'Display Name Last Updated',
                        value: snapshot.data!,
                        isEditable: false,
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            
            if (_isEditing) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        setState(() => _isEditing = false);
                        // Reset name controller to saved value
                        await _initializeUserData();
                      },
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: _saveChanges,
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGuestInfo() {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.account_circle_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Guest User',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in to sync your data across devices and access personalized features.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoField({
    required String label,
    required String value,
    bool isEditable = false,
    TextEditingController? controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        if (isEditable && controller != null)
          TextField(
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
              ),
            ),
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons(AuthState authState) {
    return Column(
      children: [
        if (!authState.isAuthenticated) ...[
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _signIn,
              icon: const Icon(Icons.login),
              label: const Text('Sign In'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _addAccount,
              icon: const Icon(Icons.person_add),
              label: const Text('Add Account'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ] else ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _addAccount,
              icon: const Icon(Icons.person_add),
              label: const Text('Add New Account'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _signOut,
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
                side: BorderSide(color: Theme.of(context).colorScheme.error),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _changeProfilePicture() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile picture change is managed through TMDB or Gravatar'),
      ),
    );
  }

  void _saveChanges() async {
    // Validate input
    final newName = _nameController.text.trim();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    if (newName.isEmpty) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Name cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (newName.length < 2) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Name must be at least 2 characters long'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (newName.length > 50) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Name must be 50 characters or less'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Show loading state
      setState(() => _isEditing = false);
      
      // Get current user
      final currentUser = ref.read(currentUserProvider);
      
      if (currentUser != null) {
        // For authenticated users: TMDB profile updates would go here
        // Since TMDB API doesn't typically allow profile name changes,
        // we'll store the display name locally
        
        // Save to local storage for display purposes
        await _saveDisplayNameLocally(newName);
        
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Display name updated successfully'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'TMDB Settings',
              textColor: Colors.white,
              onPressed: () {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Account name changes can be made in TMDB account settings'),
                  ),
                );
              },
            ),
          ),
        );
      } else {
        // For guest users: save to local storage
        await _saveDisplayNameLocally(newName);
        
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Display name saved locally'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Handle errors
      setState(() => _isEditing = true);
      
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Failed to save changes: ${e.toString()}'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: _saveChanges,
          ),
        ),
      );
    }
  }

  Future<void> _saveDisplayNameLocally(String displayName) async {
    try {
      // Import SharedPreferences if not already imported
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_display_name', displayName);
      
      // Also save timestamp for when it was last updated
      await prefs.setString('user_display_name_updated', DateTime.now().toIso8601String());
      
    } catch (e) {
      throw Exception('Failed to save to local storage: $e');
    }
  }

  Future<void> _clearDisplayNameLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_display_name');
      await prefs.remove('user_display_name_updated');
    } catch (e) {
      // Ignore errors when clearing
    }
  }

  Future<String?> _getDisplayNameLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('user_display_name');
    } catch (e) {
      return null;
    }
  }

  Future<String?> _getDisplayNameUpdatedTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final updatedTimeStr = prefs.getString('user_display_name_updated');
      
      if (updatedTimeStr != null) {
        final updatedTime = DateTime.parse(updatedTimeStr);
        final now = DateTime.now();
        final difference = now.difference(updatedTime);
        
        if (difference.inDays > 0) {
          return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
        } else if (difference.inHours > 0) {
          return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
        } else if (difference.inMinutes > 0) {
          return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
        } else {
          return 'Just now';
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  void _signIn() {
    // Navigate to login screen
    Navigator.of(context).pushNamed('/login');
  }

  void _addAccount() {
    // Show confirmation dialog and then sign out current user to add new account
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Account'),
        content: const Text(
          'Adding a new account will sign you out of the current account. '
          'Are you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final navigator = Navigator.of(context);
              navigator.pop();
              _signOut();
              // Navigate to login after signing out
              Future.delayed(const Duration(milliseconds: 500), () {
                navigator.pushNamed('/login');
              });
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _signOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text(
          'Are you sure you want to sign out? Your local data will be preserved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              
              navigator.pop();
              
              // Clear locally saved display name
              await _clearDisplayNameLocally();
              
              // Sign out from auth provider
              ref.read(authProvider.notifier).logout();
              
              scaffoldMessenger.showSnackBar(
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
}
