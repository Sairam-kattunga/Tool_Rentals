import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback

class AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final Color? backgroundColor; // Allow custom background
  final Color? splashColor;     // Color when pressed
  final Color? textColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final bool isLoading; // For loading state

  const AnimatedButton({
    super.key,
    required this.text,
    required this.onTap,
    this.backgroundColor,
    this.splashColor,
    this.textColor,
    this.borderRadius,
    this.padding,
    this.textStyle,
    this.isLoading = false,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150), // For scale
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize color animation here because Theme.of(context) is available
    final theme = Theme.of(context);
    final defaultBackgroundColor = widget.backgroundColor ?? theme.colorScheme.primary;
    final defaultSplashColor = widget.splashColor ?? theme.colorScheme.primaryContainer; // Or a slightly darker/lighter primary

    _colorAnimation = ColorTween(
      begin: defaultBackgroundColor,
      end: defaultSplashColor,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }


  Future<void> _handleTapDown(TapDownDetails details) async {
    if (widget.isLoading) return;
    HapticFeedback.lightImpact(); // Haptic feedback
    _controller.forward();
    setState(() => _isPressed = true);
  }

  Future<void> _handleTapUp(TapUpDetails details) async {
    if (widget.isLoading) return;
    await _controller.reverse();
    setState(() => _isPressed = false);
    widget.onTap();
  }

  Future<void> _handleTapCancel() async {
    if (widget.isLoading) return;
    if (_isPressed) {
      await _controller.reverse();
      setState(() => _isPressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultBorderRadius = widget.borderRadius ?? BorderRadius.circular(12);
    final defaultPadding = widget.padding ?? const EdgeInsets.symmetric(vertical: 16, horizontal: 24);
    final defaultTextColor = widget.textColor ?? theme.colorScheme.onPrimary;
    final defaultTextStyle = widget.textStyle ?? TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: defaultTextColor);

    // Use the _colorAnimation.value which will be driven by the controller
    // If not pressed, use the initial color derived from widget.backgroundColor or theme.
    final currentBackgroundColor = _isPressed && !widget.isLoading
        ? _colorAnimation.value
        : (widget.backgroundColor ?? theme.colorScheme.primary);


    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedBuilder( // To rebuild when colorAnimation changes
          animation: _colorAnimation,
          builder: (context, child) {
            return Container(
              padding: defaultPadding,
              decoration: BoxDecoration(
                color: widget.isLoading
                    ? (widget.backgroundColor ?? theme.colorScheme.primary).withOpacity(0.5) // Dim if loading
                    : currentBackgroundColor,
                borderRadius: defaultBorderRadius,
                boxShadow: _isPressed && !widget.isLoading // Subtle shadow change on press
                    ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  )
                ]
                    : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              alignment: Alignment.center,
              child: widget.isLoading
                  ? SizedBox(
                width: defaultTextStyle.fontSize ?? 18, // Match text size
                height: defaultTextStyle.fontSize ?? 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(defaultTextColor),
                ),
              )
                  : Text(
                widget.text,
                style: defaultTextStyle.copyWith(color: defaultTextColor),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
