import 'dart:math';

import 'package:flutter/rendering.dart';

class RelativeParentData extends ContainerBoxParentData<RenderBox> {
  /// the unique id for [RelativePositioned]
  Object? id;

  /// the target [RelativePositioned] id it would follow
  /// if null, it would be relative to [RelativeStack]
  Object? relativeTo;

  /// its prefer size that would be combined with the incoming [BoxConstraints] and then used in [RenderBox.layout]
  Size? preferSize;

  /// the laid-out [Size] for this [RelativePositioned]
  Size size = Size.zero;

  /// the coordinate of the target it would follow
  Alignment targetAnchor = Alignment.topLeft;

  /// the point it would align itself to [targetAnchor]
  Alignment followAnchor = Alignment.topLeft;

  /// [shift] would be used to adjust the space between the target and itself
  /// if [Offset.dx] > 0, it would move itself right; otherwise, moving itself left
  /// if [Offset.dy] > 0, move itself down; otherwise, moving itself up
  /// such moving would be relative to its relative position determined by [targetAnchor] and [followAnchor] together
  Offset shift = Offset.zero;
}

class RenderRelativeStack extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, RelativeParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, RelativeParentData> {
  RenderRelativeStack({
    List<RenderBox>? children,
    Clip clipBehavior = Clip.hardEdge,
  }) : _clipBehavior = clipBehavior {
    addAll(children);
  }

  bool _hasVisualOverflow = false;

  Clip _clipBehavior = Clip.hardEdge;
  Clip get clipBehavior => _clipBehavior;

  set clipBehavior(Clip value) {
    if (_clipBehavior != value) {
      _clipBehavior = value;
      markNeedsPaint();
      markNeedsSemanticsUpdate();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! RelativeParentData) {
      child.parentData = RelativeParentData();
    }
  }

