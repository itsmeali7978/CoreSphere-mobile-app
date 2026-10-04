import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/api/api_client.dart';
import '../../../core/services/module_navigation_service.dart';
import '../../../data/models/dashboard_card.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

export 'announcement_widgets.dart';

Color resolveCardColor(String? colorStr) {
  if (colorStr == null) return AppTheme.primaryColor;
  switch (colorStr.toLowerCase()) {
    case 'blue':
      return Colors.blue.shade600;
    case 'green':
      return Colors.green.shade600;
    case 'orange':
      return Colors.orange.shade600;
    case 'red':
      return Colors.red.shade600;
    case 'purple':
      return Colors.purple.shade600;
    case 'teal':
      return Colors.teal.shade600;
    default:
      return AppTheme.primaryColor;
  }
}

IconData resolveCardIcon(String? iconName) {
  if (iconName == null) return Icons.insert_chart;
  switch (iconName.toLowerCase()) {
    case 'customers':
    case 'people':
      return Icons.people;
    case 'receipt':
    case 'payment':
      return Icons.receipt_long;
    case 'sales':
    case 'trending_up':
      return Icons.trending_up;
    case 'pending':
    case 'hourglass':
      return Icons.hourglass_empty;
    case 'chart':
    case 'bar_chart':
      return Icons.bar_chart;
    case 'notifications':
    case 'announcement':
    case 'campaign':
      return Icons.campaign;
    case 'speed':
    case 'dashboard':
      return Icons.dashboard;
    case 'flash':
    case 'quick':
    case 'bolt':
      return Icons.bolt;
    default:
      return Icons.insert_chart;
  }
}

class BaseDashboardCard extends StatelessWidget {
  final DashboardCard card;
  final double height;
  final Widget child;
  final VoidCallback? onTap;

  const BaseDashboardCard({
    Key? key,
    required this.card,
    required this.height,
    required this.child,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardColor = resolveCardColor(card.iconColor);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: cardColor.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: child,
          ),
        ),
      ),
    );
  }
}

// METRIC: Simple card presenting a large number or short key value metrics
class MetricCard extends StatefulWidget {
  final DashboardCard card;
  final double height;

  const MetricCard({Key? key, required this.card, required this.height}) : super(key: key);

  @override
  State<MetricCard> createState() => _MetricCardState();
}

class _MetricCardState extends State<MetricCard> {
  late Future<String> _valueFuture;

  @override
  void initState() {
    super.initState();
    _valueFuture = _fetchValue();
  }

