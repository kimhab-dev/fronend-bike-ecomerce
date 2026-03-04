import 'package:flutter/material.dart';

class ProfileUserScreen extends StatelessWidget {
  const ProfileUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF100A16),
      appBar: AppBar(
        backgroundColor: const Color(0xFF100A16),
        elevation: 0,
        title: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                  text: 'BIG',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      letterSpacing: 1.0)),
              TextSpan(
                  text: 'BIKE',
                  style: TextStyle(
                      color: Color(0xFF8B5A8C),
                      fontWeight: FontWeight.normal,
                      fontSize: 22,
                      letterSpacing: 1.0)),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: Colors.grey[400]),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileCard(),
            const SizedBox(height: 16),
            _buildContactInfoCard(),
            const SizedBox(height: 16),
            _buildAccountCard(),
            const SizedBox(height: 16),
            _buildSupportCard(),
            const SizedBox(height: 24),
            _buildSignOutButton(),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'BigBike Store v2.0.0',
                style: TextStyle(color: Colors.grey[700], fontSize: 12),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1424),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5A8C), Color(0xFF7CB670)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5A8C).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: const Center(
                  child: Text(
                    'K',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'kimhabsok9',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.edit_outlined,
                            color: Colors.grey[500], size: 16),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.email_outlined,
                            color: Colors.grey[500], size: 14),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'kimhabsok9@gmail.com',
                            style: TextStyle(
                                color: Colors.grey[400], fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF8B5A8C).withOpacity(0.6),
                            const Color(0xFF7CB670).withOpacity(0.6)
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: const Text(
                        'Premium Member',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 24),
          Divider(color: Colors.white.withOpacity(0.05), height: 1),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem('12', 'Orders', Icons.inventory_2_outlined,
                  const Color(0xFF8B5A8C)),
              _buildStatItem(
                  '0', 'Saved', Icons.favorite_border, const Color(0xFFD0545A)),
              _buildStatItem('0', 'In Cart', Icons.shopping_cart_outlined,
                  const Color(0xFF7CB670)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String count, String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 12),
        Text(count,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildContactInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1424),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CONTACT INFO',
              style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2)),
          const SizedBox(height: 20),
          _buildContactRow(Icons.email_outlined, 'kimhabsok9@gmail.com'),
          const SizedBox(height: 16),
          _buildContactRow(Icons.phone_outlined, '+1 (555) 000-0000'),
          const SizedBox(height: 16),
          _buildContactRow(
              Icons.location_on_outlined, 'Los Angeles, California'),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.grey[400], size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(text,
              style: const TextStyle(color: Colors.white, fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildAccountCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1424),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text('ACCOUNT',
              style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2)),
          const SizedBox(height: 8),
          _buildActionRow(Icons.inventory_2_outlined, const Color(0xFF8B5A8C),
              'My Orders', 'Track your purchases'),
          _buildActionRow(Icons.location_on_outlined, const Color(0xFF7CB670),
              'Addresses', 'Manage delivery locations'),
          _buildActionRow(Icons.notifications_none_outlined,
              const Color(0xFFD0545A), 'Notifications', 'Manage alerts',
              showBorder: false),
        ],
      ),
    );
  }

  Widget _buildSupportCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1424),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text('SUPPORT',
              style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2)),
          const SizedBox(height: 8),
          _buildActionRow(Icons.shield_outlined, const Color(0xFF8B5A8C),
              'Security', 'Password & privacy'),
          _buildActionRow(Icons.help_outline, const Color(0xFF7CB670),
              'Help Center', 'FAQs & support'),
          _buildActionRow(Icons.star_border, const Color(0xFFD0545A),
              'Rate the App', 'Share your experience',
              showBorder: false),
        ],
      ),
    );
  }

  Widget _buildActionRow(
      IconData icon, Color iconColor, String title, String subtitle,
      {bool showBorder = true}) {
    return Container(
      decoration: showBorder
          ? BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: Colors.white.withOpacity(0.05))))
          : null,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: iconColor.withOpacity(0.2)),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: Colors.grey[600], size: 14),
        ],
      ),
    );
  }

  Widget _buildSignOutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.logout, color: Color(0xFFB03A48)),
        label: const Text('Sign Out',
            style: TextStyle(
                color: Color(0xFFB03A48),
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: Color(0xFF4A1F2D)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: const Color(0xFFB03A48).withOpacity(0.05),
        ),
      ),
    );
  }
}
