import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ImagePostViewer extends StatefulWidget {
  final List<AmityPost> posts;
  final int initialIndex;

  const ImagePostViewer(
      {Key? key, required this.posts, required this.initialIndex})
      : super(key: key);

  @override
  _ImagePostViewerState createState() => _ImagePostViewerState();
}

class _ImagePostViewerState extends State<ImagePostViewer> {
  int _currentIndex = 0;

  // Pinch / double-tap zoom. While zoomed, PageView paging is disabled so a
  // drag pans the image instead of switching pages. The controller is shared
  // across pages and reset when the page changes.
  final TransformationController _transformationController =
      TransformationController();
  final double _maxScale = 4.0;
  final ValueNotifier<bool> _isZoomed = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _transformationController.addListener(() {
      _isZoomed.value =
          _transformationController.value.getMaxScaleOnAxis() > 1.0;
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _isZoomed.dispose();
    super.dispose();
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    if (_transformationController.value.getMaxScaleOnAxis() > 1.0) {
      _transformationController.value = Matrix4.identity();
    } else {
      final position = details.localPosition;
      _transformationController.value = Matrix4.identity()
        ..translate(
            -position.dx * (_maxScale - 1), -position.dy * (_maxScale - 1))
        ..scale(_maxScale);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Full-screen image viewer
            ValueListenableBuilder<bool>(
              valueListenable: _isZoomed,
              builder: (context, zoomed, _) => PageView.builder(
                physics: zoomed
                    ? const NeverScrollableScrollPhysics()
                    : const PageScrollPhysics(),
                controller: PageController(initialPage: widget.initialIndex),
                itemCount: widget.posts.length,
                onPageChanged: (index) {
                  // Reset any zoom when moving to a new page.
                  _transformationController.value = Matrix4.identity();
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  var imageData = widget.posts[index].data as ImageData;
                  return GestureDetector(
                    onDoubleTapDown: _handleDoubleTapDown,
                    child: InteractiveViewer(
                      transformationController: _transformationController,
                      minScale: 1,
                      maxScale: _maxScale,
                      child: Center(
                        child: Image.network(
                          imageData.image!.getUrl(AmityImageSize.LARGE),
                          fit: BoxFit
                              .contain, // Fit width, show full image without cropping
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.white54,
                                size: 64,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Top bar with translucent background, close button and counter
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.black.withOpacity(0.0),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Container(
                    constraints: const BoxConstraints(
                      maxHeight:
                          96, // Maximum twice the close button height (48px * 2)
                    ),
                    child: Row(
                      children: [
                        // Close button on the left
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: IconButton(
                            icon: SvgPicture.asset(
                              'assets/Icons/amity_ic_close_viewer.svg',
                              package: 'amity_uikit_beta_service',
                              width: 32,
                              height: 32,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),

                        // Counter indicator centered
                        Expanded(
                          child: Center(
                            child: Text(
                              '${_currentIndex + 1}/${widget.posts.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),

                        // Empty space on the right to balance the layout
                        const SizedBox(
                            width: 64), // Same width as close button area
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
