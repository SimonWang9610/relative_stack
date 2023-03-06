import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'render_relative_stack.dart';

/// A widget that can stack its children relatively if the child is wrapped in [RelativePositioned]
///
/// {@tool snippet}
///
/// This sample shows how to use it
/// ```dart
/// class RelativeStackExample extends StatelessWidget {
///   const RelativeStackExample({super.key});

///   @override
///   Widget build(BuildContext context) {
///     return Center(
///       child: DecoratedBox(
///        decoration: BoxDecoration(border: Border.all()),
///         child: RelativeStack(
///           clipBehavior: Clip.hardEdge,
///           children: [
//             SizedBox.square(
///               dimension: 200,
///               child: GestureDetector(
///                 onTap: () {
///                   print("tap non relative widget");
///                 },
///                 child: ColoredBox(color: Colors.green),
///               ),
///             ),
///             RelativePositioned(
///               id: 1,
///               preferSize: const Size.square(100),
///               targetAnchor: Alignment.center,
///               followAnchor: Alignment.center,
///               child: GestureDetector(
///                 onTap: () {
///                   print("tap: 1");
///                 },
///                 child: ColoredBox(color: Colors.red),
///               ),
///             ),
///             RelativePositioned(
///               id: 2,
///               relativeTo: 1,
///               followAnchor: Alignment.bottomRight,
///               // shift: Offset(10, 10),
///               preferSize: Size.square(50),
///               child: GestureDetector(
///                 onTap: () {
///                   print("tap: 2");
///                 },
///                 child: ColoredBox(color: Colors.yellow),
///               ),
///             ),
///             RelativePositioned(
///               id: 3,
///               relativeTo: 1,
///               targetAnchor: Alignment.center,
///               preferSize: Size(100, 50),
///               child: GestureDetector(
///                 onTap: () {
///                   print("tap: 3");
///                 },
///                 child: ColoredBox(color: Colors.blue),
///               ),
///             ),
///             RelativePositioned(
///               id: 4,
///               // relativeTo: 1,
///               targetAnchor: Alignment.topRight,
///               followAnchor: Alignment.topRight,
///               preferSize: Size.square(50),
///               child: GestureDetector(
///                 onTap: () {
///                   print("tap: 4");
///                 },
///                 child: ColoredBox(color: Colors.black),
///               ),
///             ),
///             RelativePositioned(
///               id: 5,
///               relativeTo: 1,
///               targetAnchor: Alignment.bottomCenter,
///               followAnchor: Alignment.topCenter,
///               preferSize: Size.square(50),
///               child: GestureDetector(
///                 onTap: () {
///                   print("tap: 5");
///                 },
///                 child: ColoredBox(color: Colors.grey),
///               ),
///             ),
///           ],
///         ),
///       ),
///     );
///   }
/// }
/// ```
/// {@end-tool}
///
class RelativeStack extends MultiChildRenderObjectWidget {
  final Clip clipBehavior;

  RelativeStack({
    super.key,
    super.children,
    this.clipBehavior = Clip.none,
  });

  @override
  RenderRelativeStack createRenderObject(BuildContext context) {
    return RenderRelativeStack(clipBehavior: clipBehavior);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderRelativeStack renderObject) {
    renderObject.clipBehavior = clipBehavior;
  }
}

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
      final AbstractNode? targetParent = renderObject.parent;
      if (targetParent is RenderObject) {
        targetParent.markNeedsLayout();
      }
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => RelativeStack;
}
