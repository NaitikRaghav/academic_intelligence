class AppDateFormatter {
  AppDateFormatter._();

  static String formatToIOS(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    // Apple-style relative date formatting
    if (difference.inDays == 0 && date.day == now.day) {
      return 'Today, ${_formatTime(date)}';
    } else if (difference.inDays == 1 && date.day == now.add(const Duration(days: 1)).day) {
      return 'Tomorrow, ${_formatTime(date)}';
    } else if (difference.inDays == -1 && date.day == now.subtract(const Duration(days: 1)).day) {
      return 'Yesterday, ${_formatTime(date)}';
    }

    // Standard short format: Oct 24, 9:41 AM
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${_formatTime(date)}';
  }

  static String _formatTime(DateTime date) {
    int hour = date.hour;
    final String period = hour >= 12 ? 'PM' : 'AM';
    
    if (hour == 0) hour = 12;
    if (hour > 12) hour -= 12;
    
    final String minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}