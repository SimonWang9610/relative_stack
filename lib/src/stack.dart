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