  Future<String> _fetchValue() async {
    final code = widget.card.cardCode.trim().toUpperCase();
    try {
      final client = Get.find<ApiClient>();
      String? endpoint = widget.card.dataEndpoint;
      String path = (endpoint != null && endpoint.trim().isNotEmpty)
          ? endpoint
          : '/dashboard/stats';
      if (path.startsWith('/api/v1.0')) {
        path = path.substring(9);
      } else if (path.startsWith('/api')) {
        path = path.substring(4);
      }

      final response = await client.get(path);
      if (response.data != null) {
        final isSuccess = response.data['success'] == true || response.data['Success'] == true;
        if (isSuccess) {
          final data = response.data['data'] ?? response.data['Data'];
          if (data != null) {
            if (code.contains('CUSTOMER')) {
              return data['totalCustomers']?.toString() ?? data['TotalCustomers']?.toString() ?? '0';
            } else if (code.contains('EMPLOYEE') || code.contains('STAFF')) {
              return data['totalEmployees']?.toString() ?? data['TotalEmployees']?.toString() ?? '0';
            } else if (code.contains('PAYMENT') || code.contains('COLLECTION') || code.contains('RECEIPT')) {
              return data['paymentReceipts']?.toString() ?? data['PaymentReceipts']?.toString() ?? '0';
            } else if (code.contains('USER') || code.contains('ACTIVE')) {
              return data['activeUsers']?.toString() ?? data['ActiveUsers']?.toString() ?? '0';
            } else if (code.contains('AGING')) {
              return data['paymentReceipts']?.toString() ?? data['PaymentReceipts']?.toString() ?? '0';
            } else if (code.contains('ROLE')) {
              return data['totalRoles']?.toString() ?? data['TotalRoles']?.toString() ?? '0';
            } else if (code.contains('MODULE')) {
              return data['totalModules']?.toString() ?? data['TotalModules']?.toString() ?? '0';
            }
          }
        }
      }
    } catch (e, stack) {
      print("MetricCard fetch error: $e");
    }
    return widget.card.cardDescription ?? '0';
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = resolveCardColor(widget.card.iconColor);
    final code = widget.card.cardCode.trim().toUpperCase();

    VoidCallback? onTap;
    if (code.contains('EMPLOYEE') || code.contains('STAFF')) {
      onTap = () {
        Get.find<ModuleNavigationService>().navigateToModule('EMPLOYEES');
      };
    } else if (code.contains('CUSTOMER')) {
      onTap = () {
        Get.find<ModuleNavigationService>().navigateToModule('CUSTOMERS');
      };
    } else if (code.contains('PAYMENT') || code.contains('COLLECTION') || code.contains('RECEIPT')) {
      onTap = () {
        Get.find<ModuleNavigationService>().navigateToModule('COLLECTIONS');
      };
    }

    return BaseDashboardCard(
      card: widget.card,
      height: widget.height,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38.w,
                height: 38.h,
                decoration: BoxDecoration(
                  color: cardColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  resolveCardIcon(widget.card.iconName),
                  color: cardColor,
                  size: 22.sp,
                ),
              ),
              Container(
                width: 8.w,
                height: 8.h,
                decoration: BoxDecoration(
                  color: cardColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Expanded(
            child: FutureBuilder<String>(
              future: _valueFuture,
              builder: (context, snapshot) {
                final val = snapshot.data ?? '...';
                final isNumeric = RegExp(r'^\d+$').hasMatch(val);
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      widget.card.cardTitle,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      val,
                      style: TextStyle(
                        fontSize: isNumeric ? 22.sp : 12.sp,
                        fontWeight: isNumeric ? FontWeight.bold : FontWeight.normal,
                        color: isNumeric ? cardColor : Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// AGING: Display accounts/debts aging details
class AgingCard extends StatefulWidget {
  final DashboardCard card;
  final double height;

  const AgingCard({Key? key, required this.card, required this.height}) : super(key: key);

  @override
  State<AgingCard> createState() => _AgingCardState();
}

class _AgingCardState extends State<AgingCard> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchData();
  }

  Future<Map<String, dynamic>> _fetchData() async {
    try {
      final client = Get.find<ApiClient>();
      String? endpoint = widget.card.dataEndpoint;
      String path = (endpoint != null && endpoint.trim().isNotEmpty)
          ? endpoint
          : '/customer-aging/dashboard-summary';
      if (path.startsWith('/api/v1.0')) {
        path = path.substring(9);
      } else if (path.startsWith('/api')) {
        path = path.substring(4);
      }
      final response = await client.get(path);
      if (response.data != null) {
        final isSuccess = response.data['success'] == true || response.data['Success'] == true;
        if (isSuccess) {
          final data = response.data['data'] ?? response.data['Data'];
          if (data != null && data is Map) {
            return Map<String, dynamic>.from(data);
          }
        }
      }
    } catch (e, stack) {
      print("AgingCard fetch error: $e");
      print(stack);
    }
    return {};
  }

  String _formatAmount(dynamic amt) {
    if (amt == null) return '⃁ 0';
    double value = double.tryParse(amt.toString()) ?? 0.0;
    if (value >= 1000000) {
      return '⃁ ${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '⃁ ${(value / 1000).toStringAsFixed(0)}K';
    }
    return '⃁ ${value.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = resolveCardColor(widget.card.iconColor);
    final cardCode = widget.card.cardCode.trim().toUpperCase();
    print("AgingCard: Code='$cardCode', Title='${widget.card.cardTitle}', cardHeight='${widget.card.cardHeight}', resolvedHeight='${widget.height}'");

    if (cardCode == 'AGE_AMNT' || cardCode == 'DUE_AMNT') {
      return BaseDashboardCard(
        card: widget.card,
        height: widget.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.date_range_outlined, color: cardColor, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  widget.card.cardTitle,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryColor,
                  ),
                ),
              ],
            ),
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final data = snapshot.data ?? {};
                  final buckets = data['buckets'] as List?;
                  
                  String currentVal = '⃁ 0';
                  String d31Val = '⃁ 0';
                  String d61Val = '⃁ 0';
                  String over90Val = '⃁ 0';

                  if (buckets != null) {
                    for (var b in buckets) {
                      final title = b['title']?.toString().toLowerCase() ?? '';
                      final amt = b['amount'];
                      if (title.contains('0-30') || title.contains('current')) {
                        currentVal = _formatAmount(amt);
                      } else if (title.contains('31-60')) {
                        d31Val = _formatAmount(amt);
                      } else if (title.contains('61-90')) {
                        d61Val = _formatAmount(amt);
                      } else if (title.contains('>90') || title.contains('over')) {
                        over90Val = _formatAmount(amt);
                      }
                    }
                  }

                  return Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 110.w,
                            child: _buildBucketColumn(
                              "CURRENT\n(0-30D)", 
                              currentVal, 
                              "0-30 DAYS", 
                              const Color(0xFF2EC4B6),
                              () => Get.toNamed(RouteNames.customerAgingBucket, arguments: 'CURRENT'),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          SizedBox(
                            width: 110.w,
                            child: _buildBucketColumn(
                              "31-60\nDAYS", 
                              d31Val, 
                              "31-60 DAYS", 
                              const Color(0xFFFFBF00),
                              () => Get.toNamed(RouteNames.customerAgingBucket, arguments: '31-60'),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          SizedBox(
                            width: 110.w,
                            child: _buildBucketColumn(
                              "61-90\nDAYS", 
                              d61Val, 
                              "61-90 DAYS", 
                              const Color(0xFFFF9F1C),
                              () => Get.toNamed(RouteNames.customerAgingBucket, arguments: '61-90'),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          SizedBox(
                            width: 110.w,
                            child: _buildBucketColumn(
                              ">90\nDAYS", 
                              over90Val, 
                              "OVER 90 DAYS", 
                              const Color(0xFFE71D36),
                              () => Get.toNamed(RouteNames.customerAgingBucket, arguments: 'OVER90'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    // Default Fallback
    return BaseDashboardCard(
      card: widget.card,
      height: widget.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.date_range_outlined, color: cardColor, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                widget.card.cardTitle,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondaryColor,
                ),
              ),
            ],
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAgingBar("0 - 30 Days", 0.75, Colors.blue.shade400, "SR 450,000"),
                SizedBox(height: 6.h),
                _buildAgingBar("31 - 60 Days", 0.40, Colors.orange.shade400, "SR 240,000"),
                SizedBox(height: 6.h),
                _buildAgingBar("60+ Days", 0.15, Colors.red.shade400, "SR 90,000"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBucketColumn(String title, String amountText, String subtitle, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            amountText,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              fontFamilyFallback: const ['SaudiRiyal'],
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 9.sp,
              fontWeight: FontWeight.w600,
              height: 1.1,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

  Widget _buildAgingBar(String title, double percentage, Color color, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
            ),
            Text(
              value,
              style: TextStyle(fontSize: 11.sp, color: AppTheme.secondaryColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 4.h,
            backgroundColor: Colors.grey.shade100,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

// LIST: Present list summaries with scroll/list indicators
class ListCard extends StatelessWidget {
  final DashboardCard card;
  final double height;

  const ListCard({Key? key, required this.card, required this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardColor = resolveCardColor(card.iconColor);

    final List<Map<String, dynamic>> mockData = [
      {"ref": "RCP-2026-0041", "cust": "Bin Hadi Trading Est.", "amt": "SR 4,200.00", "status": "Posted", "color": Colors.blue},
      {"ref": "RCP-2026-0040", "cust": "Al-Riyadh Logistics", "amt": "SR 12,850.00", "status": "ERP Posted", "color": Colors.green},
      {"ref": "RCP-2026-0039", "cust": "Zamil Industrial Group", "amt": "SR 9,150.00", "status": "ERP Posted", "color": Colors.green},
      {"ref": "RCP-2026-0038", "cust": "SABIC Petrochemicals", "amt": "SR 25,400.00", "status": "Posted", "color": Colors.blue},
      {"ref": "RCP-2026-0037", "cust": "Saudi Telecom Company", "amt": "SR 8,900.00", "status": "ERP Posted", "color": Colors.green},
      {"ref": "RCP-2026-0036", "cust": "National Water Co.", "amt": "SR 3,150.00", "status": "Posted", "color": Colors.blue},
    ];

    final limit = card.maxItems ?? 3;
    final displayItems = mockData.take(limit).toList();

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
                  Icon(resolveCardIcon(card.iconName), color: cardColor, size: 20.sp),
                  SizedBox(width: 8.w),
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
              if (card.maxItems != null)
                Text(
                  "Limit: ${card.maxItems}",
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500),
                )
            ],
          ),
          SizedBox(height: 12.h),
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayItems.length,
              separatorBuilder: (context, index) => Divider(height: 12.h, color: Colors.grey.shade100),
              itemBuilder: (context, index) {
                final item = displayItems[index];
                return _buildListItem(
                  item["ref"] as String,
                  item["cust"] as String,
                  item["amt"] as String,
                  item["status"] as String,
                  item["color"] as Color,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(String ref, String customer, String amount, String status, Color statusColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ref,
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppTheme.secondaryColor),
              ),
              Text(
                customer,
                style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              amount,
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppTheme.secondaryColor),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                status,
                style: TextStyle(fontSize: 8.sp, fontWeight: FontWeight.bold, color: statusColor),
              ),
            )
          ],
        )
      ],
    );
  }
}

// CHART: Displays premium charts or stats vectors
class ChartCard extends StatelessWidget {
  final DashboardCard card;
  final double height;

  const ChartCard({Key? key, required this.card, required this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardColor = resolveCardColor(card.iconColor);

    return BaseDashboardCard(
      card: card,
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart, color: cardColor, size: 20.sp),
              SizedBox(width: 8.w),
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
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar("Jan", 0.40, cardColor),
                _buildBar("Feb", 0.55, cardColor),
                _buildBar("Mar", 0.75, cardColor),
                _buildBar("Apr", 0.50, cardColor),
                _buildBar("May", 0.85, cardColor),
                _buildBar("Jun", 0.95, cardColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String label, double factor, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: factor,
              child: Container(
                width: 18.w,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.8),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4.r),
                    topRight: Radius.circular(4.r),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          label,
          style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade500),
        )
      ],
    );
  }
}

// PROGRESS: Display circular or linear target tracking
class ProgressCard extends StatelessWidget {
  final DashboardCard card;
  final double height;

  const ProgressCard({Key? key, required this.card, required this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardColor = resolveCardColor(card.iconColor);

    return BaseDashboardCard(
      card: card,
      height: height,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  card.cardTitle,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryColor,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  card.cardDescription ?? 'Target progress indicators',
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 70.w,
                height: 70.h,
                child: CircularProgressIndicator(
                  value: 0.68,
                  strokeWidth: 8.w,
                  backgroundColor: Colors.grey.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(cardColor),
                ),
              ),
              Text(
                "68%",
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: AppTheme.secondaryColor),
              )
            ],
          )
        ],
      ),
    );
  }
}

// QUICK_ACTION: Large click shortcut buttons
class QuickActionCard extends StatelessWidget {
  final DashboardCard card;
  final double height;

