import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';

class CloudinaryImage extends StatelessWidget {
  final String? imageUrl;
  final String? thumbnailUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final bool useThumbnail;
  final String? cacheKey;

  const CloudinaryImage({
    Key? key,
    this.imageUrl,
    this.thumbnailUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.useThumbnail = false,
    this.cacheKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveUrl = useThumbnail && thumbnailUrl != null ? thumbnailUrl : imageUrl;
    
    if (effectiveUrl == null || effectiveUrl.isEmpty) {
      return _buildDefaultPlaceholder();
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(8.r),
      child: CachedNetworkImage(
        imageUrl: effectiveUrl,
        width: width,
        height: height,
        fit: fit,
        cacheKey: cacheKey ?? effectiveUrl,
        placeholder: (context, url) => placeholder ?? _buildLoadingPlaceholder(),
        errorWidget: (context, url, error) => errorWidget ?? _buildErrorPlaceholder(),
        memCacheWidth: width?.toInt(),
        memCacheHeight: height?.toInt(),
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: borderRadius ?? BorderRadius.circular(8.r),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: Get.theme.primaryColor,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: borderRadius ?? BorderRadius.circular(8.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            size: (width ?? 50) * 0.4,
            color: Colors.grey[400],
          ),
          SizedBox(height: 4.h),
          Text(
            'No Image',
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: borderRadius ?? BorderRadius.circular(8.r),
      ),
      child: Icon(
        Icons.image,
        size: (width ?? 50) * 0.4,
        color: Colors.grey[400],
      ),
    );
  }
}

class CircularCloudinaryImage extends StatelessWidget {
  final String? imageUrl;
  final String? thumbnailUrl;
  final double size;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool useThumbnail;

  const CircularCloudinaryImage({
    Key? key,
    this.imageUrl,
    this.thumbnailUrl,
    this.size = 50,
    this.placeholder,
    this.errorWidget,
    this.useThumbnail = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: CloudinaryImage(
        imageUrl: imageUrl,
        thumbnailUrl: thumbnailUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        useThumbnail: useThumbnail,
        placeholder: placeholder,
        errorWidget: errorWidget,
      ),
    );
  }
}

class ImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final List<String>? thumbnailUrls;
  final double height;
  final double? width;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final bool showIndicator;
  final Function(int)? onTap;
  final BorderRadius? borderRadius;

  const ImageCarousel({
    Key? key,
    required this.imageUrls,
    this.thumbnailUrls,
    this.height = 200,
    this.width,
    this.autoPlay = false,
    this.autoPlayInterval = const Duration(seconds: 3),
    this.showIndicator = true,
    this.onTap,
    this.borderRadius,
  }) : super(key: key);

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    if (widget.autoPlay && widget.imageUrls.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startAutoPlay();
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    Future.delayed(widget.autoPlayInterval, () {
      if (mounted && widget.imageUrls.isNotEmpty) {
        _nextPage();
        _startAutoPlay();
      }
    });
  }

  void _nextPage() {
    if (_currentIndex < widget.imageUrls.length - 1) {
      _currentIndex++;
    } else {
      _currentIndex = 0;
    }
    _pageController.animateToPage(
      _currentIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    if (_currentIndex > 0) {
      _currentIndex--;
    } else {
      _currentIndex = widget.imageUrls.length - 1;
    }
    _pageController.animateToPage(
      _currentIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: widget.borderRadius ?? BorderRadius.circular(8.r),
        ),
        child: Icon(
          Icons.image,
          size: 40.w,
          color: Colors.grey[400],
        ),
      );
    }

    return Stack(
      children: [
        Container(
          height: widget.height,
          width: widget.width,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.imageUrls.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => widget.onTap?.call(index),
                child: CloudinaryImage(
                  imageUrl: widget.imageUrls[index],
                  thumbnailUrl: widget.thumbnailUrls != null 
                      ? widget.thumbnailUrls![index] 
                      : null,
                  width: widget.width,
                  height: widget.height,
                  borderRadius: widget.borderRadius,
                ),
              );
            },
          ),
        ),
        
        // Navigation arrows
        if (widget.imageUrls.length > 1) ...[
          Positioned(
            left: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: _previousPage,
                  icon: Icon(Icons.chevron_left, color: Colors.white),
                ),
              ),
            ),
          ),
          Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: _nextPage,
                  icon: Icon(Icons.chevron_right, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
        
        // Page indicator
        if (widget.showIndicator && widget.imageUrls.length > 1)
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.imageUrls.length,
                (index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