  /// Layout Step
  /// 1) we first layout all children in [_layoutChild].
  /// if the child has no [RelativeParentData.id], it would be treated as the normal widget (that is not wrapped in [RelativePositioned])
  /// if the child has [RelativeParentData.id], we would use its parent data later so as to build their relations
  ///
  /// 2) for all items in [_laidOutRelativeChildren], we would go through them using [_findRelation] to build their [_LayoutRelation]
  ///
  /// 3) once [_LayoutRelation]s are built, we would compute their [RelativeSize]s that would finally return
  /// a [Size] as much larger as possible. See [RelativeSize.compare]
  ///
  /// 4) after computing an ideal [RelativeSize], we would also compare the size with other non-relative [Size] if applicable
  /// so that we could get its final [Size] for [RenderRelativeStack]
  ///
  /// 5) finally, for those widgets that are wrapped in [RelativePositioned] but without [RelativeParentData.relativeTo],
  /// we should position them relative to the [RenderRelativeStack] using the computed [Size].
  /// Since all its relations are relative to itself, so we only need to translate them
  @override
  void performLayout() {
    _laidOutRelativeChildren = {};
    _relations = {};

    final BoxConstraints constraints = this.constraints;
    _hasVisualOverflow = false;

    RenderBox? child = firstChild;
    final List<Size> nonRelativeSizes = [];

    while (child != null) {
      final childParentData = child.parentData! as RelativeParentData;

      final nonRelativeSize = _layoutChild(child);

      if (nonRelativeSize != null) {
        nonRelativeSizes.add(nonRelativeSize);
      }

      child = childParentData.nextSibling;
    }

    for (final parentData in _laidOutRelativeChildren.values) {
      _findRelation(parentData);
    }

    _RelativeSize idealRelativeSize = _RelativeSize();

    for (final relation in _relations.values) {
      final relativeSize = _RelativeSize();

      relation.computeRelativeSize(Offset.zero, relativeSize: relativeSize);
      idealRelativeSize = idealRelativeSize.compare(relativeSize);
    }

    double width = idealRelativeSize.size.width;
    double height = idealRelativeSize.size.height;

    while (nonRelativeSizes.isNotEmpty) {
      final childSize = nonRelativeSizes.removeLast();

      width = max(childSize.width, width);
      height = max(childSize.height, height);
    }

    size = constraints.constrain(Size(width, height));

    for (final relation in _relations.values) {
      _hasVisualOverflow |= relation.translate(Offset.zero, size);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (clipBehavior != Clip.none && _hasVisualOverflow) {
      _clipRectLayer.layer = context.pushClipRect(
        needsCompositing,
        offset,
        Offset.zero & size,
        defaultPaint,
        clipBehavior: clipBehavior,
        oldLayer: _clipRectLayer.layer,
      );
    } else {
      defaultPaint(context, offset);
    }
  }

  final LayerHandle<ClipRectLayer> _clipRectLayer =
      LayerHandle<ClipRectLayer>();

  @override
  void dispose() {
    _clipRectLayer.layer = null;
    super.dispose();
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  Map<Object, _LayoutRelation> _relations = {};

  Map<Object, RelativeParentData> _laidOutRelativeChildren = {};

  Size? _layoutChild(RenderBox child) {
    final childParentData = child.parentData! as RelativeParentData;

    if (childParentData.id != null) {
      final size = childParentData.preferSize;

      final innerConstraints =
          constraints.tighten(width: size?.width, height: size?.height);
      child.layout(innerConstraints, parentUsesSize: true);

      assert(!_laidOutRelativeChildren.containsKey(childParentData.id),
          "Each child should have an unique key");

      childParentData.size = child.size;

      _laidOutRelativeChildren[childParentData.id!] = childParentData;
      return null;
    } else {
      child.layout(constraints, parentUsesSize: true);
      return child.size;
    }
  }

  _LayoutRelation _findRelation(RelativeParentData parentData) {
    late _LayoutRelation relation;
    assert(
        parentData.relativeTo == null ||
            _laidOutRelativeChildren.containsKey(parentData.relativeTo),
        "The specific relativeTo: ${parentData.relativeTo} does not exist");

    if (parentData.relativeTo == null) {
      relation = _LayoutRelation(id: parentData.id!, parentData: parentData);
      _relations[parentData.id!] = relation;
    } else {
      final parent = _relations[parentData.relativeTo] ??
          _findRelation(_laidOutRelativeChildren[parentData.relativeTo]!);

      if (!parent.hasRelation(parentData.id!)) {
        relation = _LayoutRelation(id: parentData.id!, parentData: parentData);
        parent.add(relation);
      } else {
        relation = parent.getRelation(parentData.id!);
      }
    }
    return relation;
  }
}

class _LayoutRelation {
  final Object id;
  final RelativeParentData parentData;
  final Map<Object, _LayoutRelation> relations;

  _LayoutRelation({
    required this.id,
    required this.parentData,
  }) : relations = {};

  bool hasRelation(Object childId) => relations.containsKey(childId);
  _LayoutRelation getRelation(Object childId) => relations[childId]!;

  void add(_LayoutRelation relation) {
    relations[relation.id] = relation;
  }

  void computeRelativeSize(
    Offset origin, {
    required _RelativeSize relativeSize,
    Size parentSize = Size.zero,
  }) {
    late Offset offset;

    if (parentData.relativeTo == null) {
      offset = relativeSize.topLeft + parentData.shift;
    } else {
      offset = origin +
          parentData.targetAnchor.alongSize(parentSize) -
          parentData.followAnchor.alongSize(parentData.size) +
          parentData.shift;
    }

    parentData.offset = offset;

    final bottomRight = parentData.size.bottomRight(offset);

    relativeSize.top = min(relativeSize.top, offset.dy);
    relativeSize.left = min(relativeSize.left, offset.dx);
    relativeSize.bottom = max(relativeSize.bottom, bottomRight.dy);
    relativeSize.right = max(relativeSize.right, bottomRight.dx);

    for (final relation in relations.values) {
      relation.computeRelativeSize(
        offset,
        relativeSize: relativeSize,
        parentSize: parentData.size,
      );
    }
  }

  bool translate(Offset origin, [Size size = Size.zero]) {
    Offset translate = Offset.zero;

    if (parentData.relativeTo == null) {
      translate = parentData.targetAnchor.alongSize(size) -
          parentData.followAnchor.alongSize(parentData.size) +
          parentData.shift -
          parentData.offset;
    }
    parentData.offset = origin + translate + parentData.offset;

    bool hasOverflow = size.contains(parentData.offset);

    for (final relation in relations.values) {
      hasOverflow |= relation.translate(origin + translate, size);
    }
    return hasOverflow;
  }
}

class _RelativeSize {
  double top = 0;
  double left = 0;
  double bottom = 0;
  double right = 0;

  Size get size => Size(right - left, bottom - top);

  Offset get topLeft => Offset(left, top);

  _RelativeSize compare(_RelativeSize other) {
    return _RelativeSize()
      ..top = min(top, other.top)
      ..left = min(left, other.left)
      ..right = max(right, other.right)
      ..bottom = max(bottom, other.bottom);
  }

  @override
  String toString() {
    return "left: $left, right: $right, top: $top, bottom: $bottom";
  }
}
