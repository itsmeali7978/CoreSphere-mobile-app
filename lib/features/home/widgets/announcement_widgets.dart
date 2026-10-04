import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/dashboard_card.dart';
import '../../../data/models/announcement_item.dart';
import 'dashboard_cards.dart';

class AnnouncementCard extends StatelessWidget {
  final DashboardCard card;
  final double height;

  const AnnouncementCard({Key? key, required this.card, required this.height}) : super(key: key);

  void _onAnnouncementTap(BuildContext context, AnnouncementItem item) async {
    final type = item.actionType.toUpperCase();
    if (type == 'NONE') return;

    if (type == 'URL' && item.actionValue != null && item.actionValue!.isNotEmpty) {
      final uri = Uri.parse(item.actionValue!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } else if (type == 'MODULE' && item.actionValue != null && item.actionValue!.isNotEmpty) {
      final val = item.actionValue!.toUpperCase();
      if (val == 'CUSTOMERS') {
        Get.toNamed(RouteNames.customers);
      } else if (val == 'PAYMENTS' || val == 'RECEIPT' || val == 'PAYMENT_RECEIPT' || val == 'PAYMENT_RECEIPTS') {
        Get.toNamed(RouteNames.paymentReceipts);
      } else if (val == 'EMPLOYEES') {
        Get.toNamed(RouteNames.employees);
      }
    } else if (type == 'SCREEN' && item.actionValue != null && item.actionValue!.isNotEmpty) {
      Get.toNamed(item.actionValue!);
    } else if (type == 'CUSTOMER' && item.actionValue != null && item.actionValue!.isNotEmpty) {
      Get.toNamed(RouteNames.customerDetails, arguments: item.actionValue);
    } else if (type == 'EMPLOYEE' && item.actionValue != null && item.actionValue!.isNotEmpty) {
      Get.toNamed(RouteNames.employeeDetails, arguments: item.actionValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasItems = card.items != null && card.items!.isNotEmpty;
    final displayStyle = (card.cardDisplayStyle ?? 'IMAGE_SLIDER').toUpperCase();

    // Default container styling
    return BaseDashboardCard(
      card: card,
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.campaign,
                    color: resolveCardColor(card.iconColor),
                    size: 18.sp,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    card.cardTitle,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryColor,
                    ),
                  ),
                ],
              ),
              if (hasItems)
                Text(
                  "${card.items!.length} News",
                  style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade400),
                )
            ],
          ),
          SizedBox(height: 10.h),
          Expanded(
            child: !hasItems
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          color: Colors.grey.shade300,
                          size: 32.sp,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "No active announcements",
                          style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade400),
                        ),
                      ],
                    ),
                  )
                : _buildStyleWidget(context, displayStyle, card.items!),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleWidget(BuildContext context, String style, List<AnnouncementItem> items) {
    switch (style) {
      case 'TEXT_SCROLL':
        return VerticalAnnouncementTicker(
          items: items,
          onTap: (item) => _onAnnouncementTap(context, item),
        );
      case 'IMAGE_WITH_TEXT':
        return AnnouncementImageWithText(
          item: items.first,
          onTap: (item) => _onAnnouncementTap(context, item),
        );
      case 'VERTICAL_LIST':
        return AnnouncementVerticalList(
          items: items,
          onTap: (item) => _onAnnouncementTap(context, item),
        );
      case 'SINGLE_BANNER':
        return AnnouncementSingleBanner(
          item: items.first,
          onTap: (item) => _onAnnouncementTap(context, item),
        );
      case 'IMAGE_SLIDER':
      default:
        return AnnouncementImageSlider(
          items: items,
          onTap: (item) => _onAnnouncementTap(context, item),
        );
    }
  }
}

class VerticalAnnouncementTicker extends StatefulWidget {
  final List<AnnouncementItem> items;
  final Function(AnnouncementItem) onTap;
  const VerticalAnnouncementTicker({Key? key, required this.items, required this.onTap}) : super(key: key);

  @override
  State<VerticalAnnouncementTicker> createState() => _VerticalAnnouncementTickerState();
}

class _VerticalAnnouncementTickerState extends State<VerticalAnnouncementTicker> {
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    print("VerticalAnnouncementTicker [initState]: items = ${widget.items.map((i) => i.title).toList()}");
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = null;
    if (widget.items.length > 1) {
      print("VerticalAnnouncementTicker [_startTimer]: Starting 4s timer for ${widget.items.length} items");
      _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
        if (mounted) {
          setState(() {
            _currentIndex = (_currentIndex + 1) % widget.items.length;
            print("VerticalAnnouncementTicker [Timer tick]: _currentIndex = $_currentIndex, active title = ${widget.items[_currentIndex].title}");
          });
        }
      });
    } else {
      print("VerticalAnnouncementTicker [_startTimer]: Not starting timer because item count is ${widget.items.length}");
    }
  }

  @override
  void didUpdateWidget(covariant VerticalAnnouncementTicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    print("VerticalAnnouncementTicker [didUpdateWidget]: items count old = ${oldWidget.items.length}, new = ${widget.items.length}");
    if (widget.items.length != oldWidget.items.length) {
      _currentIndex = 0;
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.items[_currentIndex];
    return GestureDetector(
      onTap: () => widget.onTap(item),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: Row(
            key: ValueKey<int>(_currentIndex),
            children: [
              Icon(Icons.new_releases, color: AppTheme.primaryColor, size: 18.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.shortDescription != null && item.shortDescription!.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        item.shortDescription!,
                        style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ]
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 10.sp, color: Colors.grey.shade300),
            ],
          ),
        ),
      ),
    );
  }
}

