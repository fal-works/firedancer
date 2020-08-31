# Firedancer

A Haxe based language for defining 2D shmups bullet-hell patterns.

You can write any bullet pattern in Haxe and compile it into bytecode programs,  
which can be run on [Firedancer VM](https://github.com/fal-works/firedancer-vm).

Inspired by [BulletML](http://www.asahi-net.or.jp/~cs8k-cyu/bulletml/index_e.html).

## Demo

[https://firedancer-lang.com/](https://firedancer-lang.com/)

## Usage

### Install

First install [Haxe 4](https://haxe.org/).

Then install Firedancer:

    haxelib install firedancer

### Create bullet patterns

Import top-level properties and functions:

    import firedancer.script.Api.*;
    import firedancer.script.ApiEx.*;

Using that API of Firedancer (see also [Wiki](https://github.com/fal-works/firedancer/wiki)),  
define your own bullet patterns and compile them into a `ProgramPackage`.

### Run

Attach any `Program` instance(s) to your actor(s) and run them on [Firedancer VM](https://github.com/fal-works/firedancer-vm).

_Note: Firedancer is not a game engine. You have to prepare your own program to create/update/render your actors._

## Documentation

[Firedancer Wiki](https://github.com/fal-works/firedancer/wiki)

## Caveats

-   It's still alpha and quite unstable. Everything may change in future.
-   A bunch of spaghetti code!! Much more to be refactored/optimized.

## Dependencies

-   [sinker](https://github.com/fal-works/sinker) v0.4.0 or compatible
-   [sneaker](https://github.com/fal-works/sneaker) v0.10.0 or compatible
-   [ripper](https://github.com/fal-works/ripper) v0.4.0 or compatible
-   [banker](https://github.com/fal-works/banker) v0.7.0 or compatible
-   [reckoner](https://github.com/fal-works/banker) v0.2.0 or compatible
-   [firedancer-vm](https://github.com/fal-works/firedancer-vm) v0.1.0 or compatible