  const QuickActionCard({Key? key, required this.card, required this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardColor = resolveCardColor(card.iconColor);

    return BaseDashboardCard(
      card: card,
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                card.cardTitle,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppTheme.secondaryColor),
              ),
              if (card.cardDescription != null) ...[
                SizedBox(height: 4.h),
                Text(
                  card.cardDescription!,
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500),
                )
              ]
            ],
          ),
          Container(
            width: 44.w,
            height: 44.h,
            decoration: BoxDecoration(
              color: cardColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              resolveCardIcon(card.iconName),
              color: cardColor,
              size: 24.sp,
            ),
          )
        ],
      ),
    );
  }
}

// RecentPaymentsCard: Renders the 10 most recent payment entries
class RecentPaymentsCard extends StatefulWidget {
  final DashboardCard card;
  final double height;

  const RecentPaymentsCard({Key? key, required this.card, required this.height}) : super(key: key);

  @override
  State<RecentPaymentsCard> createState() => _RecentPaymentsCardState();
}

class _RecentPaymentsCardState extends State<RecentPaymentsCard> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchData();
  }

  Future<List<dynamic>> _fetchData() async {
    try {
      final client = Get.find<ApiClient>();
      String? endpoint = widget.card.dataEndpoint;
      String path = (endpoint != null && endpoint.trim().isNotEmpty)
          ? endpoint
          : '/customerpaymentreceipts';
      if (path.startsWith('/api/v1.0')) {
        path = path.substring(9);
      } else if (path.startsWith('/api')) {
        path = path.substring(4);
      }
      
      final response = await client.get(path, queryParameters: {
        'PageNumber': 1,
        'PageSize': 10,
      });

      if (response.data != null) {
        final isSuccess = response.data['success'] == true || response.data['Success'] == true;
        if (isSuccess) {
          final payload = response.data['data'] ?? response.data['Data'];
          if (payload is List) {
            return payload;
          } else if (payload is Map && (payload['items'] is List || payload['Items'] is List)) {
            return (payload['items'] ?? payload['Items']) as List;
          }
        }
      }
    } catch (e, stack) {
      print("RecentPaymentsCard fetch error: $e");
      print(stack);
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = resolveCardColor(widget.card.iconColor);

    return BaseDashboardCard(
      card: widget.card,
      height: widget.height,
      onTap: () {
        Get.find<ModuleNavigationService>().navigateToModule('CUSTOMERPAYMENTRECEIPT');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long_outlined, color: cardColor, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                widget.card.cardTitle,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final list = snapshot.data ?? [];
                if (list.isEmpty) {
                  return Center(
                    child: Text(
                      "No recent payments found.",
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
                    ),
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: list.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = list[index];
                    final name = (item['customerName'] ?? item['CustomerName'] ?? item['customerNo'] ?? item['CustomerNo'] ?? 'N/A').toString();
                    final amt = double.tryParse((item['amount'] ?? item['Amount'] ?? item['collectedAmount'] ?? item['CollectedAmount'] ?? '0.0').toString()) ?? 0.0;
                    final dateStr = (item['createdDate'] ?? item['CreatedDate'])?.toString();
                    
                    String formattedDate = '';
                    if (dateStr != null && dateStr.isNotEmpty) {
                      try {
                        formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(dateStr).toLocal());
                      } catch (e) {
                        formattedDate = dateStr;
                      }
                    }

                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Row(
                        children: [
                          Container(
                            width: 36.w,
                            height: 36.h,
                            decoration: BoxDecoration(
                              color: cardColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Icon(
                              Icons.payment_outlined,
                              color: cardColor,
                              size: 18.sp,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              name,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.secondaryColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '⃁ ${amt.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                  fontFamilyFallback: const ['SaudiRiyal'],
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                formattedDate,
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

