# Matrioska

> Matrioska let you create your layout and define the content of your app in a simple way.  

- [Installation](#installation)
- [Usage](#usage)
  - [Standard Components](#standard-components)
  - [Meta](#meta)
    - [ComponentMeta](#componentmeta)
    - [MaterializableComponentMeta](#materializablecomponentmeta)
  - [Creating Components](#creating-components)
  - [Layout](#layout)
- [Roadmap](#roadmap)

> NOTE: Matrioska is under active development, until `1.0.0` APIs might and will change a lot. The project is work in progress, see [Roadmap](#roadmap) or open issues.

The vision of Matrioska is to let you build and prototype your app easily, reusing views and layouts, dynamically define the content of your app.
With Matrioska you can go as far as specifing the content and layout of your views from an external source (e.g. JSON).
With this power you can easily change the structure of your app, do A/B testing, staged rollout or prototype.

To build your UI you can use nested `Component`s. A `Component` can be 3 different things:

- **View**: Any `UIViewController` that can use AutoLayout to specify its `intrinsicContentSize`
- **Cluster**: Views with children (other `Component`s). A cluster is responsible of laying out its children’s views. Since a cluster is itself a view it can also contain other clusters.
- **Wrapper**: A View with only one child (a `Component`). You can see it as a special cluster or as a special view. It’s responsible to display its child’s view.

The goal is to provide a tiny, but powerful foundation to build your app on top of it.
Matrioska will contain a limited set of standard components and we will consider to add more on a case by case basis.  
It’s really easy to extend Matrioska to add new components that fits your needs (TODO hamburger example).

## Installation

Using [CocoaPods](http://cocoapods.org/):

```ruby
use_frameworks!
pod ‘Matrioska’
```

Using [Carthage](https://github.com/Carthage/Carthage):

```
github “runtastic/Matrioska”
```

## Usage

### Standard Components

Matrioska defines some standard `Component`s that can be used to create your layout:

| id | usage | config |
|---|----|-----|
| tabbar |  `ClusterLayout.tabBar(children, meta)` | `TabBarConfig` and `TabConfig` (children) |
| stack | `ClusterLayout.stack(children, meta)` | `StackConfig` |  

See the documentation for more informations.

### Meta

Every `Component` may handle additional metadata. The `Component`’s meta is optional and the `Component` is responsible to handle it correctlty. Metadata can be anything from configuration or additional information, for example a view controller title.

#### ComponentMeta

Every meta have to conform to `ComponentMeta` a simple protocol that provides a keyed (String) subscript.  
`ComponentMeta` provides a default implementation of a subscript that uses reflection (`Swift.Mirror`) to mirror the object and use its properties names and values. Object that conform to this protocol can eventually override this behavior.  
`ZipMeta` for example is a simple meta wrapper that aggregates multiple metas together, see its documentation and implementation for more info.
`Dictionary` also conforms to `ComponentMeta`, this is a convenient way to provide meta but is especially useful to materialize a `ComponentMeta` coming from a json/dictionary.

#### MaterializableComponentMeta

When creating a new `Component` you should document which kind of meta it expects. A good way to do this is to also create an object that represents the `Component`’s meta (e.g. see `StackConfig`) and make it conform to `ComponentMeta`.  
`MaterializableComponentMeta` however provides some more convenience methods that let you load your components from a json or materialize a meta from a dictionary.  
Other than `ComponentMeta`’s requirements you also need to provide a ` init?(meta: ComponentMeta)`, then you can materialize any compatible meta into your own `MaterializableComponentMeta`.  

Example:

```swift
public struct MyConfig: MaterializableComponentMeta {
    public let title: String
    
    public init?(meta: ComponentMeta) {
        guard let title = meta["title"] as? String else {
            return nil
        }
        self.title = title
    }
}
```

After defining `MyConfig` we can materialize it from other `ComponentMeta`s if possible:

```swift
MyConfig.materialize([“title”: “foo”]) // MyConfig(title: "foo")
MyConfig.materialize([“foo”: “foo”]) // nil
MyConfig.materialize(nil) // nil
MyConfig.materialize(anotherMyConfigInstance) // anotherMyConfigInstance
```

### Creating Components

Create custom components:

```swift
// Create a cluster by extending an existing implementation
extension UITabBarController {
    convenience init(children: [Component], meta: Any?) {
        self.init(nibName: nil, bundle: nil)
        self.viewControllers = children.flatMap { $0.viewController() }
        // handle meta
    }
}

// Any UIViewController can be used as a View
// we can define a convenience init or just use an inline closure to build the ViewController
class MyViewController: UIViewController {
    init(meta: Any?) {
        super.init(nibName: nil, bundle: nil)
        guard let meta = meta as? [String: Any] else { return }
        self.title = meta["title"] as? String
    }
}
```

Then create models that can be easily used to create the entire tree of views:

```swift
let component = Component.cluster(builder: UITabBarController.init, children: [
    Component.view(builder: MyViewController.init, meta: ["title": "tab1"]),
    Component.view(builder: { _ in UIViewController() }, meta: nil),
    ], meta: nil)

window.rootViewController = component.viewController()
```

### Layout

Views are responsible to define their `intrinsicContentSize` using AutoLayout, cluster can decide to respect or respect not their dimensions, both vertical and horizontal or also only one of the two.
To make sure the a `Component`’s `UIViewController`has a valid `intrinsicContentSize` you need to add appropriate constraints to the view. [To know more about this read the documentation about “Views with Intrinsic Content Size”](https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/AutolayoutPG/ViewswithIntrinsicContentSize.html).

## Roadmap

- Load Components from JSON
	- Serialization
	- Component Factories
- Rulesets to define the visibility of a Component
