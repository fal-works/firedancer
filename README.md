# Firedancer

A Haxe based language for defining 2D shmups bullet-hell patterns.

![firedancer_v0_1_0](https://user-images.githubusercontent.com/33595446/91944104-8398c480-ed38-11ea-927e-f0f107977e98.gif)

You can write any bullet pattern in Haxe and compile it into bytecode programs,  
which can be run on [Firedancer VM](https://github.com/fal-works/firedancer-vm).

Inspired by [BulletML](http://www.asahi-net.or.jp/~cs8k-cyu/bulletml/index_e.html).

Requires **Haxe 4** (developed with v4.1.3).


## Demo

[https://firedancer-lang.com/](https://firedancer-lang.com/)


## Usage

### Install

First install [Haxe 4](https://haxe.org/).

Then install Firedancer:

```sh
haxelib install firedancer
```

### Create bullet patterns

Import top-level properties and functions in your Haxe project:

```haxe
import firedancer.script.Api.*;
import firedancer.script.ApiEx.*;
```

Using that API of Firedancer (see also [Wiki](https://github.com/fal-works/firedancer/wiki)),  
define your own bullet patterns and compile them into a `ProgramPackage`.

### Run

Attach any `Program` instance(s) to your actor(s) and run them on [Firedancer VM](https://github.com/fal-works/firedancer-vm).

*Note: Firedancer is not a game engine. You have to prepare your own program to create/update/render your actors.*


## Example Project

Here is a minimum Haxe project using Firedancer and [Heaps.io](https://heaps.io/):

[Firedancer Template (with Heaps.io)](https://github.com/fal-works/firedancer-heaps-template)


## Documentation

[Firedancer Wiki](https://github.com/fal-works/firedancer/wiki)


## Caveats

- It's still alpha and quite unstable. Everything may change in future.
- A bunch of spaghetti code!! Much more to be refactored/optimized.


## Dependencies

- [sinker](https://github.com/fal-works/sinker) v0.5.0 or compatible
- [sneaker](https://github.com/fal-works/sneaker) v0.11.0 or compatible
- [ripper](https://github.com/fal-works/ripper) v0.4.0 or compatible
- [banker](https://github.com/fal-works/banker) v0.7.0 or compatible
- [reckoner](https://github.com/fal-works/banker) v0.2.0 or compatible
- [firedancer-vm](https://github.com/fal-works/firedancer-vm) v0.1.0 or compatible
