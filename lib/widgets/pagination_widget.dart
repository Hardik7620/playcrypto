import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/global_constant.dart';

class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;

  const PaginationWidget({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous Button
          _buildControlButton(
            icon: Icons.chevron_left,
            onTap: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
          ),
          const SizedBox(width: 8),
          
          // Page Numbers
          ..._buildPageNumbers(),

          const SizedBox(width: 8),
          // Next Button
          _buildControlButton(
            icon: Icons.chevron_right,
            onTap: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({required IconData icon, VoidCallback? onTap}) {
    final bool isDisabled = onTap == null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDisabled ? Colors.grey[300] : GlobalConstant.kPrimaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isDisabled ? Colors.grey[500] : Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPageNumbers() {
    List<Widget> pages = [];
    
    // Always show first page
    pages.add(_buildPageNumber(1));

    if (totalPages <= 5) {
      // Show all pages if 5 or less
      for (int i = 2; i <= totalPages; i++) {
        pages.add(const SizedBox(width: 4));
        pages.add(_buildPageNumber(i));
      }
    } else {
      // Complex logic for > 5 pages
      if (currentPage <= 3) {
        pages.add(const SizedBox(width: 4));
        pages.add(_buildPageNumber(2));
        pages.add(const SizedBox(width: 4));
        pages.add(_buildPageNumber(3));
        pages.add(const SizedBox(width: 4));
        pages.add(_buildEllipsis());
        pages.add(const SizedBox(width: 4));
        pages.add(_buildPageNumber(totalPages));
      } else if (currentPage >= totalPages - 2) {
        pages.add(const SizedBox(width: 4));
        pages.add(_buildEllipsis());
        pages.add(const SizedBox(width: 4));
        pages.add(_buildPageNumber(totalPages - 2));
        pages.add(const SizedBox(width: 4));
        pages.add(_buildPageNumber(totalPages - 1));
        pages.add(const SizedBox(width: 4));
        pages.add(_buildPageNumber(totalPages));
      } else {
        pages.add(const SizedBox(width: 4));
        pages.add(_buildEllipsis());
        pages.add(const SizedBox(width: 4));
        pages.add(_buildPageNumber(currentPage - 1));
        pages.add(const SizedBox(width: 4));
        pages.add(_buildPageNumber(currentPage));
        pages.add(const SizedBox(width: 4));
        pages.add(_buildPageNumber(currentPage + 1));
        pages.add(const SizedBox(width: 4));
        pages.add(_buildEllipsis());
        pages.add(const SizedBox(width: 4));
        pages.add(_buildPageNumber(totalPages));
      }
    }

    return pages;
  }

  Widget _buildPageNumber(int page) {
    final bool isSelected = page == currentPage;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onPageChanged(page),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? GlobalConstant.kTabActiveButtonColor : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? GlobalConstant.kTabActiveButtonColor : Colors.grey[300]!,
            ),
          ),
          child: Text(
            page.toString(),
            style: GoogleFonts.poppins(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEllipsis() {
    return Container(
      width: 24,
      alignment: Alignment.center,
      child: Text(
        '...',
        style: GoogleFonts.poppins(
          color: Colors.grey[600],
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
