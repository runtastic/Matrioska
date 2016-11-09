# Matrioska

> Matrioska let you create your layout and define the content of your app in a simple way.  

- [Installation](#installation)
- [Usage](#usage)
  - [Layout](#layout)
- [Roadmap](#roadmap)

The vision of Matrioska is to let you build and prototype your app easily, reusing views and layouts, dynamically define the content of your app.
With Matrioska you can go as far as specifing the content and layout of your views from an external source (e.g. JSON).
With this power you can easily change the structure of your app, do A/B testing, staged rollout or prototype.
Matrioska is open source (see LICENSE) and we don’t keep an internal mirror of this repository.  

To build your UI you can use nested `Component`s. A `Component` can be 3 different things:
- **View**: Any `UIViewController` that can use AutouLayout to specify its `intrinsicContentSize`
- **Cluster**: Views with children (other `Component`s). A cluster is responsible of laying out its children’s views. Since a cluster is itself a view it can also contain other clusters.
- **Wrapper**: A View with only one child (a `Component`). You can see it as a special cluster or as a special view. It’s responsible to display its child’s view.

The goal is to provide a tiny but powerful foundation to build your app on top of it.
Matrioska will contian a limited set of standard components and we will consider to add more on a case by case basis.  
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

Create a model:

```swift
// TODO
```

From json…. TODO… schema…

Create a component:

```swift
// TODO
```

Register components in factories:

```swift
// TODO
```

#### Layout

View are responsible to define their `intrinsicContentSize` using AutouLayout, cluster can decide to respect or not their dimensions, both vertical and horizontal or also only one of the two.
To make sure the a `Component`’s `UIViewController`has a valid `intrinsicContentSize` you need to add appropriate constraints to the view. [To know more about this read the documentation about “Views with Intrinsic Content Size”](https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/AutolayoutPG/ViewswithIntrinsicContentSize.html).

## Roadmap

> TODO
