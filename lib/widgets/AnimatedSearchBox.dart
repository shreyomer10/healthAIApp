import 'package:flutter/cupertino.dart';

class RotatingHintText extends StatefulWidget {
  final List<String> texts;
  final TextStyle style;

  const RotatingHintText({
    super.key,
    required this.texts,
    required this.style,
  });

  @override
  State<RotatingHintText> createState() => _RotatingHintTextState();
}

class _RotatingHintTextState extends State<RotatingHintText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideUp;
  late Animation<double> _fade;

  int _index = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: const Offset(0, -0.4),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _loop();
  }

  void _loop() async {
    while (mounted) {
      await _controller.forward();
      await Future.delayed(const Duration(milliseconds: 900));
      await _controller.reverse();

      setState(() {
        _index = (_index + 1) % widget.texts.length;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48, // SAME height as your search bar
      child: Align(
        alignment: Alignment.centerLeft, // vertical center
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slideUp,
            child: Text(
              widget.texts[_index],
              style: widget.style,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

}
