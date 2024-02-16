import 'package:flutter/widgets.dart';

import 'render_relative_stack.dart';
import 'stack.dart';

/// [id] would identify the [RelativePositioned]
///
/// [relativeTo] would be the [id] of [RelativePositioned] that it is relative to
///
/// [preferSize] would constrain the size [child] as soon as possible.
/// if not specify [preferSize], it would use [RelativeStack]'s [BoxConstraints]
///
/// [targetAnchor] would be used to compute the origin.
/// for example, if its [relativeTo] has Size(100, 100), it's target origin would be: [targetAnchor.alongSize(relativeSize)]
///
/// [followAnchor] would be used to compute which point should follow the target origin
/// its relative position would be computed as:
/// paintOrigin + targetOrigin - followPoint + [shift]
/// paintOrigin is passed from Flutter
/// targetOrigin is computed using [targetAnchor] and its [relativeTo]'s [Size]
/// followPoint is computed using [followAnchor] and itself [Size]
/// [shift] describes the absolute space between [targetOrigin] and [followPoint]
///
class RelativePositioned extends ParentDataWidget<RelativeParentData> {
  final Object id;
  final Object? relativeTo;
  final Size? preferSize;
  final Alignment targetAnchor;
  final Alignment followAnchor;
  final Offset shift;

  const RelativePositioned({
    super.key,
    required this.id,
    required super.child,
    this.targetAnchor = Alignment.topLeft,
    this.followAnchor = Alignment.topLeft,
    this.shift = Offset.zero,
    this.preferSize,
    this.relativeTo,
  });

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is RelativeParentData);

    final parentData = renderObject.parentData! as RelativeParentData;

    bool needsLayout = false;

    if (parentData.id != id) {
      parentData.id = id;
      needsLayout = true;
    }

    if (parentData.followAnchor != followAnchor) {
      parentData.followAnchor = followAnchor;
      needsLayout = true;
    }

    if (parentData.targetAnchor != targetAnchor) {
      parentData.targetAnchor = targetAnchor;
      needsLayout = true;
    }

    if (parentData.preferSize != preferSize) {
      parentData.preferSize = preferSize;
      needsLayout = true;
    }

    if (parentData.shift != shift) {
      parentData.shift = shift;
      needsLayout = true;
    }

    if (parentData.relativeTo != relativeTo) {
      parentData.relativeTo = relativeTo;
      needsLayout = true;
    }

    if (needsLayout) {
      final RenderObject? targetParent = renderObject.parent;
      if (targetParent is RenderObject) {
        targetParent.markNeedsLayout();
      }
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => RelativeStack;
}

class AnimatedRelative extends ImplicitlyAnimatedWidget {
  final Object id;
  final Object? relativeTo;
  final Size? preferSize;
  final Alignment targetAnchor;
  final Alignment followAnchor;
  final Offset shift;
  final Widget child;

  const AnimatedRelative({
    super.key,
    required super.duration,
    required this.id,
    required this.child,
    super.curve,
    this.targetAnchor = Alignment.topLeft,
    this.followAnchor = Alignment.topLeft,
    this.shift = Offset.zero,
    this.preferSize,
    this.relativeTo,
  });

  @override
  AnimatedWidgetBaseState<AnimatedRelative> createState() =>
      _AnimatedRelativeState();
}

class _AnimatedRelativeState extends AnimatedWidgetBaseState<AnimatedRelative> {
  Tween<Alignment>? _target;
  Tween<Alignment>? _follower;
  Tween<Offset>? _shift;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _target = visitor(_target, widget.targetAnchor,
            (value) => Tween<Alignment>(begin: value as Alignment))
        as Tween<Alignment>?;
    _follower = visitor(_follower, widget.followAnchor,
            (value) => Tween<Alignment>(begin: value as Alignment))
        as Tween<Alignment>?;

    _shift = visitor(_shift, widget.shift,
        (value) => Tween<Offset>(begin: value as Offset)) as Tween<Offset>?;
  }

  @override
  Widget build(BuildContext context) {
    final targetAnchor = _target?.evaluate(animation) ?? Alignment.topLeft;
    final followAnchor = _follower?.evaluate(animation) ?? Alignment.topLeft;

    return RelativePositioned(
      id: widget.id,
      relativeTo: widget.relativeTo,
      preferSize: widget.preferSize,
      targetAnchor: targetAnchor,
      followAnchor: followAnchor,
      shift: _shift?.evaluate(animation) ?? Offset.zero,
      child: widget.child,
    );
  }
}
