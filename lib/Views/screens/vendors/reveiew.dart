import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../res/app_url.dart';
import '../../../view_model/apiServices.dart';

class VendorReviewScreen extends StatefulWidget {
  final dynamic stars;
  final dynamic reviewsLenght;
  final dynamic prodID;
  VendorReviewScreen({this.stars, this.reviewsLenght, this.prodID});

  @override
  State<VendorReviewScreen> createState() => _VendorReviewScreenState();
}

class _VendorReviewScreenState extends State<VendorReviewScreen> {
  static const Color _accent = Color(0xFFF6AE02);
  static const Color _textDark = Color(0xFF1B1B1F);
  static const Color _textGrey = Color(0xFF72747A);
  static const Color _surface = Color(0xFFF7F7F9);

  bool isLoading = true;
  bool isError = false;
  bool isEmpty = false;

  void getReviews() {
    ApiRepository.shared.reviewsByProductId(
      widget.prodID.toString(),
      (list) {
        if (mounted) {
          setState(() {
            isEmpty = list.data?.isEmpty ?? true;
            isLoading = false;
            isError = false;
          });
        }
      },
      (error) {
        if (mounted && error != null) {
          setState(() {
            isEmpty = false;
            isLoading = false;
            isError = true;
          });
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getReviews();
  }

  @override
  Widget build(BuildContext context) {
    final reviews = ApiRepository.shared.getReviewsByProductIdModelList?.data ?? [];
    final double avgRating =
        (double.tryParse(widget.stars.toString()) ?? 0).clamp(0, 5);
    final int totalReviews =
        int.tryParse(widget.reviewsLenght.toString()) ?? reviews.length;
    final Map<int, int> starCount = _buildStarCountMap(reviews);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Reviews',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: _textDark,
            fontSize: 20,
          ),
        ),
        leading: InkWell(
          onTap: () => Get.back(),
          borderRadius: BorderRadius.circular(50),
          child: const Padding(
            padding: EdgeInsets.all(17.0),
            child: Icon(Icons.arrow_back, color: _textDark),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Text(
                avgRating.toStringAsFixed(
                  avgRating == avgRating.roundToDouble() ? 0 : 1,
                ),
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 58,
                  color: _textDark,
                ),
              ),
              RatingBarIndicator(
                rating: avgRating,
                itemBuilder: (context, index) =>
                    const Icon(Icons.star_rounded, color: _accent),
                itemCount: 5,
                itemSize: 22,
              ),
              const SizedBox(height: 8),
              Text(
                "$totalReviews ${totalReviews == 1 ? 'review' : 'reviews'}",
                style: GoogleFonts.inter(
                  color: _textGrey,
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 28),
              _ratingBarRow(
                label: "Excellent",
                value: _share(starCount[5] ?? 0, totalReviews),
                color: const Color(0xFF1CAA16),
              ),
              const SizedBox(height: 16),
              _ratingBarRow(
                label: "Good",
                value: _share(starCount[4] ?? 0, totalReviews),
                color: const Color(0xFF84D01E),
              ),
              const SizedBox(height: 16),
              _ratingBarRow(
                label: "Average",
                value: _share(starCount[3] ?? 0, totalReviews),
                color: const Color(0xFFEACB1D),
              ),
              const SizedBox(height: 16),
              _ratingBarRow(
                label: "Below Average",
                value: _share(starCount[2] ?? 0, totalReviews),
                color: const Color(0xFFF07A18),
              ),
              const SizedBox(height: 16),
              _ratingBarRow(
                label: "Poor",
                value: _share(starCount[1] ?? 0, totalReviews),
                color: const Color(0xFFF0322D),
              ),
              const SizedBox(height: 26),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: isError
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          "Some error occurred while loading reviews.",
                          style: GoogleFonts.inter(color: _textGrey),
                        ),
                      )
                    : isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(12),
                                child: Text(
                                  "No reviews yet.",
                                  style: GoogleFonts.inter(color: _textGrey),
                                ),
                              )
                            : ListView.separated(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: reviews.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, int index) {
                                  final data = reviews[index];
                                  final date = DateFormat('yyyy-MM-dd').format(
                                    DateTime.parse(data.createdAt.toString()),
                                  );
                                  final stars = data.stars;
                                  final desc = data.description.toString();
                                  final name = data.userName.toString();
                                  return _card(
                                    data.image?.toString(),
                                    date,
                                    stars,
                                    desc,
                                    name,
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ratingBarRow({
    required String label,
    required double value,
    required Color color,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: _textDark,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Stack(
              children: [
                Container(height: 10, color: const Color(0xFFD9D9D9)),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: value,
                    child: Container(height: 10, color: color),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Map<int, int> _buildStarCountMap(List reviews) {
    final map = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (final r in reviews) {
      final s = int.tryParse(r.stars.toString()) ?? 0;
      if (map.containsKey(s)) {
        map[s] = (map[s] ?? 0) + 1;
      }
    }
    return map;
  }

  double _share(int count, int total) {
    if (total <= 0) return 0;
    return (count / total).clamp(0.0, 1.0);
  }

  /// Same URL rules as other screens (e.g. ProductDetail, Messages).
  String? _reviewerImageUrl(String? raw) {
    final s = (raw ?? '').trim();
    if (s.isEmpty || s.toLowerCase() == 'null') return null;
    if (s.startsWith('http')) return s;
    return AppUrl.baseUrlM + s;
  }

  Widget _reviewerAvatar(String? imagePath) {
    const double size = 46;
    const radius = size / 2;
    final url = _reviewerImageUrl(imagePath);
    if (url == null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey.shade300,
        backgroundImage:
            const AssetImage('assets/slicing/blankuser.jpeg') as ImageProvider,
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade200,
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (context, u) => Container(
            width: size,
            height: size,
            color: Colors.grey.shade200,
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          errorWidget: (context, u, e) => Image.asset(
            'assets/slicing/blankuser.jpeg',
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _card(String? imagePath, date, stars, desc, name) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEAEAEA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _reviewerAvatar(imagePath),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: _textDark,
                      ),
                    ),
                    Text(
                      date,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: _textGrey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          RatingBarIndicator(
            rating: (double.tryParse(stars.toString()) ?? 0).clamp(0, 5),
            itemBuilder: (context, index) =>
                const Icon(Icons.star_rounded, color: _accent),
            itemCount: 5,
            itemSize: 17,
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: _textDark,
              fontWeight: FontWeight.w400,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}