class AnnouncementImageSlider extends StatefulWidget {
  final List<AnnouncementItem> items;
  final Function(AnnouncementItem) onTap;
  const AnnouncementImageSlider({Key? key, required this.items, required this.onTap}) : super(key: key);

  @override
  State<AnnouncementImageSlider> createState() => _AnnouncementImageSliderState();
}

class _AnnouncementImageSliderState extends State<AnnouncementImageSlider> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    print("AnnouncementImageSlider [initState]: items = ${widget.items.map((i) => i.title).toList()}");
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = null;
    if (widget.items.length > 1) {
      print("AnnouncementImageSlider [_startTimer]: Starting 5s timer for ${widget.items.length} items");
      _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
        if (mounted && _pageController.hasClients) {
          int nextPage = (_currentPage + 1) % widget.items.length;
          print("AnnouncementImageSlider [Timer tick]: Animating from page $_currentPage to $nextPage, active title = ${widget.items[nextPage].title}");
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
          );
        }
      });
    } else {
      print("AnnouncementImageSlider [_startTimer]: Not starting timer because item count is ${widget.items.length}");
    }
  }

  @override
  void didUpdateWidget(covariant AnnouncementImageSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    print("AnnouncementImageSlider [didUpdateWidget]: items count old = ${oldWidget.items.length}, new = ${widget.items.length}");
    if (widget.items.length != oldWidget.items.length) {
      _currentPage = 0;
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (idx) => setState(() => _currentPage = idx),
            itemCount: widget.items.length,
            itemBuilder: (context, idx) {
              final item = widget.items[idx];
              return GestureDetector(
                onTap: () => widget.onTap(item),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      item.imageUrl != null && item.imageUrl!.isNotEmpty
                          ? Image.network(
                              item.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Container(
                                color: Colors.grey.shade100,
                                child: const Icon(Icons.broken_image, color: Colors.grey),
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppTheme.primaryColor.withOpacity(0.2), AppTheme.primaryColor.withOpacity(0.05)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.items.length > 1) ...[
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.items.length, (idx) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: 2.w),
                height: 4.h,
                width: _currentPage == idx ? 12.w : 4.w,
                decoration: BoxDecoration(
                  color: _currentPage == idx ? AppTheme.primaryColor : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              );
            }),
          )
        ]
      ],
    );
  }
}

class AnnouncementImageWithText extends StatelessWidget {
  final AnnouncementItem item;
  final Function(AnnouncementItem) onTap;
  const AnnouncementImageWithText({Key? key, required this.item, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(item),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.04),
              blurRadius: 6.r,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10.r)),
                child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                    ? Image.network(
                        item.imageUrl!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          color: Colors.grey.shade100,
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      )
                    : Container(
                        width: double.infinity,
                        color: AppTheme.primaryColor.withOpacity(0.05),
                        child: Icon(Icons.image_outlined, color: AppTheme.primaryColor.withOpacity(0.4)),
                      ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.shortDescription != null && item.shortDescription!.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        item.shortDescription!,
                        style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade500),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ]
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class AnnouncementVerticalList extends StatelessWidget {
  final List<AnnouncementItem> items;
  final Function(AnnouncementItem) onTap;
  const AnnouncementVerticalList({Key? key, required this.items, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: items.length,
      padding: EdgeInsets.zero,
      physics: const BouncingScrollPhysics(),
      separatorBuilder: (context, index) => Divider(height: 8.h, color: Colors.grey.shade100),
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () => onTap(item),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 4.h),
            color: Colors.transparent,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6.r),
                  child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                      ? Image.network(
                          item.imageUrl!,
                          width: 40.w,
                          height: 40.h,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            width: 40.w,
                            height: 40.h,
                            color: Colors.grey.shade100,
                            child: const Icon(Icons.image, size: 16),
                          ),
                        )
                      : Container(
                          width: 40.w,
                          height: 40.h,
                          color: AppTheme.primaryColor.withOpacity(0.05),
                          child: Icon(Icons.campaign, color: AppTheme.primaryColor, size: 16.sp),
                        ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (item.shortDescription != null && item.shortDescription!.isNotEmpty) ...[
                        SizedBox(height: 2.h),
                        Text(
                          item.shortDescription!,
                          style: TextStyle(fontSize: 9.sp, color: Colors.grey.shade500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ]
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 10.sp, color: Colors.grey.shade300)
              ],
            ),
          ),
        );
      },
    );
  }
}

class AnnouncementSingleBanner extends StatelessWidget {
  final AnnouncementItem item;
  final Function(AnnouncementItem) onTap;
  const AnnouncementSingleBanner({Key? key, required this.item, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(item),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.04),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.12)),
        ),
        padding: EdgeInsets.all(10.w),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Icon(Icons.label_important, color: Colors.orange.shade700, size: 14.sp),
                      SizedBox(width: 4.w),
                      Text(
                        "Latest Announcement",
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.shortDescription != null && item.shortDescription!.isNotEmpty) ...[
                    SizedBox(height: 3.h),
                    Text(
                      item.shortDescription!,
                      style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ]
                ],
              ),
            ),
            if (item.imageUrl != null && item.imageUrl!.isNotEmpty) ...[
              SizedBox(width: 10.w),
              ClipRRect(
                borderRadius: BorderRadius.circular(6.r),
                child: Image.network(
                  item.imageUrl!,
                  width: 65.w,
                  height: 65.h,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => const SizedBox.shrink(),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}
