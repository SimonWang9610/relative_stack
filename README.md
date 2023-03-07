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

The below cod would stack its children:

- `tag 1` would be relative to `RelativeStack` self, and its center would be overlapped at the center of `RelativeStack`
- `tag 2` would be relative to `tag 1`, and its `bottomRight` would be overlapped at the `topLeft` of `tag 1`
- `tag 3` would be also relative to `tag 1`, and its `topLeft` would be overlapped at the `center` of `tag 1` and be shifted `Offset(-10, 10)` absolutely
- `tag 4` would be relative to `RelativeStack` self, and its `topRight` would be aligned to the `topRight` of `RelativeStack`
- `tag 5` would be also relative to `tag 1`, and its `topCenter` would be aligned to the `bottomCenter` of `tag 1`
- `tag 6` is not wrapped in `RelativePositioned`, so it would be treated as a normal widget and painted from the `topLeft` of `RelativeStack`

```dart
class RelativeStackExample extends StatelessWidget {
  const RelativeStackExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.red, width: 2),
          ),
          child: RelativeStack(
            // clipBehavior: Clip.hardEdge,
            children: [
              SizedBox.square(
                dimension: 300,
                child: GestureDetector(
                  onTap: () {
                    print("tap non relative widget");
                  },
                  child: ColoredBox(color: Colors.green),
                ),
              ),
              RelativePositioned(
                id: 1,
                preferSize: const Size.square(150),
                targetAnchor: Alignment.center,
                followAnchor: Alignment.center,
                child: GestureDetector(
                  onTap: () {
                    print("tap: 1");
                  },
                  child: ColoredBox(color: Colors.red),
                ),
              ),
              RelativePositioned(
                id: 2,
                relativeTo: 1,
                followAnchor: Alignment.bottomRight,
                // shift: Offset(10, 10),
                preferSize: Size.square(100),
                child: GestureDetector(
                  onTap: () {
                    print("tap: 2");
                  },
                  child: ColoredBox(color: Colors.yellow),
                ),
              ),
              RelativePositioned(
                id: 3,
                relativeTo: 1,
                targetAnchor: Alignment.center,
                preferSize: Size(100, 50),
                shift: Offset(-10, 10),
                child: GestureDetector(
                  onTap: () {
                    print("tap: 3");
                  },
                  child: ColoredBox(color: Colors.blue),
                ),
              ),
              RelativePositioned(
                id: 4,
                // relativeTo: 1,
                targetAnchor: Alignment.topRight,
                followAnchor: Alignment.topRight,
                preferSize: Size.square(100),
                child: GestureDetector(
                  onTap: () {
                    print("tap: 4");
                  },
                  child: ColoredBox(color: Colors.black),
                ),
              ),
              RelativePositioned(
                id: 5,
                relativeTo: 1,
                targetAnchor: Alignment.bottomCenter,
                followAnchor: Alignment.topCenter,
                preferSize: Size.square(80),
                child: GestureDetector(
                  onTap: () {
                    print("tap: 5");
                  },
                  child: ColoredBox(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

```

### why `RelativePositioned` is overflowing

Truly, the `RelativePositioned` widgets may be outside of the `Size` of `RelativeStack` (overflowing) because they would only follow their `RelativePositioned.relativeTo` instead of relative to `RelativeStack` directly. Only those `RelativePositioned` that have no `relativeTo` property would be relative to `RelativeStack` directly.

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
