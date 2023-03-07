<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

[![pub package](https://img.shields.io/pub/v/relative_stack?color=blue&style=plastic)](https://pub.dev/packages/relative_stack)
[![GitHub Repo stars](https://img.shields.io/github/stars/SimonWang9610/relative_stack?color=black&logoColor=black&style=social)](https://github.com/SimonWang9610/relative_stack)

## Features

You could use `RelativeStack` to position its children relative to you specify widget. (the specified widget is also one of the children list)

<img src="https://github.com/SimonWang9610/relative_stack/blob/main/assets/relative_stack_demo.png?raw=true">

- `tag 1` would be relative to `RelativeStack` self, and its center would be overlapped at the center of `RelativeStack`
- `tag 2` would be relative to `tag 1`, and its `bottomRight` would be overlapped at the `topLeft` of `tag 1`
- `tag 3` would be also relative to `tag 1`, and its `topLeft` would be overlapped at the `center` of `tag 1` and be shifted `Offset(-10, 10)` absolutely
- `tag 4` would be relative to `RelativeStack` self, and its `topRight` would be aligned to the `topRight` of `RelativeStack`
- `tag 5` would be also relative to `tag 1`, and its `topCenter` would be aligned to the `bottomCenter` of `tag 1`
- `tag 6` is not wrapped in `RelativePositioned`, so it would be treated as a normal widget and painted from the `topLeft` of `RelativeStack`

By using `AnimatedRelative`, you could animate your widget's position like `AnimatedPositioned`:
<img src="https://github.com/SimonWang9610/relative_stack/blob/main/assets/demo1.gif?raw=true">
<img src="https://github.com/SimonWang9610/relative_stack/blob/main/assets/demo2.gif?raw=true">

## Questions

### Why `RelativePositioned`/`AnimatedRelative` is overflowing

Truly, the `RelativePositioned` widgets may be outside of the `Size` of `RelativeStack` (overflowing) because they would only follow their `RelativePositioned.relativeTo` instead of relative to `RelativeStack` directly. Only those `RelativePositioned` that have no `relativeTo` property would be relative to `RelativeStack` directly.

### Why the `AnimatedRelative` or `RelativePositioned` does not trigger gesture tapping events

If the `AnimatedRelative` or `RelativePositioned` is painted at the **outside of the size of `RelativeStack`** (it is possible because `RelativeStack` only ensure the widgets follow its target's position but not guarantee they are inside of its size), it cannot pass the `hitTest` due to the mechanism of Flutter hitTest:
<img src="https://github.com/SimonWang9610/relative_stack/blob/main/assets/hittest.png?raw=true">

### Why `AnimatedRelative` would change the size of `RelativeStack`

since the size of `RelativeStack` is computed as below, so its size might be change during animation

### How the size of `RelativeStack` is computed

Since the children list may contain normal widgets and `RelativePositioned`, so we follow the below rules to compute the size of `RelativeStack`.

1. For all `RelativePositioned` widgets, we would abstract them as multi-node tree according to their relations defined by `RelativePositioned.relativeTo`. After `layout` each render box, we could know their actual size, and then, we go through their relation trees to compute their relative `Size`s. Finally, we would compare the `RelativeSize` of each relation tree by:

```dart
  _RelativeSize compare(_RelativeSize other) {
    return _RelativeSize()
      ..top = min(top, other.top)
      ..left = min(left, other.left)
      ..right = max(right, other.right)
      ..bottom = max(bottom, other.bottom);
  }

```

to determine the maximum `Size` for all relation trees.

2. for normal widgets, we do not need to process them particularly, and we could know their actual sizes instantly once `layout` them.

Once we get all `Size`s ready, we could compare them to determine the final `Size` for `RelativeStack`:

```dart
    double width = idealRelativeSize.size.width;
    double height = idealRelativeSize.size.height;

    while (nonRelativeSizes.isNotEmpty) {
      final childSize = nonRelativeSizes.removeLast();

      width = max(childSize.width, width);
      height = max(childSize.height, height);
    }

    size = constraints.constrain(Size(width, height));
```
