# Path Morph

This is a package that lets you smoothly morph one Flutter `Path` object into another. You can think of this as a path tween animation. The idea is to take two paths, a source path and a destination path, and smoothly move the points of the source path until it looks exactly like the destination path.

![](https://raw.githubusercontent.com/hathibelagal-dev/path_morph_for_flutter/master/example.gif)

## Tip

Use [path_drawing](https://pub.dev/packages/path_drawing) to transform svg's into paths!

(see bottom of example)

## Important

This package currently allows you to morph two paths only if they both have an equal number of contours. You can think of a contour as a line you can draw without lifting the pen. For example, the path to draw a triangle, a circle, or a square has one contour only. But a path to draw two concentric circles will have two contours.

## Usage

Simply provider an animationController and the paths you want to morph.
Move the controller forward to morph from path1 to path2 `_controller.forward();`
Move the controller backward to morph from path2 to path1 `_controller.reverse();`

```dart
MorphWidget(
  controller: _controller,
  path1: _path1,
  path2: _path2,
)
```

## Custom widget

You can use the `PathMorphUtils` to create your own widget.

First you need to sample two paths using the `PathMorphUtils.samplePaths()` method, which returns a `SampledPathData` object.

```dart
SampledPathData data = PathMorphUtils.samplePaths(path1, path2);
```

Then you call the `PathMorphUtils.generateAnimations()` method to create an animation for every point in the path. This method needs an `AnimationController` object and a `SampledPathData` object as arguments. Additionally, it expects you to pass a function to it, one that takes two arguments itself. In the body of the function, you must call `setState()` and update the value of the shiftedPoints list, which is present in the `SampledPathData` object.

```dart
AnimationController controller = AnimationController(vsync: this,
                                    duration: Duration(seconds: 1));

PathMorphUtils.generateAnimations(controller, data, (i,z) {
    setState((){
      data.shiftedPoints[i] = z;
    });
});
```

Lastly, while rendering the morph animation, you can call the `PathMorphUtils.generatePath()` method and pass the shiftedPoints list to it. This returns a Path object you can draw on your canvas. If you are using a `CustomPainter` object, you'll want to pass the path as an argument to it.

```dart
@override
Widget build(BuildContext context) {
    return CustomPaint(painter: MyPainter(PathMorphUtils.generatePath(data)));
}
```

Do take a look at the example project to get a better idea.
